---
title: Proteomics missing values are mostly MNAR — impute in the left tail
area: proteomics
tags: [proteomics, missing-values, mnar, imputation, perseus, lfq]
confidence: established
updated: 2026-07-18
sources:
  - Lazar et al. 2016 (J Proteome Res 15:1116) — missing values in MS proteomics
  - Tyanova et al. 2016 (Nat Methods 13:731) — Perseus down-shifted imputation
---

## Fact
In mass-spec proteomics, a missing value usually means the protein was **present
but below the detection limit** — missing-not-at-random (MNAR, left-censored),
correlated with low abundance — not missing-at-random (MAR). The standard fix is
**left-shifted imputation**: replace missing entries with draws from a narrow
Gaussian placed in the low tail of each sample's observed distribution. The
Perseus convention, per sample:

```
imputed ~ Normal(μ − 1.8·σ,  (0.3·σ)²)      μ, σ from that sample's detected values
```

## Why it matters
MAR imputers (KNN, mean, regression) assume the missing value resembles observed
ones and therefore impute **too high**, erasing the real low-abundance signal and
inventing differential-expression artefacts. Downstream steps that cannot accept
NaN — batch correction (ComBat/Harmony), PCA, clustering — force an imputation
choice, so making it MNAR-aware is load-bearing, not cosmetic.

## Caveats
Not all missingness is MNAR: values missing due to run failures or ID transfer are
MAR and better handled by MAR methods; real data are a mix. The −1.8σ/0.3σ
constants are conventions, not laws — tune to the platform. DIA data have less
missingness than DDA. Impute once, and record that you did — imputed values are
not measurements.

## See also
[[lfq-log2-intensities]] · [[batch-correction-by-data-type]] · [[differential-protein-expression]]
