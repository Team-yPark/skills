---
title: BayesAge-style likelihood age prediction over an expression reference
area: machine-learning
tags: [bayesage, maximum-likelihood, poisson, aging-clock, count-data, lowess]
confidence: emerging
updated: 2026-07-18
sources:
  - Mboning et al., BayesAge / BayesAge2 (transcriptomic extension)
  - verified empirically, KillifishAtlas BayesAge2 implementation, 2026-07
---

## Fact
Instead of regressing age on expression, a **likelihood clock** builds a reference
of how each gene's expression varies with age, then predicts a query sample's age
as the one that **maximizes the likelihood** of its observed counts. BayesAge2:

1. Rank each gene's expression against age (Spearman) and keep the top age-correlated genes.
2. Fit a **LOWESS**-smoothed expression-vs-age curve per gene → reference `(genes × age-grid)`.
3. For a query sample, pick the age on the grid that maximizes the summed
   **Poisson log-likelihood** of its counts against the reference curves.

Input is **frequency-normalized** counts (count / sample total), the natural scale
for a Poisson model.

## Why it matters
It is a non-parametric, count-native alternative to linear clocks: no linear
age–expression assumption (LOWESS captures non-monotone trends), and it yields a
probabilistic age with a natural grid resolution. Genes are ranked by |Spearman r|,
giving an interpretable age-signal ordering.

## Caveats
Feeding DESeq2-normalized (already-scaled) counts and then frequency-normalizing
**double-normalizes** — a real, silent bug; give it raw counts. LOWESS `frac`
strongly affects predictions (too small → overfit wiggles). Newer and less
battle-tested than elastic-net/PC clocks, hence `emerging`. The age grid must span
the biology (extrapolation outside the reference ages is meaningless).

## See also
[[transcriptomic-aging-clock]] · [[count-models-need-raw-counts]] · [[deseq2-median-of-ratios]]
