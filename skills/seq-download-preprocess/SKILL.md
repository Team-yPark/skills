---
name: seq-download-preprocess
description: Builds sequencing data download and preprocessing pipeline scripts (SRA/GEO download → adapter trim → contaminant filter → alignment → BAM) as idempotent, resumable bash. Use when writing, extending, or debugging a script that handles sequencing data, RNA-seq, Ribo-seq, ribosome profiling, GEO/SRA raw data, FASTQ download, or read preprocessing — keywords include GEO, GSE, SRR/ERR/DRR accessions, prefetch, fasterq-dump, fastp, cutadapt, Trim Galore, bowtie2, SortMeRNA, STAR, rRNA depletion, adapter trimming, samplesheet, strandedness, UMI, raw data download, preprocessing pipeline, nf-core.
---

# Sequencing Download + Preprocessing Pipeline Builder

Assembles a preprocessing pipeline script: **one `run_<order>_<topic>.sh`
orchestrator that sources `lib/common.sh`**, resolves samples from several input
forms, and runs a chain of idempotent step functions, each skipping when its
output already exists.

Two working, tested files ship with this skill — start from them rather than
retyping:

| Asset | What it is |
|---|---|
| `assets/common.sh` | `lib/common.sh` baseline: logging, guards, container wrapper, mounts, organism selector |
| `assets/pipeline_template.sh` | the full orchestrator, paired-end aware, verified end to end |
| `assets/make_test_organism.py` | synthetic organism + reads, so you can actually run the thing (see Verification) |

The blocks below explain the parts that carry judgment. The template is the code.

## When to use

- A script to download and preprocess a GEO/SRA dataset.
- Adding or changing a step in an existing preprocessing pipeline.
- Adapting a pipeline to a different assay or organism.

**Do not use** for downstream analysis (differential expression, ORF calling,
pause scores, metagene/p-site work) — this skill stops at the aligned BAM.

**Consider not writing bash at all** for a standard workflow on a well-annotated
organism where Nextflow is available: `nf-core/rnaseq` and `nf-core/riboseq` are
maintained and already handle UMIs, strandedness, and lane merging. Bespoke bash
earns its keep for non-standard references, unusual assays, or an existing
container setup. Say this once, then build what they asked for (`nf-core.md`).

## Ask before writing

Never guess these. Get them from the user or from a file in the project:

| Question | Why it matters | If unstated |
|---|---|---|
| Organism + genome build | index paths, `--alignIntronMax` | **ask** |
| Assay (Ribo-seq / RNA-seq / other) | length window, aligner flags | **ask** |
| 3' adapter sequence | wrong adapter silently destroys yield | **ask**, or `auto` for fastp |
| Single- or paired-end | `--in1/--in2`, `--split-3` handling | infer from SRA, else ask |
| Input form | accessions / local FASTQ / mixed | infer from what they gave |
| Multi-lane samples? | re-sequenced samples must be **concatenated**, not overwritten | inspect the map for repeated ids |
| UMIs in the library? | without dedup, PCR duplicates inflate counts | **ask** if the kit is unknown |
| Strandedness (RNA-seq) | wrong value silently halves or zeroes counts | **ask** |

`--alignIntronMax` is the classic silent-corruption knob: a compact genome needs
a small value, and STAR's `1000000` default lets reads bridge unrelated genes
with no error. See `reference.md`.

UMI extraction and strandedness inference are **not** part of the block library
below. If the user needs either, say so rather than generating a script that
quietly ignores them — `nf-core.md` covers what a real implementation involves.

## Architecture

```
lib/common.sh                  # paths, logging, container wrapper, guards — SOURCE, don't duplicate
lib/<domain>.sh                # optional: reusable step groups
run_<order>_<topic>.sh         # orchestrator: options → sample map → preflight → steps → summary
```

`lib/common.sh` provides `log_info`, `log_error`, `log_step`, `require_file`,
`already_done`, `run_in_container`, plus `THREADS`, `CONTAINER`, `DATA_DIR`,
`RESULTS_DIR`, the `MNT_*` mounts, and the organism selector that sources
`data/<organism>/config.sh`. **There is no `log_warn`** — do not call one.

**Everything the pipeline runs must be in the container image**, including
sra-tools. A host with no bioinformatics tools installed is the normal case, so a
step that shells out to `prefetch` or `fastp` on the host is a step that does not
run. The only host requirement should be apptainer.

**Mounts are a closed set.** Paths inside a `run_in_container` command must be
`${MNT_DATA}`, `${MNT_RESULTS}`, `${MNT_OUT}` (or its `MNT_WORK` / `MNT_QC` /
`MNT_BAM` children), or `${MNT_ORG}`. Two failure modes, both silent-ish:

- Passing a **host path** — "file not found" for a file that plainly exists.
- Using a mount the library does not define — under `set -u` the script dies with
  `MNT_FOO: unbound variable` at the first container call. If you need a new
  mount, define it in `common.sh` *and* bind it.

`${OUT_DIR}` is bound automatically at `${MNT_OUT}`, because `-o` routinely
points outside `RESULTS_DIR` and an unbound output directory is invisible in the
container.

If a project defines both `run_in_container <binds> <cmd>` (two args) and a local
`run_container <cmd>` (one arg), pick one and use it consistently. Prefer the
library version; define a local wrapper only when the bind set is script-specific.

Assemble in block order: header → source library → defaults + `getopts` →
sample map → preflight → step functions → orchestration + `main`.

## Core blocks

### 1. Header + self-documenting `-h`

The header block **is** the help text, so it cannot drift from `-h` output.

```bash
#!/usr/bin/env bash
# run_<order>_<topic>.sh
#
# <One-line purpose.>
#
# Pipeline steps per sample:
#   1. [SRA only] prefetch + fasterq-dump  acc      → tmp/<s>_raw.fastq.gz
#   2. fastp                               raw      → tmp/<s>_trimmed.fastq.gz
#   3. bowtie2 contaminant filter          trimmed  → tmp/<s>_filtered.fastq.gz
#   4. STAR align                          filtered → <out>/<s>_genome.bam
#
# Each step checks for its output before running — leave any intermediate file
# in place to resume from that point.
#
# Options:
#   -o DIR    Output directory (default: results)
#   -a SEQ    3' adapter, or "auto" for fastp detection (default: auto)
#   -l INT    Min read length after trim (default: 22)
#   -L INT    Max read length after trim (default: 36)
#   -t INT    Threads (default: 16)
#   -k        Keep tmp intermediates
#   -h        Show this help
#
# Examples:
#   ./run_<order>_<topic>.sh -o results/study1 SRR12345678 SRR12345679
#   ./run_<order>_<topic>.sh -m data/sample_map.tsv

set -euo pipefail
```

Help handler — the `sed` range stops at `set `, so only the header prints:

```bash
h) sed -n '2,/^set /p' "$0" | grep '^#' | sed 's/^# \?//'; exit 0 ;;
```

Do **not** use `grep '^#' "$0"` alone: it dumps every inline comment in the file,
not just the header.

### 2. Sourcing the library + resolving tools

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
cd "${ROOT_DIR}"
source "${ROOT_DIR}/lib/common.sh"
```

This assumes `lib/` is a **sibling of the script's parent** (script in
`scripts/`, library in `lib/`). If the script sits *next to* `lib/`, use
`source "${SCRIPT_DIR}/lib/common.sh"`. Get this wrong and the script dies at
line 1 with no usable error — verify the path resolves before shipping.

Never hardcode interpreter or toolkit paths. Resolve them:

```bash
command -v fastp &>/dev/null && FASTP="fastp" || FASTP="${ROOT_DIR}/data/fastp/fastp"
PREFETCH="";    command -v prefetch     &>/dev/null && PREFETCH="prefetch"
FASTERQDUMP=""; command -v fasterq-dump &>/dev/null && FASTERQDUMP="fasterq-dump"
GZIP_CMD="gzip"; command -v pigz &>/dev/null && GZIP_CMD="pigz -p ${THREADS}"
```

### 3. Defaults + option parsing

```bash
OUT_DIR="${ROOT_DIR}/results"
ADAPTER="auto"
MIN_LEN=22
MAX_LEN=36
KEEP_TMP=false
MAP_FILE=""
INPUT_DIR=""

while getopts ":o:a:l:L:t:km:d:h" opt; do
    case $opt in
        o) OUT_DIR="$OPTARG" ;;
        a) ADAPTER="$OPTARG" ;;
        l) MIN_LEN="$OPTARG" ;;
        L) MAX_LEN="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;      # THREADS comes from common.sh
        k) KEEP_TMP=true ;;
        m) MAP_FILE="$OPTARG" ;;
        d) INPUT_DIR="$OPTARG" ;;
        h) sed -n '2,/^set /p' "$0" | grep '^#' | sed 's/^# \?//'; exit 0 ;;
        :) log_error "-$OPTARG requires an argument"; exit 1 ;;
       \?) log_error "Unknown option: -$OPTARG"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```

Validate enum-style options immediately after parsing:

```bash
[[ "${ALIGN_MODE}" == "cds" || "${ALIGN_MODE}" == "genome" ]] || {
    log_error "-M must be 'cds' or 'genome'"; exit 1; }
```

### 4. Sample→source map

The most reusable block. Accepts four input forms. `SAMPLE_MAP[id]` holds a
`|`-separated source list: accessions, FASTQ paths, or `""` meaning *resume from
existing intermediates*.

```bash
declare -A SAMPLE_MAP=()      # the =() is required — see notes below

# Append rather than overwrite: a re-sequenced sample repeats its id (one row
# per lane) and its reads must be concatenated, not silently dropped.
add_sample() {
    local sid="$1" src="$2"
    if [[ -n "${SAMPLE_MAP[$sid]:-}" ]]; then
        SAMPLE_MAP["$sid"]="${SAMPLE_MAP[$sid]}|${src}"
    else
        SAMPLE_MAP["$sid"]="${src}"
    fi
}

# -m FILE : TSV <sample_id>\t<accession_or_path>, '#' comments ignored
if [[ -n "${MAP_FILE}" ]]; then
    [[ -f "${MAP_FILE}" ]] || { log_error "Map file not found: ${MAP_FILE}"; exit 1; }
    while IFS=$'\t' read -r sid src || [[ -n "$sid" ]]; do
        sid="${sid%%#*}"; sid="${sid//[$'\t\r\n ']/}"
        src="${src%%#*}"; src="${src//[$'\r\n']/}"
        [[ -z "${sid}" ]] && continue
        add_sample "${sid}" "${src:-}"
    done < "${MAP_FILE}"
fi

# -d DIR : every *.fastq.gz in DIR; sample id = filename minus extension
if [[ -n "${INPUT_DIR}" ]]; then
    [[ -d "${INPUT_DIR}" ]] || { log_error "Not a directory: ${INPUT_DIR}"; exit 1; }
    while IFS= read -r fq; do
        sid=$(basename "${fq}" .fastq.gz); sid="${sid%.fq.gz}"
        add_sample "${sid}" "${fq}"
    done < <(find "${INPUT_DIR}" -maxdepth 1 \( -name "*.fastq.gz" -o -name "*.fq.gz" \) | sort)
fi

# positional: SRR/ERR/DRR accession | sample_id:path | bare id (resume)
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
```

Three details that look cosmetic and are not:

**`declare -A SAMPLE_MAP=()`, not bare `declare -A SAMPLE_MAP`.** Under `set -u`,
`${#SAMPLE_MAP[@]}` on an array declared without an element list is an unbound-
variable error (still true on bash 5.2), so the no-arguments path dies with
`SAMPLE_MAP: unbound variable` instead of the intended help message.

**`add_sample`, not `SAMPLE_MAP[$sid]="$src"`.** Direct assignment overwrites, so
three lanes of one sample collapse to whichever row came last — two-thirds of the
data gone, silently. The one-row-per-lane layout is standard (nf-core samplesheets
repeat the `sample` column per lane precisely so reads get concatenated).

**Keep the `\( ... -o ... \)` parens in `find`** — without them the `-o` branch
escapes the intended grouping.

### 5. Preflight

Check every external dependency **before** the first sample, so a missing index
fails in seconds rather than after an hour of downloading.

```bash
preflight() {
    log_step "Pre-flight checks"
    require_file "${CONTAINER}"      "container image"                   || exit 1
    require_file "${STAR_INDEX}/SA"  "STAR genome index (${STAR_INDEX})"  || exit 1
    require_file "${RRNA_IDX}.1.bt2" "rRNA bowtie2 index (${RRNA_IDX})"   || exit 1
    mkdir -p "${BAM_DIR}" "${TMP_DIR}" "${SRA_CACHE}" "${QC_DIR}"
    log_info "Output dir   : ${OUT_DIR}"
    log_info "Adapter      : ${ADAPTER}"
    log_info "Length range : ${MIN_LEN}–${MAX_LEN} nt"
    log_info "Threads      : ${THREADS}"
    log_info "Samples      : ${!SAMPLE_MAP[*]}"
}
```

Echoing resolved parameters is not decoration — it is how a wrong adapter or
index gets caught before it silently ruins the run.

### 6. Step contract

Every step function follows this shape:

```bash
step_<name>() {
    local sample="$1"
    local inp="${TMP_DIR}/${sample}_<prev>.fastq.gz"
    local out="${TMP_DIR}/${sample}_<this>.fastq.gz"

    if [[ -f "${out}" ]]; then
        log_info "[${sample}] step<N> <name>: output exists, skipping"
        return 0
    fi
    require_file "${inp}" "<prev> for ${sample} (run step<N-1> first)" || return 1

    log_info "[${sample}] step<N> <name>..."
    <tool> ... -o "${out}" "${inp}" || return 1

    local n; n=$(zcat "${out}" | awk 'NR%4==1' | wc -l)
    log_info "[${sample}] step<N> <name>: ${n} reads"
}
```

Rules, all load-bearing:

- The **skip check uses this step's own output**, not a downstream file.
- For BAMs, gate on `.bam.bai` — a `.bam` can exist while truncated; the index
  only appears after `samtools index` succeeds.
- Declare `local n` on its own line before `n=$(...)`. Combining them makes
  `local` swallow the command's exit status under `set -e`.
- Return non-zero on failure; let the caller tally it.

### 7-10. Download, trim, filter, align

These four steps are long, mutually dependent, and paired-end aware. They live as
one **working, tested script** at `assets/pipeline_template.sh` — read it and
adapt, rather than reassembling them from prose here. It covers:

| Step | Notes |
|---|---|
| `step_sra_download` | prefetch + fasterq-dump **inside the container** (see below) |
| `step_gather_input` | resolves the `\|`-separated source list; concatenates lanes; rejects PE/SE mixing |
| `step_fastp` | adapter trim; `--detect_adapter_for_pe` required for PE autodetect |
| `step_filter_rrna` | bowtie2, keeps reads that FAIL to align; `--un-conc-gz %` for PE |
| `step_star_align` | gates on `.bai`; `--quantMode GeneCounts` |
| `run_sample` / `main` | resume logic and the per-sample tally |

Three things in it that are easy to get wrong:

**Run the SRA tools inside the container.** A bare host with no SRA toolkit is
the normal case, not the exception. Putting sra-tools in the image reduces the
host requirement to apptainer alone. Do not call `prefetch`/`fasterq-dump`
directly.

**Detect the layout; never assume it.** `fasterq-dump --split-3` emits
`<acc>_1/_2.fastq` for paired and `<acc>.fastq` for single. That is the signal.
Everything downstream asks `is_paired <sample> <stage>`, which tests for an R2 at
that stage:

```bash
is_paired() {
    local sample="$1" stage="$2"
    [[ -f "${WORK_DIR}/${sample}_${stage}_2.fastq.gz" ]]
}
```

Re-checking per stage rather than caching one flag means the layout cannot drift
mid-pipeline, and a sample that mixes PE and SE sources is rejected rather than
half-processed.

**`--quantMode GeneCounts` is free and answers strandedness.** You cannot infer
strandedness in the pipeline, but STAR emits `ReadsPerGene.out.tab` with
unstranded/forward/reverse columns at no extra cost. Compare the column totals to
determine the library's strandedness instead of guessing.
## Pitfalls

All observed in real pipeline code. All silent — none errors at the point of the
mistake.

1. **A step reading a filename no step writes.** The symptom appears far from the
   cause. When adding or renaming a step, trace the literal filenames end to end.
   Rarely-exercised branches (an alternate alignment mode) are where this hides.
2. **`declare -A MAP` without `=()`.** Unbound-variable death under `set -u` on
   the no-arguments path — the first thing a new user does.
3. **Overwriting instead of appending in the sample map.** Multi-lane samples
   lose all but the last lane. Use `add_sample`.
4. **Header text drifting from actual defaults.** The header *is* the help text,
   so the only defence is editing both together — check them against each other
   before shipping.
5. **Cleanup functions taking the wrong argument.** A `cleanup_*` helper treating
   `$1` as a sample id, called with a source path, yields `rm -rf "${CACHE}/<path>"`.
   Cleanup code deletes things: check its arguments twice.
6. **Hardcoded absolute paths** to toolkits or interpreters. Resolve with
   `command -v` plus a documented fallback — or better, put the tool in the image.
7. **Assuming a tool exists on the host.** A bare host is normal. Anything not in
   the container image is a step that does not run.
8. **An output directory the container cannot see.** `-o` outside `RESULTS_DIR`
   is invisible unless bound; `common.sh` binds `${OUT_DIR}` at `${MNT_OUT}` for
   this reason.
9. **Referencing an `MNT_*` mount the library does not define.** Death by
   unbound variable at the first container call, under `set -u`.
10. **`auto` adapter detection on paired-end without `--detect_adapter_for_pe`.**
    fastp does not autodetect for PE otherwise, so "auto" silently does nothing.

## Verification

### Static (seconds)

```bash
bash -n <script>                          # 1. parses
shellcheck <script> 2>/dev/null || true   # 2. if available
./<script> -h                             # 3. help renders, header only
./<script>                                # 4. exits 1 with the "no samples" error
```

### End-to-end on a synthetic organism (under a minute) — do this

Static checks prove the script parses, not that it works. Every pitfall in this
skill survives `bash -n`. A real dataset takes hours, so build a fake one:

```bash
python3 assets/make_test_organism.py --outdir data/testorg --fastq-dir testfq
ORGANISM=testorg ./scripts/setup_<organism>_reference.sh -t 8    # tiny genome: seconds
ORGANISM=testorg ./scripts/<script>.sh -m testfq/samples.tsv -o /tmp/testout -t 8
```

The generator makes a 120 kb genome with one annotated gene plus one rRNA gene,
and reads drawn from that gene so they genuinely align. Assert:

| Check | Correct result | What a failure means |
|---|---|---|
| Exit status | `3 OK \| 0 failed` | — |
| `pe_sample` paired records | **800** (2 lanes × 200 pairs) | 400 → the sample map overwrites lanes |
| `rrna_sample` | ~100% rRNA, **0** aligned | 0% → filter polarity inverted (keeping aligned reads) |
| `se_sample` | aligns, 0% rRNA | — |
| BAM + `.bai` per sample | both present | — |
| Re-run | all samples skipped | resume/idempotency broken |
| `ReadsPerGene.out.tab` | col3 ≫ col4 | strandedness readout wrong |

```bash
apptainer exec <image> samtools view -c -f 1 /tmp/testout/genome_bams/pe_sample_genome.bam   # want 800
```

Then delete `data/testorg`, `testfq`, and the output — it is scaffolding.

This catches the whole Pitfalls list: a broken filename chain, lane loss,
inverted filters, a PE branch nobody exercised. It costs a minute and it is the
difference between "the script parses" and "the script works".

### What not to do

Do not launch a real download or alignment to test — those are hours long and the
user's to start. Print the command and let them run it.

**Verify the artifact, not the exit code.** A build or download backgrounded
behind a wrapper reports the *wrapper's* status; a `0` can mean "successfully
started". Check that the file exists and is what you expect before reporting
success.

## Reference

- `reference.md` — adapters, per-assay presets, `alignIntronMax`, STAR/bowtie2
  flag rationale, contaminant-filter choices, SRA/GEO notes, index building.
- `nf-core.md` — samplesheet conventions, strandedness, UMIs, rRNA-removal tool
  choice, canonical-annotation backbone, and when to use nf-core instead.
- `assets/common.sh` — `lib/common.sh` baseline to copy.
- `assets/pipeline_template.sh` — the full working orchestrator; adapt this.
- `assets/make_test_organism.py` — synthetic organism for end-to-end testing.

**Reference data is a prerequisite, not part of this skill.** If the genome
FASTA, GTF, or an index is missing, or alignment succeeds but nothing maps, use
the `organism-reference-setup` skill — it downloads organism data into
`data/<organism>/` and wires the paths into `lib/common.sh`.
