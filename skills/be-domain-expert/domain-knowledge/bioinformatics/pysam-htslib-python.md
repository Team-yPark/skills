---
title: pysam — Python bindings to htslib for SAM/BAM/VCF/tabix/FASTA
area: bioinformatics
tags: [pysam, htslib, python, bam, vcf, tabix, fasta, api]
confidence: established
updated: 2026-07-18
sources:
  - pysam — https://github.com/pysam-developers/pysam (docs: https://pysam.readthedocs.io)
  - htslib / samtools / bcftools (pysam wraps these)
---

## Fact
**pysam** is a thin Python wrapper over **htslib** (the C library behind samtools/
bcftools) for reading and writing genomics files without shelling out. Core
classes:

| Class | For |
|---|---|
| `AlignmentFile` / `AlignedSegment` | SAM/BAM/CRAM records (`.fetch()`, `.pileup()`) |
| `VariantFile` / `VariantRecord` | VCF/BCF |
| `TabixFile` | any tabix-indexed, bgzipped tab-delimited file (BED/GFF/…) |
| `FastaFile` (indexed) / `FastxFile` (streaming) | FASTA/FASTQ |

It also exposes samtools/bcftools commands as functions (`pysam.sort`,
`pysam.index`, …). Open with an explicit mode: `AlignmentFile(path, "rb")` (read
BAM), `"rc"` (CRAM), `"wb"` (write BAM).

## Why it matters
It is the standard way to script alignment/variant analysis in Python — per-read
filtering, pileups, coverage, region queries — at C speed. For deeper/current API
detail, search the repo and readthedocs (linked in sources); this entry is the
orientation, not the full manual.

## Caveats (the ones that bite in development)
- **The API is 0-based half-open** (`fetch(start, end)`) but region **strings**
  (`"chr1:1-100"`) and printed SAM POS are 1-based ([[genomic-coordinate-conventions]]).
- **`.fetch()` needs a coordinate-sorted, indexed BAM/CRAM** — otherwise it errors
  or must scan (`until_eof=True` streams unsorted/unindexed).
- **Pileup objects are transient**: `PileupColumn`/`PileupRead` returned by
  `.pileup()` are only valid during the current iteration — copy what you need.
- **Two iterators on one file handle interfere**; use `multiple_iterators=True` or
  separate handles.
- **CRAM needs the reference** (`reference_filename=`).
- API details and defaults change across versions — pin pysam and check the linked
  docs for the version you use.

## See also
[[sam-bam-cram-alignment-formats]] · [[genomic-coordinate-conventions]] · [[reference-seqname-conventions]]
