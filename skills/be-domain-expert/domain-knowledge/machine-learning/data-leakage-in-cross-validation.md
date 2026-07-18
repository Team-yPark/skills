---
title: Nothing derived from held-out data may touch the model
area: machine-learning
tags: [cross-validation, data-leakage, preprocessing, model-selection, overfitting]
confidence: established
updated: 2026-07-18
sources:
  - Kaufman et al. 2012 (ACM TKDD 6:15) — leakage in data mining
  - Hastie, Tibshirani & Friedman, ESL — CV done right
---

## Fact
Any quantity computed from data the model is evaluated on — and used to build or
choose that model — **leaks** and inflates the reported score. Two common forms:

1. **Preprocessing leakage.** Fitting a scaler, PCA, imputation, or feature filter
   on the **full** dataset before splitting means each training fold has seen
   statistics of its held-out samples. Fix: fit every data-dependent transform
   **inside each CV fold, on the training portion only**, then apply to the held-out
   part (a scikit-learn `Pipeline` inside the CV does this correctly).
2. **Model-selection leakage.** Choosing hyperparameters or the number of
   components/features by a metric computed on the **test/query** set (e.g. picking
   `n_components` by a p-value on the target samples). Fix: select using
   cross-validation **on the training set only**; the test set is touched once, at
   the end.

## Why it matters
Leakage produces optimistic accuracy that evaporates on genuinely new data — the
model looks validated but is not. It is the most common reason a published clock or
classifier fails to reproduce. The failure is silent: the code runs and the numbers
look good.

## Caveats
Leave-one-out / leave-one-sample-out CV is low-bias but higher-variance and does
not remove the need for in-fold preprocessing. Grouped data (replicates, subjects,
batches) needs **grouped** splitting so correlated samples do not straddle the
train/test boundary — otherwise leakage persists even with a correct pipeline.

## See also
[[elastic-net-aging-clock]] · [[principal-component-regression-clock]] · [[transcriptomic-aging-clock]]
