---
title: The four levels of protein structure
area: biochemistry
tags: [protein, structure, secondary-structure, folding, alpha-helix, beta-sheet]
confidence: established
updated: 2026-07-18
sources:
  - Lehninger Principles of Biochemistry; Berg, Stryer Biochemistry
---

## Fact
Protein structure is described at four levels:

1. **Primary** — the linear amino-acid sequence, joined by peptide bonds.
2. **Secondary** — local backbone patterns stabilized by backbone hydrogen bonds:
   **α-helices** and **β-sheets** (plus turns/loops).
3. **Tertiary** — the full 3D fold of one polypeptide chain: how helices/sheets
   pack, driven mainly by burial of hydrophobic side chains and constrained by
   disulfide bonds, salt bridges, and packing.
4. **Quaternary** — assembly of multiple chains (subunits) into a complex (e.g.
   a homodimer, hemoglobin's α₂β₂).

Function derives from the folded 3D shape (tertiary/quaternary), not the sequence
alone.

## Why it matters
The levels frame what a structure-prediction tool outputs and where it can fail:
secondary structure is comparatively easy; tertiary packing is the hard part;
quaternary/complex prediction (multiple chains, ligands) is a separate, harder
problem some models (AlphaFold-Multimer, AF3, Boltz) target. "Predicting a
structure from sequence" means going primary → tertiary.

## Caveats
Not all proteins adopt a single fixed tertiary fold — **intrinsically disordered**
regions lack stable structure yet are functional. Many proteins are multi-domain
(semi-independent folding units) or change conformation on binding. Membrane
proteins fold in a lipid environment the standard picture underplays.

## See also
[[sequence-determines-structure]] · [[amino-acid-properties]] · [[protein-domains-modular-units]]
