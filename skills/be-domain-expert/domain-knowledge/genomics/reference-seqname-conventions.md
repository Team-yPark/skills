---
title: Genome sequence-name conventions differ by source
area: genomics
tags: [reference, genome, seqnames, ensembl, ucsc, ncbi, wormbase]
confidence: established
updated: 2026-07-18
sources:
  - Ensembl / Ensembl Genomes FTP file conventions
  - UCSC Genome Browser goldenPath naming
  - NCBI RefSeq accession format (NC_/NW_/NT_)
  - verified empirically, BCbB mouse (Ensembl) + worm (WormBase ParaSite) setup, 2026-07
---

## Fact
The same chromosome has different names in different reference sources:

| Source | Autosomes | Mito | Style |
|---|---|---|---|
| Ensembl / Ensembl Genomes | `1`, `2`, … | `MT` | bare |
| UCSC (goldenPath) | `chr1`, `chr2`, … | `chrM` | `chr`-prefixed |
| NCBI RefSeq | `NC_000001.11`, … | `NC_012920.1` | accession |
| WormBase ParaSite (C. elegans) | `I`, `II`, … `X` | `MtDNA` | roman numerals |

A FASTA and its annotation (GTF/GFF) must use the **same** convention, or every
downstream tool that joins them by sequence name silently matches nothing.

## Why it matters
Mixing a UCSC genome (`chr1`) with an Ensembl GTF (`1`) builds an aligner index
that produces zero (or near-zero) alignments — with **no error at build time**.
The failure surfaces much later as "my data is bad". Always take the FASTA and
the annotation from the same source and release, and check name concordance
before building an index.

## Caveats
Scaffold/patch/contig names do **not** follow the simple `chr` ↔ bare rule, so a
regex conversion of main chromosomes leaves scaffolds mismatched — a partial
conversion is worse than none. Convert via an explicit mapping (e.g. NCBI
`sequence_report.jsonl`) and re-check concordance by counting shared names, not
just "shared > 0".

## See also
[[fastq-gzip-multimember-concatenation]]
