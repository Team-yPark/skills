---
title: Fit at the level of the independent unit, not its sub-samples
area: statistics
tags: [pseudoreplication, independence, mixed-models, aggregation, experimental-design]
confidence: established
updated: 2026-07-18
sources:
  - Hurlbert 1984 (Ecol Monogr 54:187) — pseudoreplication
  - Lazic 2010 (BMC Neurosci 11:5) — the problem in biology
---

## Fact
Statistical tests assume the data points are **independent**. Sub-samples that
share a source are not: multiple worms from one condition/day bin, cells from one
animal, technical replicates of one sample. Treating them as independent
observations — **pseudoreplication** — fabricates degrees of freedom and shrinks
p-values artificially. Fixes: (1) **aggregate** to the independent unit (the bin
mean, the animal mean) and fit on those, or (2) use a **mixed model** with the
grouping as a random effect. A trend (e.g. entropy vs age) should be fit on
group-level points, not raw within-group members.

## Why it matters
It is one of the most common silent errors in biology analysis: an effect looks
strongly significant because n was counted as the number of cells/worms rather
than the number of independent replicates. The apparent power is fictitious and
does not reproduce.

## Caveats
There is a legitimate exception: you may fit on individual members **if** the
reference each is scored against is external and fixed (not estimated from the same
group), so the points are conditionally independent — but the default assumption
should be that shared-source samples are dependent. Grouped cross-validation
splits (keep a group entirely in train or test) are the CV analogue
([[data-leakage-in-cross-validation]]).

## See also
[[data-leakage-in-cross-validation]] · [[limma-empirical-bayes-small-n]] · [[robust-trend-theil-sen-mann-kendall]]
