---
title: PERMANOVA — permutational multivariate ANOVA on a distance matrix
area: statistics
tags: [permanova, adonis, microbiome, beta-diversity, multivariate, permutation]
confidence: established
updated: 2026-07-18
sources:
  - Anderson 2001 (Austral Ecology 26:32) — PERMANOVA
  - Anderson 2006 (Biometrics 62:245) — PERMDISP (dispersion test); vegan adonis2
---

## Fact
PERMANOVA tests whether groups differ in **multivariate** composition, operating
directly on a **distance/dissimilarity matrix** (Bray–Curtis, Jaccard, UniFrac,
Euclidean, …) rather than raw variables. It partitions the total sum of squared
dissimilarities into between- and within-group parts, forms a **pseudo-F**, and
gets its p-value by **permuting group labels** — no multivariate-normal assumption.
It reports **R²** (fraction of variation explained). In R it is `vegan::adonis2`.

## Why it matters
It is the field-standard test for "does community composition differ across groups?"
in microbiome and ecology (e.g. beta diversity ~ treatment). Feature counts there
are high-dimensional, non-normal, and zero-inflated, which breaks classical MANOVA;
PERMANOVA sidesteps all of it by working on distances and permutations, and handles
any metric appropriate to the data.

## Caveats
A significant PERMANOVA can reflect **different group dispersions** (spread), not
just different centroids — so pair it with a dispersion test (**PERMDISP** /
`betadisper`); if dispersions differ, the location conclusion is confounded. The
result depends heavily on the **chosen distance metric** — report it. Unbalanced
designs affect sensitivity to dispersion. Permutation must respect the design
(constrain permutations within blocks/strata for nested/repeated data,
[[pseudoreplication]]).

## See also
[[one-way-anova]] · [[factorial-anova-interaction]] · [[pseudoreplication]]
