---
title: Amino-acid sequence determines native structure (Anfinsen's dogma)
area: biochemistry
tags: [protein-folding, anfinsen, thermodynamics, native-state, structure-prediction]
confidence: established
updated: 2026-07-18
sources:
  - Anfinsen 1973 (Science 181:223) — thermodynamic hypothesis of folding
---

## Fact
**Anfinsen's dogma**: for many small globular proteins, the amino-acid sequence
alone encodes the native 3D fold, which is the thermodynamically most stable
(lowest free-energy) accessible state under physiological conditions. A denatured
protein can spontaneously refold to its functional structure without external
information. This is the premise that makes **structure prediction from sequence**
(AlphaFold, ESMFold, etc.) a well-posed problem at all.

## Why it matters
It is the theoretical license for sequence → structure prediction: if the fold is
a function of the sequence, a model trained on sequence–structure pairs can learn
that mapping. It also underlies why coevolution in a multiple-sequence alignment
is informative — residues that contact in the fold co-vary to preserve it.

## Caveats
The dogma is not universal. **Chaperones** are required for many proteins to reach
the native state in the crowded cell (kinetic, not thermodynamic, help).
**Intrinsically disordered** proteins have no single native fold. Some sequences
are **metamorphic / fold-switching** (two stable folds), and prions/misfolding show
the native state is not always the global minimum in vivo. Prediction tools inherit
these limits — they return one fold for a sequence that may adopt several.

## See also
[[protein-structure-levels]] · [[alphafold2-msa-structure-prediction]] · [[msa-coevolution-structure-signal]]
