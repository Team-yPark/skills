---
title: Transcriptomic aging clock — predict age from expression
area: machine-learning
tags: [aging-clock, transcriptomic, age-prediction, regression, biomarker]
confidence: established
updated: 2026-07-18
sources:
  - Horvath 2013 (Genome Biology 14:R115) — epigenetic clock, foundational
  - Peters et al. 2015 (Nat Commun) — transcriptomic age; BayesAge2 / KillifishAtlas
---

## Fact
An **aging clock** is a supervised model trained to predict chronological (or
biological) age from a molecular profile. A **transcriptomic** clock uses gene
expression; the prediction is the **transcriptomic age (tAge)**. Training regresses
a reference cohort's expression on known ages; the fitted model then scores new
samples. Three model families dominate:

| Family | Idea | Output |
|---|---|---|
| Penalized regression (elastic net) | sparse linear panel of age-predictive genes | small interpretable gene set |
| Principal component regression | regress age on top PCs of expression | noise-robust, dense |
| Bayesian / likelihood | ML age over a smoothed age–expression reference | probabilistic age |

## Why it matters
tAge minus chronological age (the "age acceleration" residual) is the actual
readout of interest — it flags samples/tissues aging faster or slower, and tests
whether an intervention (diet, drug, mutation) shifts biological age. The clock is
a tool; the deviation from the diagonal is the result.

## Caveats
Clocks are **correlative predictors, not mechanisms** — a gene's clock weight does
not imply it drives aging. They are tissue- and platform-specific and transfer
poorly across datasets without batch correction ([[clock-transfer-batch-correction]]).
Evaluate honestly with held-out cross-validation, never on the training cohort.

## See also
[[elastic-net-aging-clock]] · [[principal-component-regression-clock]] · [[bayesage-likelihood-age-prediction]] · [[data-leakage-in-cross-validation]]
