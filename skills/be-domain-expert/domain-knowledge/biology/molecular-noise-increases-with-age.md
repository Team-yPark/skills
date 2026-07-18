---
title: Molecular heterogeneity tends to increase with age
area: biology
tags: [aging, transcriptional-noise, heterogeneity, entropy, dispersion, single-cell]
confidence: emerging
updated: 2026-07-18
sources:
  - Bahar et al. 2006 (Nature 441:1011) — increased cell-to-cell variation with age
  - Enge et al. 2017 (Cell 171:321) — transcriptional noise in aging pancreas
---

## Fact
A recurring observation in aging: the **variability** of molecular profiles —
between cells, or between nominally-identical individuals — tends to **rise with
age**, even when mean expression is stable. Loss of tight regulation shows up as
increased cell-to-cell "transcriptional noise" and as proteome/transcriptome
**dispersion** or **entropy**. It is commonly quantified as mean-corrected distance
to a group centroid, Shannon entropy of the abundance profile, or loss of
co-expression structure (network decorrelation).

## Why it matters
It reframes aging as a loss of homeostatic control, not only a shift in average
state — two cohorts can share a mean profile while differing sharply in dispersion.
An "entropy-vs-age" slope, per gene or per module, is a distinct readout from
mean-expression-vs-age and can flag regulation breakdown that differential
expression misses.

## Caveats
`emerging`/contested: the effect is real in several systems but **not universal**,
and it is easy to measure spuriously. Dispersion is confounded with the mean
(higher-abundance features vary more) — decouple mean from variance before scoring.
Small groups bias variance downward (variance around their own mean), and batch
confounded with age inflates apparent noise. Always check these before claiming an
age–noise trend.

## See also
[[wgcna-coexpression-modules]] · [[pseudoreplication]] · [[transcriptomic-aging-clock]]
