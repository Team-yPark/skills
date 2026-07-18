---
title: Factorial (two-way) ANOVA and the interaction term
area: statistics
tags: [anova, two-way, factorial, interaction, main-effect, design]
confidence: established
updated: 2026-07-18
sources:
  - Fisher 1935, The Design of Experiments — factorial designs
---

## Fact
Factorial ANOVA models an outcome with **two or more crossed factors** at once
(e.g. genotype × treatment), partitioning variance into each factor's **main
effect** plus their **interaction**:

```
y ~ A + B + A:B
```

The **interaction** `A:B` tests whether the effect of one factor *depends on the
level of the other* — e.g. a drug changes expression in the mutant but not the
wild type. A significant interaction means the main effects cannot be read in
isolation.

## Why it matters
The interaction is frequently the actual biological hypothesis: "does the treatment
response differ by genotype?", "is the age effect condition-dependent?". Testing
factors one at a time in separate ANOVAs cannot answer it and wastes samples;
one factorial model does, with more power. This is the same interaction logic
behind DE interaction models (deltaTE's `condition:assay`, [[translation-efficiency]]).

## Caveats
Interpret main effects cautiously when the interaction is significant — the "main
effect" is then an average over conditions that may not apply to any of them.
Unbalanced designs make the sums of squares order-dependent (Type I vs II vs III);
state which you used. Interactions need more samples to detect than main effects.
Same normality/variance/independence assumptions as one-way ([[one-way-anova]]).

## See also
[[one-way-anova]] · [[ancova-covariate-adjustment]] · [[translation-efficiency]] · [[repeated-measures-mixed-model]]
