---
title: Kruskal–Wallis — rank-based ANOVA alternative
area: statistics
tags: [kruskal-wallis, non-parametric, ranks, anova, dunn, eqtl]
confidence: established
updated: 2026-07-18
sources:
  - Kruskal & Wallis 1952 (J Am Stat Assoc 47:583)
  - Dunn 1964 (Technometrics 6:241) — post-hoc for Kruskal–Wallis
---

## Fact
The Kruskal–Wallis test is the **non-parametric one-way ANOVA**: it ranks all
observations together and tests whether the mean ranks differ across ≥3 groups.
It replaces the normality assumption with a distribution-free rank statistic
(χ²-approximated), so it works on skewed, heavy-tailed, or ordinal data. For k=2 it
reduces to the Mann–Whitney U test. A significant result is followed by **Dunn's
test** (or Nemenyi) for pairwise comparisons.

## Why it matters
Bioinformatics data are frequently non-normal and small-n, where ANOVA's normality
assumption is shaky. Kruskal–Wallis is standard for comparing expression across
tissues/disease states and for **eQTL** discovery (robust to the genotype model and
to trait-distribution shape). It tests distributions/medians rather than means, so
it resists outliers that would distort an ANOVA.

## Caveats
Lower power than ANOVA **when** ANOVA's assumptions actually hold — don't reach for
it reflexively. It tests whether distributions differ; interpreting it strictly as
"medians differ" assumes similarly-shaped group distributions. Heavy ties degrade
the χ² approximation (use a tie correction / exact test). Still assumes
**independent** samples ([[pseudoreplication]]).

## See also
[[one-way-anova]] · [[anova-posthoc-multiple-comparisons]] · [[robust-trend-theil-sen-mann-kendall]]
