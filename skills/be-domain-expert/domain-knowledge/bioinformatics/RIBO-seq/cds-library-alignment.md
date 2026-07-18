---
title: CDS-library alignment strategy for Ribo-seq
area: bioinformatics
tags: [ribo-seq, alignment, star, cds, multimapping, isoforms]
confidence: established
updated: 2026-07-18
sources:
  - Stein et al. 2022; Di Fraia et al. 2025 (CDS-library Bowtie v1 strategy)
  - verified empirically, BCbB Ribo-seq preprocessing, 2026-07
---

## Fact
An alternative to whole-genome alignment for Ribo-seq: build the aligner index
from a **synthetic FASTA of one CDS per gene** — the longest transcript's coding
sequence, exons concatenated (no introns), plus a short upstream flank (commonly
21 nt 5′ of the AUG). Align footprints to this library with strict flags:

```
--outFilterMultimapNmax 1   # unique mappers only
--outSAMmultNmax 1          # at most one record per read
--outFilterMismatchNmax 2   # <=2 mismatches
--alignEndsType EndToEnd    # no soft-clipping
--alignIntronMax 1          # no spliced alignment (the ref has no introns)
```

## Why it matters
Short footprints (~28–30 nt) cannot resolve which isoform or paralog they came
from when reads fall on shared exons. A one-CDS-per-gene reference removes that
ambiguity by construction, eliminating cross-isoform multimapping and spurious
intronic reads. Soft-clipping is disabled because a clipped end shifts the
inferred P-site and corrupts periodicity. The upstream flank keeps reads whose
P-site sits at the start codon on-reference.

## Caveats
CDS mode discards intronic, UTR, and intergenic signal — wrong for novel-ORF
discovery, UTR ribosome occupancy, or contamination diagnosis; use genome
alignment there. `--genomeSAindexNbases` must shrink for the small reference
([[star-genomesaindexnbases-small-genome]]). The flank length should match the
P-site offset you expect.

## See also
[[psite-offset]] · [[star-genomesaindexnbases-small-genome]] · [[three-nt-periodicity]]
