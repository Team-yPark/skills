---
title: Differential protein expression uses a moderated t-test on log2 LFQ
area: proteomics
tags: [proteomics, differential-expression, limma, moderated-t-test, fdr, wilcoxon]
confidence: established
updated: 2026-07-18
sources:
  - Kammers et al. 2015 (EuPA Open Proteomics 7:11) — limma for proteomics
  - Ritchie et al. 2015, limma (Nucleic Acids Res 43:e47)
---

## Fact
Differential protein expression (DEP) between conditions is tested per protein on
**log2 LFQ** values, typically with a **moderated t-test** (limma) rather than an
ordinary t-test — limma's empirical-Bayes variance shrinkage borrows information
across proteins to stabilize the tiny per-protein variance estimate at low
replicate n ([[limma-empirical-bayes-small-n]]). P-values are BH-FDR corrected
across all tested proteins; results are read as a volcano plot (log2FC vs
−log10 FDR).

## Why it matters
Proteomics experiments are small-n (often 3–5), where per-protein t-tests are
underpowered and rank-based tests (Wilcoxon — Scanpy's default) are worse: with
n=3 the smallest possible Wilcoxon p-value cannot even reach significance. The
moderated t-test recovers usable power, which is why it is the field standard.

## Caveats
Requires the log2 scale and a sensible missing-value policy first
([[mnar-imputation]]) — a protein detected in one group but absent in the other is
common and not a plain fold-change. limma assumes approximately-normal residuals;
grossly non-normal proteins violate it. Batch/covariates belong in the design
matrix, not corrected away blindly ([[batch-correction-by-data-type]]).

## See also
[[lfq-log2-intensities]] · [[limma-empirical-bayes-small-n]] · [[mnar-imputation]]
