---
title: SAM / BAM / CRAM — the alignment formats and their index
area: bioinformatics
tags: [sam, bam, cram, samtools, htslib, cigar, flag, index, alignment]
confidence: established
updated: 2026-07-18
sources:
  - SAM/BAM/CRAM format specification — https://github.com/samtools/hts-specs (samtools.github.io/hts-specs)
  - samtools / htslib — https://github.com/samtools/samtools
---

## Fact
Read alignments are stored in three interconvertible formats:

- **SAM** — human-readable **text**; one line per alignment.
- **BAM** — the **binary**, BGZF-compressed form of SAM; the working format.
- **CRAM** — **reference-based** compression (stores differences from a reference,
  not full sequences); smaller than BAM but **requires the reference FASTA** to
  decode.

Each record carries: **FLAG** (bitfield: paired, mapped, reverse-strand, duplicate,
secondary/supplementary…), reference name + **1-based POS**, **MAPQ** (mapping
quality), **CIGAR** (match/insert/delete/soft-clip string), sequence, base
qualities, and optional **tags** (`NH`, `HI`, `NM`, `MD`, …).

**Random access needs a coordinate-sorted file plus an index** (`.bai` or `.csi`
for BAM, `.crai` for CRAM). Without sort+index you can only stream start-to-end.

## Why it matters
Nearly every downstream tool assumes a **sorted, indexed BAM/CRAM** — `fetch` by
region, coverage, variant calling all fail or fall back to full scans otherwise.
Knowing FLAG/CIGAR/MAPQ is what lets you filter correctly (e.g. drop secondary +
supplementary + duplicates, require MAPQ ≥ N) rather than miscount reads.

## Caveats
CRAM silently needs the **exact** reference it was written against — a missing or
wrong reference gives errors or corrupt sequence. `.bai` cannot index contigs
longer than 512 Mb — use `.csi` for large genomes. FLAG is a bitfield: test bits,
don't compare equality. POS in the file is 1-based; most programmatic APIs are
0-based ([[genomic-coordinate-conventions]]).

## See also
[[pysam-htslib-python]] · [[genomic-coordinate-conventions]] · [[reference-seqname-conventions]]
