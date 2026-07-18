---
title: Ribosome pause score — coverage over local mean
area: bioinformatics
tags: [ribo-seq, pause, codon, elongation, stalling]
confidence: established
updated: 2026-07-18
sources:
  - Ingolia et al. 2011; general Ribo-seq pause-site literature
  - verified empirically, BCbB pause-score analysis, 2026-07
---

## Fact
A **pause score** measures how much ribosome density piles up at one codon
relative to the rest of the same CDS — a proxy for local elongation slowdown.
At codon *i*:

```
pause_i = coverage_i / mean(coverage over internal CDS codons)
```

The denominator is the mean over interior codons, **excluding the first and last
~20 codons** (to avoid start/stop-codon accumulation artefacts). A score of 1 is
average; >1 is a pause. Scores are usually normalized within coverage bins so
they compare across genes of different depth.

## Why it matters
Pausing reflects elongation control — codon optimality, tRNA availability,
mRNA/nascent-peptide structure, collisions. Differential pausing between
conditions (per-codon Welch t-test or Fisher's exact on P-site counts, with
FDR correction) localizes where translation slows, at single-codon resolution
that TE and gene-level counts cannot see.

## Caveats
Requires accurate P-site offsets and adequate coverage — genes below a
per-codon-coverage floor (e.g. <0.5 reads/codon) are unreliable and should be
dropped. Start/stop exclusion window is a convention, not a constant. Absolute
pause magnitude is sensitive to normalization; prefer differential comparisons.

## See also
[[psite-offset]] · [[three-nt-periodicity]] · [[translation-efficiency]]
