---
title: Principal component regression (PC) clocks reduce technical noise
area: machine-learning
tags: [pcr, pca, aging-clock, regression, reliability, collinearity]
confidence: established
updated: 2026-07-18
sources:
  - Higgins-Chen et al. 2022 (Nature Aging 2:644) — PC-based epigenetic clocks
  - verified empirically, KillifishAtlas PCR clock, 2026-07
---

## Fact
A **PC regression clock** fits a pipeline: standardize → **PCA** (keep the top *k*
components) → linear regression of age on those PCs. Prediction runs a new sample
through the same fitted transform. *k* is selected by cross-validation (e.g. the
value maximizing LOSO-CV R²), **not** by inspecting the test set.

Per-gene importance is recovered from the PCA loadings and regression
coefficients: `gene_importance = loadings.T · coef`.

## Why it matters
Individual gene/CpG measurements are noisy and highly correlated. Projecting onto
principal components **averages out uncorrelated technical noise** before
regression, which markedly improves **test–retest reliability** of the age
estimate — the main advantage of PC clocks over single-feature elastic-net clocks
(Higgins-Chen 2022). It also sidesteps multicollinearity, which destabilizes plain
linear regression.

## Caveats
PCs are dense — the clock uses all input features, so it is less interpretable than
a sparse elastic-net panel. Top PCs capture the largest variance, which may be
batch/tissue rather than age; inspect what the retained PCs encode. Choosing *k* by
a metric computed on the query/test set is model-selection leakage
([[data-leakage-in-cross-validation]]).

## See also
[[transcriptomic-aging-clock]] · [[elastic-net-aging-clock]] · [[data-leakage-in-cross-validation]]
