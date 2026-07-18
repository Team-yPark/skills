---
title: Trim one 5′ nucleotide from ligation-based small-RNA / Ribo-seq reads
area: bioinformatics
tags: [ribo-seq, small-rna, library-prep, trimming, fastp, artifact]
confidence: established
updated: 2026-07-18
sources:
  - Stein et al. 2022; Di Fraia et al. 2025 (FASTX-Trimmer -f 2 step)
  - verified empirically, BCbB Ribo-seq preprocessing (fastp --trim_front1 1), 2026-07
---

## Fact
Ribo-seq and other small-RNA libraries built by RNA-ligation add a **non-templated
nucleotide at the 5′ end** of reads during ligase-based adapter attachment.
Standard practice removes exactly one base from the 5′ end of every read after
adapter trimming: `fastp --trim_front1 1`, equivalently `fastx_trimmer -f 2`.

## Why it matters
The extra 5′ base offsets every read by 1 nt, which shifts the inferred P-site
and can blur 3-nt periodicity. Removing it before alignment restores correct
codon-frame registration. It is a one-line preprocessing step with a real effect
on downstream frame and pause analysis.

## Caveats
This is specific to **ligation-based small-RNA / Ribo-seq protocols**. It is
destructive on standard RNA-seq, where it silently shortens every read by a base
for no reason. Confirm against the library-prep kit before applying, and treat
the exact count (1 nt) as protocol-dependent rather than universal.

## See also
[[psite-offset]] · [[three-nt-periodicity]] · [[cds-library-alignment]]
