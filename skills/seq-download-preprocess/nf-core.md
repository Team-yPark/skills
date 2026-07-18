# seq-download-preprocess — nf-core conventions

Loaded only when `SKILL.md` points here. Community conventions and tool choices
worth borrowing when hand-writing a pipeline, plus when to stop hand-writing one.

Distilled from `nf-core/riboseq` (1.2.0) and `nf-core/rnaseq` (3.14.0) usage
docs. Versions move; treat specifics as a starting point and check upstream when
it matters.

## When to use nf-core instead of bash

Reach for `nf-core/rnaseq` or `nf-core/riboseq` when the work is a standard
workflow on a well-annotated organism and Nextflow is available. They are
maintained and tested, and they already handle the things hand-rolled scripts
usually get wrong: multi-lane merging, strandedness inference, UMI dedup, FASTQ
validation, resumability, and per-process resource retry.

Hand-written bash earns its keep when:

- the reference is non-standard (custom CDS/transcript library, unusual flank);
- the assay is unusual, or the protocol demands specific flags end to end;
- there is an existing container-based setup to fit into;
- Nextflow is unavailable, or the job is a one-off small enough that pipeline
  overhead exceeds the benefit.

Say this once when it applies, then build what the user asked for.

## Samplesheet conventions

nf-core uses a CSV with a fixed leading column set. RNA-seq:

```csv
sample,fastq_1,fastq_2,strandedness
CONTROL_REP1,AEG588A1_L002_R1.fastq.gz,AEG588A1_L002_R2.fastq.gz,auto
```

Ribo-seq adds a `type` column (`riboseq` | `rnaseq` | `tiseq`), and extra columns
are allowed after the required ones (used for contrasts, pairing, treatment).

Two conventions worth adopting regardless of Nextflow:

**One row per FASTQ, sample id repeated for re-sequenced samples.** The same
`sample` across three rows means three lanes of one sample, concatenated before
analysis. This is why `SKILL.md`'s sample map appends rather than overwrites —
the same layout in a TSV silently loses lanes under naive assignment.

**Sample id is the join key, not the filename.** Never derive identity from a
filename when an explicit mapping exists; filenames encode lane and run details
that must collapse.

If a user brings an nf-core samplesheet, `sample,fastq_1` maps onto the
`<sample_id>\t<path>` TSV directly. `fastq_2` implies paired-end — the
single-end blocks in `SKILL.md` do not cover it.

## Strandedness (RNA-seq)

Values: `unstranded` | `forward` | `reverse` | `auto`.

`auto` means: subsample ~1M reads, infer with a quantifier, propagate. Typical
thresholds — forward-stranded if ≥80% of fragments are forward; unstranded if the
forward/reverse fractions differ by <10%; otherwise undetermined, which usually
signals genomic DNA contamination.

Nothing in the `SKILL.md` block library infers strandedness. It matters at
quantification, not alignment, so a preprocessing script that stops at the BAM
can legitimately ignore it — but the value must be recorded and carried forward,
and a wrong one silently halves or zeroes counts downstream. Ask; don't guess.

## Adapter trimming: Trim Galore vs fastp

nf-core defaults to Trim Galore (a Cutadapt + FastQC wrapper, auto-detects the
adapter); fastp is opt-in. They are functionally equivalent for single-end
adapter trimming. fastp is faster and emits integrated QC JSON/HTML, which is why
the blocks here use it.

Trim Galore caps usefully at ~4 cores (7–8 CPUs total) — more brings no runtime
benefit. Do not scale it with `THREADS` blindly.

## rRNA / contaminant removal

| Tool | Method | Notes |
|---|---|---|
| SortMeRNA | k-mer match vs rRNA database | nf-core default; needs a database manifest |
| Bowtie2 | alignment vs rRNA FASTA; keep unaligned | what `SKILL.md` uses; easiest with a custom reference |
| RiboDetector | ML, no database | **known to hang** in containers (ONNX multiprocessing); avoid in automated runs |

Two practical points:

- The "rRNA" reference can include other abundant contaminants (tRNA, other
  ncRNA). Composition is your choice; document what went in, because the
  contaminant rate is meaningless without it.
- Default SortMeRNA databases derive from SILVA 119, which **requires licensing
  for commercial use**. SILVA 138+ is CC-BY 4.0. If licensing is a concern, a
  Bowtie2 index over your own rRNA FASTA sidesteps it entirely.

## FASTQ validation

nf-core lints every input FASTQ and re-lints after each step that manipulates
FASTQ, failing the run on error. Cheap, and it catches truncated downloads and
malformed records before they become confusing alignment failures.

Worth adding to hand-written pipelines as a step after download and after trim.
Paired-read *name* checks are failure-prone in practice and are commonly disabled
while keeping the rest.

## UMIs

If the library has UMIs, reads must be deduplicated or PCR duplicates inflate
counts. The shape: extract the UMI (from read name or sequence, per the kit's
pattern) before trimming, then dedup after alignment.

Grouping method trades accuracy for compute — the most accurate (directional) is
also the most expensive; cheaper approximations exist for many-sample runs.

None of this is in the `SKILL.md` blocks. A UMI library needs extra tooling
(umi_tools or equivalent); flag it rather than silently skipping dedup.

## Canonical annotation backbone

Directly relevant to any footprint pipeline. Ribo-seq footprints (~28–32 nt)
cannot resolve which isoform they came from when reads fall on exons shared
between isoforms — against a full multi-isoform human annotation only ~7% of
Ribo-seq reads map uniquely.

The response is to separate two annotations:

- **Full, multi-isoform GTF** — for genome-guided alignment, and for tools that
  read a transcriptome-coordinate BAM (those BAMs are keyed to the full
  annotation; a canonical-only GTF would not match their transcript IDs).
- **Canonical backbone, one transcript per gene** — for P-site quantification,
  genome-coordinate ORF calling, and anything comparing across genes.

This is the same reasoning behind CDS/transcript-library alignment in
`reference.md`, and it generalizes: a one-transcript-per-gene reference removes
ambiguity the read length cannot resolve.

Sources for a canonical backbone:

| Organism | Source | Extraction |
|---|---|---|
| Human | MANE Select GTF | use directly |
| Any Ensembl organism (release ≥104) | Ensembl GTF | `grep 'tag "Ensembl_canonical"' in.gtf > canonical.gtf` |
| Any organism (fallback) | full GTF + AGAT | `agat_sp_keep_longest_isoform.pl` |

A curated source beats the AGAT fallback, which is structural (longest CDS per
gene, falling back to longest concatenated exons) rather than curated. MANE
Select covers protein-coding genes well but non-coding only partially;
`Ensembl_canonical` has broader biotype coverage, which matters for work on
lncRNA-encoded smORFs.

Exactly one transcript per gene is a recommendation, not a hard requirement —
annotations that occasionally list two (MANE Plus Clinical alongside MANE Select)
work fine and simply retain a little of the ambiguity the backbone reduces.

## Read length equalisation (RNA-seq vs Ribo-seq)

When comparing the two modalities, read lengths differ substantially — RNA-seq
75–150 bp vs footprints 26–34 nt. Different lengths mean different effective
mappability, which skews any ratio between them: regions can look translationally
silent purely because short reads could not map there uniquely.

If a downstream ratio analysis needs matched mappability, RNA-seq reads can be
hard-trimmed from the 5' end to the footprint length (for paired-end, only R1
survives). This is a downstream-analysis decision, out of scope for this skill,
but it constrains preprocessing: don't discard the untrimmed RNA-seq reads, and
keep the trimmed and untrimmed outputs distinctly named.

## Resource and reproducibility habits worth copying

- **Pin the version** of the pipeline/tools and record it with the results.
- **Build indexes once**, store centrally, reuse via an explicit path parameter.
- **Retry with more memory** on failure rather than sizing every job for the
  worst case.
- **Separate params from config**: what the analysis *is* (adapter, organism,
  lengths) versus where it runs (threads, memory, paths). The `getopts` block in
  `SKILL.md` is the params half; keep machine specifics out of the script body.
