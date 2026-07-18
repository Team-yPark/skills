---
name: organism-reference-setup
description: Acquires organism reference data (genome FASTA, GTF/GFF annotation) from Ensembl, UCSC, NCBI, or GENCODE, stores it under data/<organism>/ with provenance, builds derived artifacts and aligner indexes, and wires the paths into lib/common.sh for downstream scripts. Use when setting up or fixing reference data for an organism — keywords include genome FASTA, GTF, GFF, annotation, reference genome, genome build, assembly, Ensembl, UCSC, goldenPath, NCBI, RefSeq, GENCODE, WormBase, iGenomes, STAR index, bowtie2 index, genomeGenerate, build index, download genome, organism setup, canonical transcript, longest transcript.
---

# Organism Reference Setup

Gets an organism's reference data onto disk in a known layout, verified, with
provenance recorded, and wired into the config that pipeline scripts read.

Runs **before** any preprocessing script can work, and is the thing to fix when
one fails at preflight with a missing index or aligns nothing. Callable on its
own or from a pipeline-building skill (e.g. `seq-download-preprocess`).

## When to use

- Setting up a new organism, or a new assembly of an existing one.
- A pipeline preflight fails on a missing FASTA/GTF/index.
- Alignment "succeeds" but almost nothing maps → suspect a reference mismatch.
- Adding a derived artifact (canonical GTF, rRNA reference, second index).

**Do not use** for read processing — that is `seq-download-preprocess`. This
skill stops once the references exist and `lib/common.sh` points at them.

## Ask before downloading

Reference data is large and slow to fetch; a wrong choice costs hours. Never
guess:

| Question | Why it matters | If unstated |
|---|---|---|
| Organism (scientific name) | picks the source | **ask** |
| Assembly / build | GRCh38 vs GRCh37, WBcel235 vs ce11 — coordinates differ | **ask** |
| Source preference | must match any existing data in the project | infer from what's there, else Ensembl |
| Annotation flavour | full multi-isoform, canonical, or both | **ask** if a footprint assay |
| Release / version | reproducibility; "latest" drifts | **ask**, else pin the current one and record it |

**Never mix sources.** A UCSC FASTA with an Ensembl GTF is the single most
destructive error in this area — see Pitfalls.

If the project already has reference data, match its conventions rather than
introducing a second style. Check `lib/common.sh` and `data/` first.

## Layout

One directory per organism+assembly, self-describing and swappable:

```
data/<organism>/
├── MANIFEST.tsv          # file, url, retrieved_utc, md5 — provenance, written on every fetch
├── config.sh             # exports the paths; sourced by lib/common.sh
├── genome.fa             # + genome.fa.fai
├── genes.gtf             # full, multi-isoform
├── genes.longest_tx.gtf  # derived: canonical backbone
├── contaminant_ref/
│   ├── rrna.fa
│   └── index/rrna.*.bt2
└── index/star/           # sentinel: index/star/SA
```

Use a stable, lowercase organism key (`c_elegans`, `h_sapiens`, `m_musculus`).
If several assemblies coexist, key on both: `c_elegans_WBcel235`.

## Source selection

| Source | Best for | Seqnames | Notes |
|---|---|---|---|
| Ensembl | vertebrates | `1`, `MT` | `primary_assembly` + `dna_sm`; GTF and FASTA agree by construction |
| Ensembl Genomes / ParaSite | invertebrates, plants, fungi, protists | `1`/`I`/roman | separate FTP tree and release numbering from main Ensembl |
| GENCODE | human, mouse | `chr1`, `chrM` | richest annotation; FASTA headers use `\|` separators that break some parsers |
| UCSC (goldenPath) | browser-aligned work | `chr1`, `chrM` | genome is easy, matching annotation is fiddlier |
| NCBI Datasets | organisms absent elsewhere; anything RefSeq | `NC_…` accessions | `datasets` CLI; ships checksums and a file catalogue |
| iGenomes-style bundles | — | varies | **avoid**: annotations often years stale |

Pick **one** source for FASTA and GTF and take both from the same release.

### NCBI Datasets quick path

```bash
datasets download genome accession GCF_000001405.40 --include genome,gtf
unzip -q ncbi_dataset.zip -d ncbi_out && (cd ncbi_out && md5sum -c md5sum.txt)
```

`--include` defaults to `genome` **alone** — without `,gtf` you get no
annotation. Files land under `ncbi_dataset/data/<accession>/` uncompressed, with
a stable `genomic.gtf` but an interpolated `*_genomic.fna` name; glob it or read
`dataset_catalog.json`. Copy both to `genome.fa`/`genes.gtf` in the layout above
and record the accession in `MANIFEST.tsv`. Full flag list and package layout in
`reference.md`.

### Which FASTA

- **`primary_assembly`, not `toplevel`.** Toplevel includes haplotypes and
  padded scaffolds; it bloats the index and creates multi-mapping against
  sequence that is the same locus twice. If `primary_assembly` is absent for the
  organism, `toplevel` is the intended file.
- **`dna_sm` (soft-masked)** is the usual choice for alignment: masking is
  lowercase, so aligners that ignore case are unaffected, and tools that use it
  can. `dna_rm` (hard-masked, N's) destroys sequence — do not use it for
  alignment.

## Core blocks

### 1. Fetch with verification and provenance

```bash
MANIFEST="${ORG_DIR}/MANIFEST.tsv"
[[ -f "${MANIFEST}" ]] || printf 'file\turl\tretrieved_utc\tmd5\n' > "${MANIFEST}"

# Download once, verify, record. Writes .part and renames on success so an
# interrupted transfer never looks like a finished file.
#
# Reference genomes are 100s of MB to GBs and public FTP is often slow (a few
# hundred KB/s is normal for Ensembl), so a single fetch can run for an hour.
# That drives two flags people habitually get wrong — see the notes below.
fetch() {
    local url="$1" dest="$2" md5_expected="${3:-}"
    if [[ -s "${dest}" ]]; then
        log_info "exists, skipping: $(basename "${dest}")"
        return 0
    fi
    mkdir -p "$(dirname "${dest}")"

    local total_mb=""
    total_mb=$(curl -sfI --max-time 30 "${url}" \
               | awk 'tolower($1)=="content-length:"{printf "%.0f", $2/1048576}') || true

    if [[ -s "${dest}.part" ]]; then
        local have_mb=$(( $(stat -c %s "${dest}.part") / 1048576 ))
        log_info "resuming $(basename "${dest}") at ${have_mb}${total_mb:+/${total_mb}} MB..."
    else
        log_info "fetching $(basename "${dest}")${total_mb:+ (${total_mb} MB)} — this can take a while"
    fi

    curl -fL --progress-bar --retry 5 --retry-delay 5 --retry-all-errors \
         -C - -o "${dest}.part" "${url}" \
        || { log_error "download failed: ${url}"
             log_error "  partial kept at ${dest}.part — re-run to resume"
             return 1; }

    if [[ -n "${md5_expected}" ]]; then
        local md5_actual
        md5_actual=$(md5sum "${dest}.part" | awk '{print $1}')
        if [[ "${md5_actual}" != "${md5_expected}" ]]; then
            log_error "checksum mismatch for $(basename "${dest}")"
            log_error "  expected ${md5_expected}"
            log_error "  actual   ${md5_actual}"
            # A corrupt .part must go: resuming it would append to garbage.
            rm -f "${dest}.part"; return 1
        fi
        log_info "  checksum OK"
    fi
    mv "${dest}.part" "${dest}"
    printf '%s\t%s\t%s\t%s\n' "$(basename "${dest}")" "${url}" \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(md5sum "${dest}" | awk '{print $1}')" \
        >> "${MANIFEST}"
}
```

Four things here are load-bearing:

**`-f`** — without it an FTP/HTTP error page is saved as your genome and fails
much later, incomprehensibly.

**No `-s`.** A silent hour-long transfer is indistinguishable from a hang, and
will be reported as "the download is broken". `--progress-bar` writes to stderr
and costs nothing. Print the expected size up front too.

**`-C -` and keep the `.part` on transfer failure.** Public genome FTP drops
connections. Deleting the partial throws away 45 minutes of transfer and the next
attempt starts from zero. Ensembl, UCSC and NCBI all send `Accept-Ranges: bytes`
— check with `curl -I` if unsure. The one case where the `.part` *must* be
deleted is a checksum mismatch: resuming a corrupt file appends to garbage.

**`MANIFEST.tsv`** is what makes the download reproducible — a bare FASTA on disk
cannot tell you which release it is.

Ensembl publishes a `CHECKSUMS` file per directory, NCBI an `md5checksums.txt`.
Fetch it and pass the value through rather than skipping verification.

### 2. Decompress (keep the archive out of the way)

```bash
gunzip -c "${ORG_DIR}/genome.fa.gz" > "${ORG_DIR}/genome.fa"
```

Many tools accept `.gz`, but STAR `--genomeFastaFiles` does not. Decompress once
at setup rather than per run.

### 3. Verify FASTA/GTF agreement — do this before building anything

```bash
check_seqname_concordance() {
    local fa="$1" gtf="$2"
    local fa_n gtf_n shared
    fa_n=$(grep '^>' "$fa" | sed 's/^>\([^[:space:]]*\).*/\1/' | sort -u)
    gtf_n=$(awk '$0 !~ /^#/ && NF>2 {print $1}' "$gtf" | sort -u)
    shared=$(comm -12 <(printf '%s\n' "$fa_n") <(printf '%s\n' "$gtf_n") | grep -c . || true)

    if [[ "${shared}" -eq 0 ]]; then
        log_error "FASTA and GTF share NO sequence names — the index would align nothing."
        log_error "  FASTA: $(printf '%s\n' "$fa_n" | head -3 | tr '\n' ' ')"
        log_error "  GTF  : $(printf '%s\n' "$gtf_n" | head -3 | tr '\n' ' ')"
        log_error "  Likely a UCSC (chr1) vs Ensembl (1) mismatch. Use one source for both."
        return 1
    fi
    log_info "seqname concordance OK: ${shared} shared sequence name(s)"
}
```

This is the highest-value check in the skill. Nothing downstream reports a
seqname mismatch: STAR builds an index happily, then aligns ~nothing, and the
error surfaces as "my data is bad".

### 4. Derived artifacts — idempotent, sentinel-gated

```bash
# Canonical backbone: one transcript per gene.
if [[ -f "${GENOME_GTF_LONGEST}" ]]; then
    log_info "canonical GTF exists — skipping (delete it to rebuild)"
else
    log_step "Filtering GTF to one transcript per gene"
    "${PYTHON}" "${FILTER_SCRIPT}" --gtf "${GENOME_GTF}" --out "${GENOME_GTF_LONGEST}"
fi

# STAR index — gate on the sentinel, not the directory.
if [[ -f "${STAR_INDEX_DIR}/SA" ]]; then
    log_info "STAR index exists — skipping (delete the directory to rebuild)"
else
    log_step "Building STAR index"
    mkdir -p "${STAR_INDEX_DIR}"
    run_in_container "" \
        "STAR --runMode genomeGenerate \
              --runThreadN ${THREADS} \
              --genomeDir ${MNT_DATA}/${ORGANISM}/index/star \
              --genomeFastaFiles ${MNT_DATA}/${ORGANISM}/genome.fa \
              --sjdbGTFfile ${MNT_DATA}/${ORGANISM}/genes.gtf \
              --genomeSAindexNbases ${SA_IDX}"
fi

# bowtie2 contaminant index — sentinel is the first .bt2 file.
if [[ -f "${RRNA_INDEX}.1.bt2" ]]; then
    log_info "rRNA index exists — skipping"
else
    run_in_container "" \
        "bowtie2-build --threads ${THREADS} \
             ${MNT_DATA}/${ORGANISM}/contaminant_ref/rrna.fa \
             ${MNT_DATA}/${ORGANISM}/contaminant_ref/index/rrna"
fi
```

**Gate on a sentinel file, never on the directory.** A killed `genomeGenerate`
leaves the directory populated but unusable; `[[ -d ... ]]` then skips the
rebuild forever and every downstream run fails confusingly. `SA` for STAR,
`.1.bt2` for bowtie2, `.fai` for samtools faidx.

**`--genomeSAindexNbases` must shrink for small references:**

```bash
total_len=$(awk '/^>/{next}{t+=length($0)}END{print t}' "${REF_FA}")
SA_IDX=$(python3 -c "import math; print(min(14, int(math.log2(${total_len})/2 - 1)))")
```

Leaving the default of 14 on a small genome or a transcript library makes STAR
allocate absurd memory or fail outright.

`--sjdbOverhang` is baked in at build time and cannot be changed later — see
`reference.md`.

### 5. Wire it into the config

Each organism directory describes itself, so switching organism is one variable:

```bash
# data/<organism>/config.sh — generated by this skill
ORG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENOME_FA="${ORG_DIR}/genome.fa"
GENOME_GTF="${ORG_DIR}/genes.gtf"
GENOME_GTF_LONGEST="${ORG_DIR}/genes.longest_tx.gtf"
GENOME_INDEX_DIR="${ORG_DIR}/index/star"
RRNA_FA="${ORG_DIR}/contaminant_ref/rrna.fa"
RRNA_INDEX="${ORG_DIR}/contaminant_ref/index/rrna"
INTRON_MAX=25000        # organism-specific — see reference.md
```

`lib/common.sh` then selects one:

```bash
ORGANISM="${ORGANISM:-<default_organism>}"
ORG_CONFIG="${DATA_DIR}/${ORGANISM}/config.sh"
if [[ -f "${ORG_CONFIG}" ]]; then
    source "${ORG_CONFIG}"
else
    log_error "No reference config for '${ORGANISM}': ${ORG_CONFIG}"
    log_error "Run the reference setup script for this organism first."
    return 1 2>/dev/null || exit 1
fi
```

This is the "link" step. Prefer it to editing hardcoded paths in `common.sh`:
adding an organism becomes a new directory rather than a diff, `ORGANISM=x ./run.sh`
switches everything at once, and nothing silently half-switches.

Keep organism-specific *parameters* (like `INTRON_MAX`) in `config.sh` too — they
belong with the organism, not scattered across scripts.

## Pitfalls

1. **Mixing sources.** UCSC FASTA (`chr1`) + Ensembl GTF (`1`) → index aligns
   nothing, no error. Block 3 catches it; run it before every index build.
2. **`toplevel` instead of `primary_assembly`.** Haplotype scaffolds duplicate
   loci, inflating multi-mapping and index size. Reads that should map uniquely
   quietly become multi-mappers and get filtered out.
3. **Gating a rebuild on the directory rather than a sentinel.** A half-built
   index is a populated directory. `[[ -d ]]` skips forever.
4. **"Latest" as a version.** An unpinned release makes results irreproducible
   and silently changes under you. Pin it, record it in `MANIFEST.tsv`.
5. **No `-f` on curl.** An HTTP error page saved as `genome.fa` fails far away
   from the cause.
5b. **A silent download.** `curl -s` on an 800 MB file over a 200 KB/s link means
   an hour of no output; users reasonably conclude it is broken and kill it.
   Show progress and the expected size.
5c. **Deleting the `.part` on a dropped connection.** Without `-C -` and a kept
   partial, every retry restarts from zero — on a slow link the download may
   never finish. Delete the partial only on a checksum mismatch.
6. **Rebuilding an index without rebuilding what depends on it.** BAMs aligned
   to the old index are not comparable to new ones. When the reference changes,
   downstream outputs are stale — say so explicitly.
7. **Hard-masked (`dna_rm`) FASTA for alignment.** Repeats become N; reads over
   them vanish. Use `dna_sm`.

## Verification

Cheap checks, all before any long build:

```bash
grep -c '^>' "${GENOME_FA}"                       # sequences present?
awk '$0!~/^#/ && NF>2' "${GENOME_GTF}" | wc -l    # GTF non-empty?
check_seqname_concordance "${GENOME_FA}" "${GENOME_GTF}"
awk '$0!~/^#/ && $3=="exon"' "${GENOME_GTF}" | wc -l   # exon rows exist?
```

After building, confirm the sentinels exist (`index/star/SA`,
`contaminant_ref/index/rrna.1.bt2`, `genome.fa.fai`) and that `config.sh` sources
cleanly with every path resolving:

```bash
( source data/<organism>/config.sh
  for v in GENOME_FA GENOME_GTF GENOME_INDEX_DIR; do
      [[ -e "${!v}" ]] && echo "OK   $v=${!v}" || echo "MISS $v=${!v}"
  done )
```

Index builds are long (tens of minutes to hours) and memory-hungry — a
human-sized STAR index needs ~38 GB. Print the command and let the user run it
rather than launching it yourself.

## Reference

`reference.md` — per-source URL patterns, canonical-transcript sources,
organism-specific parameters, rRNA reference construction, and disk/memory sizing.
