---
title: One-way ANOVA — F-test for three or more group means
area: statistics
tags: [anova, f-test, hypothesis-test, variance, multi-group, differential-expression]
confidence: established
updated: 2026-07-18
sources:
  - Fisher 1925, Statistical Methods for Research Workers — ANOVA
  - Welch 1951 (Biometrika 38:330) — ANOVA under unequal variances
---

## Fact
One-way ANOVA tests whether ≥3 groups share a common mean by comparing
**between-group** variance to **within-group** variance:

```
F = MS_between / MS_within      (large F → group means differ)
```

Under H0 (all means equal) F follows an F-distribution with `(k−1, N−k)` degrees
of freedom. It is the generalization of the two-sample t-test to many groups (for
k=2, F = t²). It answers only "do any groups differ?" — an **omnibus** test — not
which ones ([[anova-posthoc-multiple-comparisons]]).

## Why it matters
Testing k groups with all pairwise t-tests inflates the false-positive rate; ANOVA
gives one controlled omnibus test. In bioinformatics, a **per-gene one-way ANOVA
F-test** across >2 conditions is the basis of multi-group differential expression —
`limma` runs exactly this but replaces the noisy per-gene within-group variance
with an empirical-Bayes **moderated F** ([[limma-empirical-bayes-small-n]]).

## Caveats
Assumes independent observations ([[pseudoreplication]]), approximately **normal**
residuals, and **equal variances** across groups (homoscedasticity). When variances
differ, use **Welch's ANOVA** (does not pool variance); when normality fails, use
the rank-based **Kruskal–Wallis** ([[kruskal-wallis-nonparametric-anova]]). ANOVA is
fairly robust to mild non-normality with balanced, moderate n, but not to
non-independence.

## See also
[[anova-posthoc-multiple-comparisons]] · [[factorial-anova-interaction]] · [[kruskal-wallis-nonparametric-anova]] · [[limma-empirical-bayes-small-n]]
