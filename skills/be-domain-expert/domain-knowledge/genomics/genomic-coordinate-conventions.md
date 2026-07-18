---
title: 0-based half-open vs 1-based inclusive genomic coordinates
area: genomics
tags: [coordinates, 0-based, 1-based, bed, bam, vcf, gff, off-by-one]
confidence: established
updated: 2026-07-18
sources:
  - UCSC / Ensembl coordinate documentation; SAM/VCF/BED format specs
  - pysam docs — coordinates are 0-based in the API
---

## Fact
Genomics uses **two incompatible coordinate systems**, and mixing them is the
classic off-by-one bug:

| System | Start | Interval | Used by |
|---|---|---|---|
| **0-based, half-open** | first base = 0 | `[start, end)` (end exclusive) | BED, BAM (binary), **pysam API**, UCSC internal, htslib |
| **1-based, inclusive** | first base = 1 | `[start, end]` (both included) | SAM text, VCF, GFF/GTF, GenBank, samtools/IGV region strings |

Interval length in 0-based = `end − start`. To convert a 1-based inclusive
position/interval to 0-based half-open: **start − 1**, end unchanged.

## Why it matters
The same feature has different numbers in different files/tools, so a coordinate
copied across a boundary without conversion is silently shifted by one base —
enough to break a variant call, a codon frame, or a peak overlap. When a tool's API
and its file format disagree (pysam is 0-based but prints SAM 1-based; a samtools
region string `chr1:1-100` is 1-based while `fetch(start=0, end=100)` is 0-based),
this is where the bug hides.

## Caveats
"Position" alone is ambiguous — always state the convention. Region **strings**
(`chr:start-end`) are almost always 1-based inclusive even in tools whose
programmatic API is 0-based. BED is 0-based half-open but the score/name columns
follow their own rules. VCF positions are 1-based and left-aligned.

## See also
[[sam-bam-cram-alignment-formats]] · [[pysam-htslib-python]] · [[reference-seqname-conventions]]
