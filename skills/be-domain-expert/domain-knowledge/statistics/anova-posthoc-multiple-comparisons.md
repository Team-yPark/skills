---
title: A significant ANOVA needs a post-hoc test to say which groups differ
area: statistics
tags: [anova, post-hoc, tukey-hsd, multiple-comparisons, fdr, pairwise]
confidence: established
updated: 2026-07-18
sources:
  - Tukey 1949 (Biometrics 5:99) — HSD test
  - Benjamini & Hochberg 1995 (JRSS B 57:289) — FDR
---

## Fact
An omnibus ANOVA that rejects H0 says *some* group differs, not *which*. To
localize the difference, run a **post-hoc** pairwise test that controls the
family-wise error rate across the comparisons:

| Situation | Post-hoc |
|---|---|
| Equal-variance ANOVA, all pairwise | **Tukey HSD** |
| Vs one control group | Dunnett |
| Unequal variances (Welch ANOVA) | Games–Howell |
| Kruskal–Wallis (non-parametric) | Dunn (or Nemenyi) |

Only test pairwise **after** a significant omnibus (or use a method that builds the
correction in). Bare pairwise t-tests with no correction is the error these guard
against.

## Why it matters
With k groups there are k(k−1)/2 pairs; uncorrected pairwise testing lets the
false-positive rate balloon (10 groups → 45 tests). Post-hoc procedures keep the
error rate at the nominal α while still identifying the specific contrasts — the
part biologists actually want.

## Caveats
Family-wise methods (Tukey, Bonferroni) control the chance of **any** false
positive and are conservative; for large screens (thousands of genes) **FDR**
(Benjamini–Hochberg) is the usual choice instead — different error definitions, pick
deliberately. Match the post-hoc to the omnibus (Games–Howell with Welch, Dunn with
Kruskal–Wallis), not a mismatched pair.

## See also
[[one-way-anova]] · [[kruskal-wallis-nonparametric-anova]] · [[factorial-anova-interaction]]
