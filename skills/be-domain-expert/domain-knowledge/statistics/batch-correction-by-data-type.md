---
title: Choose the batch-correction method by data type
area: statistics
tags: [batch-effect, combat, combat-seq, harmony, normalization, integration]
confidence: established
updated: 2026-07-18
sources:
  - Johnson et al. 2007, ComBat (Biostatistics 8:118); Zhang et al. 2020, ComBat-seq
  - Korsunsky et al. 2019, Harmony (Nat Methods 16:1289)
---

## Fact
Batch effects need a correction matched to the data's scale and downstream use:

| Method | Input | Model | Use for |
|---|---|---|---|
| **ComBat** | log / continuous | empirical-Bayes location–scale on the matrix | proteomics (log2 LFQ), microarray, methylation |
| **ComBat-seq** | raw counts | negative-binomial, returns adjusted counts | bulk RNA-seq counts feeding an NB model |
| **Harmony** | an embedding (PCA) | iterative clustering + correction in latent space | single-cell / large-scale integration |

ComBat-family corrects the **feature matrix**; Harmony corrects an **embedding**
(so you get integrated coordinates, not a corrected gene matrix, unless you
inverse-transform).

## Why it matters
Using the wrong one silently damages data: ComBat on raw counts breaks the
count-model assumptions ([[count-models-need-raw-counts]]); Harmony gives no
gene-space matrix for per-gene tests. Matrix methods also require **no NaN** —
impute first ([[mnar-imputation]]).

## Caveats
All batch correction assumes batch is **not confounded** with the biological
factor — if a condition and a batch coincide, correction removes the effect you
want. Pass known biological covariates to protect them, and check group/batch
balance before comparing. Over-correction erases real signal; prefer modelling
batch as a covariate when the design allows.

## See also
[[count-models-need-raw-counts]] · [[mnar-imputation]] · [[clock-transfer-batch-correction]] · [[deseq2-median-of-ratios]]
