---
title: Elastic net is the standard aging-clock regression
area: machine-learning
tags: [elastic-net, regularization, aging-clock, feature-selection, high-dimensional]
confidence: established
updated: 2026-07-18
sources:
  - Zou & Hastie 2005 (J R Stat Soc B 67:301) — elastic net
  - Horvath 2013 (Genome Biology 14:R115) — DNAm clock built with elastic net
---

## Fact
Molecular aging clocks are typically built with **elastic net** — linear
regression penalized by a mix of L1 (lasso) and L2 (ridge):

```
minimize  ||y − Xβ||² + α[ l1_ratio·||β||₁ + (1−l1_ratio)·||β||₂² ]
```

The **L1 term drives most coefficients to zero**, yielding a small, interpretable
panel of age-predictive genes/CpGs; the **L2 term** stabilizes selection among
correlated features (lasso alone arbitrarily picks one of a correlated group).
`alpha` and `l1_ratio` are chosen by cross-validation.

## Why it matters
Omics data are p ≫ n (tens of thousands of features, tens–hundreds of samples),
where ordinary regression overfits catastrophically. Elastic net's sparsity makes
the clock both generalizable and reportable as a defined feature set — it is why
the Horvath clock and most successors use it. Standardize features first (fit the
scaler inside each CV fold — [[data-leakage-in-cross-validation]]).

## Caveats
The selected panel is **not unique or causal**: among correlated genes the choice
is partly arbitrary, and re-training on a new cohort yields a different set with
similar accuracy. Prediction accuracy ≠ biological importance. Very small `alpha`
approaches unregularized regression and overfits.

## See also
[[transcriptomic-aging-clock]] · [[principal-component-regression-clock]] · [[data-leakage-in-cross-validation]]
