---
title: 3-nt periodicity is the defining Ribo-seq signal and QC metric
area: bioinformatics
tags: [ribo-seq, periodicity, reading-frame, qc, footprint]
confidence: established
updated: 2026-07-18
sources:
  - Ingolia et al. 2009, Science 324:218 (PMID 19213877) — original Ribo-seq
  - Lauria et al. 2018, riboWaltz (PMC6112680)
---

## Fact
Ribosome-protected fragments (RPFs) advance one codon at a time, so their
mapped positions pile up with a **3-nucleotide period** along the coding
sequence. After assigning each read to a reading frame (0 / +1 / −1) via its
P-site, a healthy translating sample puts **≥ ~80%** of CDS reads in frame 0.
The in-frame fraction is the standard Ribo-seq quality metric: strong periodicity
means clean ribosome footprints; weak periodicity means degraded RNA, wrong
P-site offsets, or contamination.

## Why it matters
Periodicity is used two ways: (1) as a **QC gate** — select only read lengths
whose frame-0 fraction clears a threshold (e.g. ≥0.4–0.5) and have enough reads
(e.g. ≥5,000 in the metagene); non-periodic lengths are discarded before
analysis. (2) As **evidence of translation** — a locus with significant 1/3
cycles-per-nt signal is confidently translated (basis of ORF callers like
RiboTaper). No other assay gives sub-codon positional information.

## Caveats
Periodicity requires correct per-length P-site offsets first — bad offsets
destroy the signal even in good data. The ~80% figure is organism/protocol
dependent. Out-of-frame reads are not only noise: condition-dependent
frameshifting is a real biological signal (see caveat sources under stress).

## See also
[[psite-offset]] · [[psite-offset-calibration]] · [[ribosome-footprint-length]]
