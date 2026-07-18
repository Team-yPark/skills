---
title: AlphaFold2 predicts structure from an MSA via the Evoformer
area: bioinformatics
tags: [alphafold, structure-prediction, msa, evoformer, coevolution, casp]
confidence: established
updated: 2026-07-18
sources:
  - Jumper et al. 2021, AlphaFold2 (Nature 596:583); CASP14 — https://github.com/google-deepmind/alphafold
  - Mirdita et al. 2022, ColabFold (Nat Methods 19:679) — https://github.com/sokrypton/ColabFold
---

## Fact
AlphaFold2 (AF2) predicts a protein's 3D structure from its amino-acid sequence at
near-experimental accuracy — the breakthrough that won CASP14 (2020). Pipeline:

1. **Build a multiple-sequence alignment (MSA)** of evolutionarily related
   sequences, plus optional structural templates.
2. **Evoformer** — a transformer that jointly reasons over the MSA (co-evolution)
   and a residue–residue pair representation to infer which residues contact.
3. **Structure module** — turns that into explicit 3D atomic coordinates, refined
   by recycling.

It also emits per-residue **pLDDT** and pairwise **PAE** confidence
([[structure-confidence-plddt-pae]]). **ColabFold** makes AF2 fast/accessible by
generating the MSA with MMseqs2 (40–60× faster search).

## Why it matters
AF2 turned "get a structure" from months of crystallography or a wrong homology
model into minutes of compute for most well-conserved proteins, and populated the
AlphaFold DB with 200M+ predicted structures. The MSA is the engine: coevolution
across homologs is where most of the signal comes from.

## Caveats
Accuracy tracks **MSA depth** — shallow alignments give low-confidence models
([[msa-coevolution-structure-signal]]). AF2 returns **one static conformation**,
not dynamics or alternative states, and by default a single chain (use
AlphaFold-Multimer / AF3 / Boltz for complexes). High confidence ≠ correct function
or biological assembly ([[predicted-structure-caveats]]).

## See also
[[structure-confidence-plddt-pae]] · [[alphafold3-boltz-biomolecular-complexes]] · [[esmfold-protein-language-models]] · [[sequence-determines-structure]]
