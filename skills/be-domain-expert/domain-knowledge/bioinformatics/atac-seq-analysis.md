---
title: ATAC-seq analysis — chromatin accessibility with the Tn5 shift
area: bioinformatics
tags: [atac-seq, chromatin-accessibility, tn5, macs2, nucleosome, peak-calling]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/atacseq pipeline — https://github.com/nf-core/atacseq
  - Buenrostro et al. 2013 (Nat Methods 10:1213) — ATAC-seq
  - MACS peak caller — https://github.com/macs3-project/MACS
---

## Fact
ATAC-seq maps **open chromatin**: a hyperactive Tn5 transposase inserts adapters
into accessible DNA. Workflow mirrors ChIP-seq (align → filter → MACS2 peaks →
consensus) with accessibility-specific steps:

- **Remove mitochondrial reads** — mito chromatin is always open, so ATAC libraries
  are heavily mito-contaminated (often >20% of reads); drop them.
- **Tn5 shift** — offset read starts (+4 bp on +, −5 bp on −) to center on the Tn5
  cut site before peak calling.
- No input control is needed (unlike ChIP); MACS2 calls peaks directly.
- **Fragment-size distribution** should show nucleosome periodicity (~200 bp
  ladder) — a key QC that the assay worked.

## Why it matters
Chromatin accessibility marks active regulatory elements (promoters, enhancers)
genome-wide from a small input, without needing an antibody. Omitting the
mito-read removal or the Tn5 shift skews peak calls and every downstream footprint.

## Caveats
Accessibility ≠ activity — an open region is not necessarily transcribed.
Nucleosome-free vs mononucleosome fragments carry different information (footprints
vs positioning). Sensitive to input cell number and over/under-transposition.
Peaks are regions, not base-pair binding sites; TF footprinting is a separate,
noisier analysis.

## See also
[[chip-seq-analysis]] · [[nf-core-standardized-pipelines]]
