#!/usr/bin/env bash
# scripts/run_<order>_<topic>.sh
#
# <One-line purpose: download and preprocess <assay> data — accession → BAM.>
#
# Pipeline steps per sample:
#   1. [SRA only] prefetch + fasterq-dump  acc      → tmp/<s>_raw[_1/_2].fastq.gz
#   2. fastp      adapter trim + Q filter  raw      → tmp/<s>_trimmed[_1/_2].fastq.gz
#   3. bowtie2    rRNA filter (optional)   trimmed  → tmp/<s>_filtered[_1/_2].fastq.gz
#   4. STAR       genome alignment         filtered → genome_bams/<s>_genome.bam
#
# Single- and paired-end are detected automatically; no flag needed.
#
# Each step checks for its output before running — leave any intermediate file
# in place to resume from that point.
#
# Requires: the container image and the organism reference set.
#   apptainer build --fakeroot apptainer/pipeline.sif apptainer/pipeline.def
#   ./scripts/setup_<organism>_reference.sh
#
# Input mapping (any mix):
#   -m FILE   TSV: <sample_id>\t<accession_or_path>, '#' comments ignored.
#             Repeat a sample_id per lane — lanes are concatenated.
#   -d DIR    Directory of *.fastq.gz; sample id = filename without extension
#   SRR/ERR/DRR accession   — download from SRA
#   sample_id:path          — local single-end FASTQ
#   sample_id:r1.gz,r2.gz   — local paired-end FASTQ (comma separates mates)
#   bare sample_id          — resume from existing intermediates
#
# Options:
#   -o DIR    Output directory (default: results/<topic>)
#   -a SEQ    3' adapter, or "auto" for fastp detection (default: auto)
#   -l INT    Min read length after trim (default: 20)
#   -t INT    Threads (default: 16)
#   -R        Skip the rRNA filter
#   -k        Keep tmp intermediates
#   -h        Show this help
#
# Examples:
#   ./scripts/run_<order>_<topic>.sh SRR12345678 SRR12345679
#   ./scripts/run_<order>_<topic>.sh -m data/samples.tsv -o results/GSE123456 -t 22

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
cd "${ROOT_DIR}"
ORGANISM="${ORGANISM:-<organism>}"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/common.sh"

# ── Defaults ──────────────────────────────────────────────────────────────────
# ASSAY PRESETS — set these deliberately; the wrong ones fail silently.
#   RNA-seq  : MIN_LEN=20, no MAX_LEN, no TRIM_FRONT, multimappers kept
#   Ribo-seq : MIN_LEN=22, MAX_LEN=36, TRIM_FRONT=1, unique mappers only
# See reference.md — a Ribo-seq --length_limit on RNA-seq discards nearly every
# read and the run still exits 0.
OUT_DIR="${ROOT_DIR}/results/<topic>"
ADAPTER="auto"
MIN_LEN=20
SKIP_RRNA=false
KEEP_TMP=false
MAP_FILE=""
INPUT_DIR=""

while getopts ":o:a:l:t:Rkm:d:h" opt; do
    case $opt in
        o) OUT_DIR="$OPTARG" ;;
        a) ADAPTER="$OPTARG" ;;
        l) MIN_LEN="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        R) SKIP_RRNA=true ;;
        k) KEEP_TMP=true ;;
        m) MAP_FILE="$OPTARG" ;;
        d) INPUT_DIR="$OPTARG" ;;
        h) sed -n '2,/^set /p' "$0" | grep '^#' | sed 's/^# \?//'; exit 0 ;;
        :) log_error "-$OPTARG requires an argument"; exit 1 ;;
       \?) log_error "Unknown option: -$OPTARG"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# ── Derived paths ─────────────────────────────────────────────────────────────
# OUT_DIR is bound at ${MNT_OUT} by run_in_container (it is set before any call).
BAM_DIR="${OUT_DIR}/genome_bams"
WORK_DIR="${OUT_DIR}/tmp"
SRA_CACHE="${OUT_DIR}/sra_cache"
QC_DIR="${OUT_DIR}/qc"

# ── Sample→source map ─────────────────────────────────────────────────────────
declare -A SAMPLE_MAP=()      # the =() is required under set -u

# Append rather than overwrite: a re-sequenced sample repeats its id (one row per
# lane) and its reads must be concatenated, not silently dropped.
add_sample() {
    local sid="$1" src="$2"
    if [[ -n "${SAMPLE_MAP[$sid]:-}" ]]; then
        SAMPLE_MAP["$sid"]="${SAMPLE_MAP[$sid]}|${src}"
    else
        SAMPLE_MAP["$sid"]="${src}"
    fi
}

if [[ -n "${MAP_FILE}" ]]; then
    [[ -f "${MAP_FILE}" ]] || { log_error "Map file not found: ${MAP_FILE}"; exit 1; }
    while IFS=$'\t' read -r sid src || [[ -n "$sid" ]]; do
        sid="${sid%%#*}"; sid="${sid//[$'\t\r\n ']/}"
        src="${src%%#*}"; src="${src//[$'\r\n']/}"
        [[ -z "${sid}" ]] && continue
        add_sample "${sid}" "${src:-}"
    done < "${MAP_FILE}"
fi

if [[ -n "${INPUT_DIR}" ]]; then
    [[ -d "${INPUT_DIR}" ]] || { log_error "Not a directory: ${INPUT_DIR}"; exit 1; }
    while IFS= read -r fq; do
        sid=$(basename "${fq}" .fastq.gz); sid="${sid%.fq.gz}"
        add_sample "${sid}" "${fq}"
    done < <(find "${INPUT_DIR}" -maxdepth 1 \( -name "*.fastq.gz" -o -name "*.fq.gz" \) | sort)
fi

for arg in "$@"; do
    if [[ "${arg}" == *:* ]]; then
        add_sample "${arg%%:*}" "${arg#*:}"
    elif [[ "${arg}" =~ ^[SED]RR[0-9]+ ]]; then
        add_sample "${arg}" "${arg}"
    else
        add_sample "${arg}" ""
    fi
done

if [[ ${#SAMPLE_MAP[@]} -eq 0 ]]; then
    log_error "No samples specified. Use -m FILE, -d DIR, accessions, or sample_id:path."
    log_error "Run with -h for usage."
    exit 1
fi

# ── Layout helper ─────────────────────────────────────────────────────────────
# Paired-end iff an R2 exists at this stage. Detected, never assumed, and
# re-checked per stage so the layout cannot drift mid-pipeline.
is_paired() {
    local sample="$1" stage="$2"
    [[ -f "${WORK_DIR}/${sample}_${stage}_2.fastq.gz" ]]
}

# ── Pre-flight ────────────────────────────────────────────────────────────────
preflight() {
    log_step "Pre-flight checks"
    # Checked here, not at source time, so -h works before the reference exists.
    require_organism || exit 1
    require_file "${CONTAINER}" "container image — build it first" || exit 1
    require_file "${GENOME_INDEX_DIR}/SA" "STAR index — run setup_${ORGANISM}_reference.sh" || exit 1
    require_file "${GENOME_GTF}"          "genome GTF — run setup_${ORGANISM}_reference.sh" || exit 1
    if [[ "${SKIP_RRNA}" == false ]]; then
        require_file "${RRNA_INDEX}.1.bt2" "rRNA index — run setup, or pass -R to skip" || exit 1
    fi
    mkdir -p "${BAM_DIR}" "${WORK_DIR}" "${SRA_CACHE}" "${QC_DIR}"

    log_info "Organism   : ${ORGANISM}"
    log_info "Output dir : ${OUT_DIR}"
    log_info "Adapter    : ${ADAPTER}"
    log_info "Min length : ${MIN_LEN} nt"
    log_info "IntronMax  : ${INTRON_MAX}"
    log_info "rRNA filter: $([[ "${SKIP_RRNA}" == true ]] && echo "SKIPPED (-R)" || echo "${RRNA_INDEX}")"
    log_info "Threads    : ${THREADS}"
    log_info "Samples    : ${!SAMPLE_MAP[*]}"
}

# ── Step 1: SRA download (inside the container) ───────────────────────────────
# sra-tools lives in the image, so the host needs nothing but apptainer. Do not
# call prefetch/fasterq-dump on the host: a bare host is the normal case.
step_sra_download() {
    local tag="$1" acc="$2"
    if [[ -f "${WORK_DIR}/${tag}_raw.fastq.gz" || -f "${WORK_DIR}/${tag}_raw_1.fastq.gz" ]]; then
        log_info "[${tag}] raw FASTQ exists, skipping download"
        return 0
    fi

    if [[ ! -f "${SRA_CACHE}/${acc}/${acc}.sra" ]]; then
        log_info "[${tag}] prefetch ${acc}..."
        run_in_container "" "prefetch --max-size 100G --output-directory ${MNT_OUT}/sra_cache ${acc}" || return 1
    fi

    log_info "[${tag}] fasterq-dump ${acc}..."
    # -t scratch is required: temporaries are multi-GB and the default location
    # is often too small.
    run_in_container "" \
        "mkdir -p ${MNT_WORK}/.fq_tmp_${acc} && \
         fasterq-dump --split-3 -e ${THREADS} \
             -O ${MNT_WORK} -t ${MNT_WORK}/.fq_tmp_${acc} \
             ${MNT_OUT}/sra_cache/${acc}/${acc}.sra && \
         rm -rf ${MNT_WORK}/.fq_tmp_${acc}" || return 1

    # --split-3 gives <acc>_1/_2.fastq when paired, <acc>.fastq when single.
    # That is how the layout is determined — nothing else needs to know.
    if [[ -f "${WORK_DIR}/${acc}_1.fastq" && -f "${WORK_DIR}/${acc}_2.fastq" ]]; then
        log_info "[${tag}] paired-end detected"
        run_in_container "" "gzip -f ${MNT_WORK}/${acc}_1.fastq ${MNT_WORK}/${acc}_2.fastq" || return 1
        mv "${WORK_DIR}/${acc}_1.fastq.gz" "${WORK_DIR}/${tag}_raw_1.fastq.gz"
        mv "${WORK_DIR}/${acc}_2.fastq.gz" "${WORK_DIR}/${tag}_raw_2.fastq.gz"
        rm -f "${WORK_DIR}/${acc}.fastq"   # unmated leftovers; not usable as pairs
    elif [[ -f "${WORK_DIR}/${acc}.fastq" ]]; then
        log_info "[${tag}] single-end detected"
        run_in_container "" "gzip -f ${MNT_WORK}/${acc}.fastq" || return 1
        mv "${WORK_DIR}/${acc}.fastq.gz" "${WORK_DIR}/${tag}_raw.fastq.gz"
    else
        log_error "[${tag}] fasterq-dump produced no FASTQ for ${acc}"
        return 1
    fi
}

# ── Step 1b: gather (resolve sources, concatenate lanes) ──────────────────────
step_gather_input() {
    local sample="$1" srcs_str="$2"
    if [[ -f "${WORK_DIR}/${sample}_raw.fastq.gz" || -f "${WORK_DIR}/${sample}_raw_1.fastq.gz" ]]; then
        log_info "[${sample}] raw FASTQ exists, skipping gather"
        return 0
    fi

    local srcs; IFS='|' read -ra srcs <<< "${srcs_str}"
    local r1_parts=() r2_parts=() se_parts=() i=0

    for src in "${srcs[@]}"; do
        i=$((i + 1))
        if [[ "${src}" =~ ^[SED]RR[0-9]+ ]]; then
            step_sra_download "${sample}_part${i}" "${src}" || return 1
            if [[ -f "${WORK_DIR}/${sample}_part${i}_raw_1.fastq.gz" ]]; then
                r1_parts+=("${WORK_DIR}/${sample}_part${i}_raw_1.fastq.gz")
                r2_parts+=("${WORK_DIR}/${sample}_part${i}_raw_2.fastq.gz")
            else
                se_parts+=("${WORK_DIR}/${sample}_part${i}_raw.fastq.gz")
            fi
        elif [[ "${src}" == *,* ]]; then          # local paired-end: r1,r2
            local r1="${src%%,*}" r2="${src#*,}"
            require_file "${r1}" "R1 for ${sample}" || return 1
            require_file "${r2}" "R2 for ${sample}" || return 1
            r1_parts+=("${r1}"); r2_parts+=("${r2}")
        else                                       # local single-end
            require_file "${src}" "FASTQ for ${sample}" || return 1
            se_parts+=("${src}")
        fi
    done

    if [[ ${#r1_parts[@]} -gt 0 && ${#se_parts[@]} -gt 0 ]]; then
        log_error "[${sample}] mixes paired-end and single-end sources — split into two samples"
        return 1
    fi

    # cat on .gz is valid: gzip is a multi-member format and every reader here
    # (zcat, fastp, STAR gunzip -c) handles it. Do not decompress to merge.
    if [[ ${#r1_parts[@]} -gt 0 ]]; then
        [[ ${#r1_parts[@]} -gt 1 ]] && log_info "[${sample}] concatenating ${#r1_parts[@]} paired lanes"
        cat "${r1_parts[@]}" > "${WORK_DIR}/${sample}_raw_1.fastq.gz"
        cat "${r2_parts[@]}" > "${WORK_DIR}/${sample}_raw_2.fastq.gz"
    else
        [[ ${#se_parts[@]} -gt 1 ]] && log_info "[${sample}] concatenating ${#se_parts[@]} lanes"
        cat "${se_parts[@]}" > "${WORK_DIR}/${sample}_raw.fastq.gz"
    fi
}

# ── Step 2: fastp ─────────────────────────────────────────────────────────────
step_fastp() {
    local sample="$1"
    if [[ -f "${WORK_DIR}/${sample}_trimmed.fastq.gz" || -f "${WORK_DIR}/${sample}_trimmed_1.fastq.gz" ]]; then
        log_info "[${sample}] step2 fastp: output exists, skipping"
        return 0
    fi

    local adapter_flag=""
    [[ "${ADAPTER}" != "auto" ]] && adapter_flag="--adapter_sequence ${ADAPTER}"

    log_info "[${sample}] step2 fastp (adapter=${ADAPTER}, min_len=${MIN_LEN})..."
    if is_paired "${sample}" raw; then
        # --detect_adapter_for_pe is REQUIRED for autodetection on paired-end:
        # fastp does not autodetect for PE without it, so "auto" would silently
        # do nothing.
        local pe_detect=""
        [[ "${ADAPTER}" == "auto" ]] && pe_detect="--detect_adapter_for_pe"
        # shellcheck disable=SC2086
        run_in_container "" "fastp \
            --in1 ${MNT_WORK}/${sample}_raw_1.fastq.gz \
            --in2 ${MNT_WORK}/${sample}_raw_2.fastq.gz \
            --out1 ${MNT_WORK}/${sample}_trimmed_1.fastq.gz \
            --out2 ${MNT_WORK}/${sample}_trimmed_2.fastq.gz \
            ${pe_detect} ${adapter_flag} \
            --length_required ${MIN_LEN} \
            --qualified_quality_phred 20 \
            --thread ${THREADS} \
            --json ${MNT_QC}/${sample}_fastp.json \
            --html ${MNT_QC}/${sample}_fastp.html" || return 1
    else
        # shellcheck disable=SC2086
        run_in_container "" "fastp \
            --in1 ${MNT_WORK}/${sample}_raw.fastq.gz \
            --out1 ${MNT_WORK}/${sample}_trimmed.fastq.gz \
            ${adapter_flag} \
            --length_required ${MIN_LEN} \
            --qualified_quality_phred 20 \
            --thread ${THREADS} \
            --json ${MNT_QC}/${sample}_fastp.json \
            --html ${MNT_QC}/${sample}_fastp.html" || return 1
    fi
}

# ── Step 3: rRNA / contaminant filter ─────────────────────────────────────────
# Aligns TO rRNA and keeps what FAILS to align (--un-gz / --un-conc-gz).
step_filter_rrna() {
    local sample="$1"

    if [[ "${SKIP_RRNA}" == true ]]; then
        log_info "[${sample}] step3 rRNA filter skipped (-R) — passing trimmed reads through"
        if is_paired "${sample}" trimmed; then
            ln -f "${WORK_DIR}/${sample}_trimmed_1.fastq.gz" "${WORK_DIR}/${sample}_filtered_1.fastq.gz"
            ln -f "${WORK_DIR}/${sample}_trimmed_2.fastq.gz" "${WORK_DIR}/${sample}_filtered_2.fastq.gz"
        else
            ln -f "${WORK_DIR}/${sample}_trimmed.fastq.gz" "${WORK_DIR}/${sample}_filtered.fastq.gz"
        fi
        return 0
    fi

    if [[ -f "${WORK_DIR}/${sample}_filtered.fastq.gz" || -f "${WORK_DIR}/${sample}_filtered_1.fastq.gz" ]]; then
        log_info "[${sample}] step3 rRNA filter: output exists, skipping"
        return 0
    fi

    log_info "[${sample}] step3 bowtie2 rRNA filter..."
    if is_paired "${sample}" trimmed; then
        # --un-conc-gz expands % to 1 and 2 → matches the 'filtered' stage names.
        run_in_container "" "bowtie2 \
            -x ${MNT_ORG}/contaminant_ref/index/rrna \
            -1 ${MNT_WORK}/${sample}_trimmed_1.fastq.gz \
            -2 ${MNT_WORK}/${sample}_trimmed_2.fastq.gz \
            --un-conc-gz ${MNT_WORK}/${sample}_filtered_%.fastq.gz \
            --no-unal -S /dev/null --threads ${THREADS} \
            2> ${MNT_QC}/${sample}_rrna_stats.txt" || return 1
    else
        run_in_container "" "bowtie2 \
            -x ${MNT_ORG}/contaminant_ref/index/rrna \
            -U ${MNT_WORK}/${sample}_trimmed.fastq.gz \
            --un-gz ${MNT_WORK}/${sample}_filtered.fastq.gz \
            --no-unal -S /dev/null --threads ${THREADS} \
            2> ${MNT_QC}/${sample}_rrna_stats.txt" || return 1
    fi

    local pct; pct=$(grep "overall alignment rate" "${QC_DIR}/${sample}_rrna_stats.txt" 2>/dev/null | awk '{print $1}' || echo "?")
    log_info "[${sample}] step3 rRNA filter: ${pct} of reads were rRNA"
}

# ── Step 4: STAR ──────────────────────────────────────────────────────────────
step_star_align() {
    local sample="$1"
    local out_bam="${BAM_DIR}/${sample}_genome.bam"
    # Gate on .bai: a .bam can exist while truncated; the index only appears
    # after samtools index succeeds.
    [[ -f "${out_bam}.bai" ]] && { log_info "[${sample}] step4 STAR: BAM exists, skipping"; return 0; }

    local reads
    if is_paired "${sample}" filtered; then
        reads="${MNT_WORK}/${sample}_filtered_1.fastq.gz ${MNT_WORK}/${sample}_filtered_2.fastq.gz"
    else
        reads="${MNT_WORK}/${sample}_filtered.fastq.gz"
    fi

    log_info "[${sample}] step4 STAR alignment..."
    # RNA-seq settings. For Ribo-seq add:
    #   --outFilterMultimapNmax 1 --outSAMmultNmax 1 --outFilterMismatchNmax 2
    #   --alignEndsType EndToEnd        (and --alignIntronMax 1 for a CDS ref)
    # --quantMode GeneCounts is free here and emits unstranded/forward/reverse
    # columns — that is how you determine the library's strandedness.
    local prefix="${MNT_BAM}/${sample}_"
    run_in_container "" "ulimit -n 65536 && \
        STAR \
            --runThreadN ${THREADS} \
            --genomeDir ${MNT_ORG}/index/star \
            --readFilesIn ${reads} \
            --readFilesCommand gunzip -c \
            --outFileNamePrefix ${prefix} \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMattributes NH HI AS NM MD \
            --outFilterMismatchNoverLmax 0.04 \
            --alignIntronMin 20 \
            --alignIntronMax ${INTRON_MAX} \
            --alignSJoverhangMin 8 \
            --outFilterType BySJout \
            --quantMode GeneCounts && \
        mv ${prefix}Aligned.sortedByCoord.out.bam ${MNT_BAM}/${sample}_genome.bam && \
        samtools index -@ ${THREADS} ${MNT_BAM}/${sample}_genome.bam" || return 1

    local n; n=$(run_in_container "" "samtools view -c -F 4 ${MNT_BAM}/${sample}_genome.bam")
    log_info "[${sample}] step4 STAR: ${n} aligned reads → ${out_bam}"
}

# ── Cleanup ───────────────────────────────────────────────────────────────────
cleanup_tmp() {
    local sample="$1"      # NOTE: a sample id, never a source path
    [[ "${KEEP_TMP}" == true ]] && return 0
    rm -f "${WORK_DIR}/${sample}"_raw*.fastq.gz \
          "${WORK_DIR}/${sample}"_trimmed*.fastq.gz \
          "${WORK_DIR}/${sample}"_filtered*.fastq.gz \
          "${WORK_DIR}/${sample}"_part*_raw*.fastq.gz
    rm -rf "${SRA_CACHE:?}/${sample}"
    log_info "[${sample}] tmp intermediates removed"
}

# ── Per-sample orchestration ──────────────────────────────────────────────────
run_sample() {
    local sample="$1" srcs="$2"
    log_step "Sample: ${sample}"

    [[ -f "${BAM_DIR}/${sample}_genome.bam.bai" ]] && {
        log_info "[${sample}] already complete — nothing to do"; return 0; }

    if [[ ! -f "${WORK_DIR}/${sample}_filtered.fastq.gz" && ! -f "${WORK_DIR}/${sample}_filtered_1.fastq.gz" ]]; then
        [[ -z "${srcs}" ]] && {
            log_error "[${sample}] no source given and no intermediates to resume from"; return 1; }
        step_gather_input "${sample}" "${srcs}" || return 1
        step_fastp        "${sample}"           || return 1
        step_filter_rrna  "${sample}"           || return 1
    else
        log_info "[${sample}] filtered FASTQ exists — resuming at STAR"
    fi

    step_star_align "${sample}" || return 1
    cleanup_tmp     "${sample}"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    preflight
    local n_ok=0 n_fail=0
    # One sample failing must not abort the rest, despite set -e.
    for sample in $(echo "${!SAMPLE_MAP[@]}" | tr ' ' '\n' | sort); do
        if run_sample "${sample}" "${SAMPLE_MAP[$sample]}"; then
            (( n_ok += 1 ))
        else
            (( n_fail += 1 )); log_error "[${sample}] FAILED"
        fi
    done

    log_step "Done: ${n_ok} OK | ${n_fail} failed"
    log_info "BAMs        : ${BAM_DIR}/"
    log_info "Gene counts : ${BAM_DIR}/<sample>_ReadsPerGene.out.tab"
    log_info "QC reports  : ${QC_DIR}/"
    [[ "${n_fail}" -gt 0 ]] && return 1
    return 0
}

main
