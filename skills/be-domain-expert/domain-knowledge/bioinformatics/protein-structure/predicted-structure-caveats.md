---
title: What a predicted structure is not — one static model, not the whole story
area: bioinformatics
tags: [alphafold, limitations, dynamics, conformation, function, interpretation]
confidence: established
updated: 2026-07-18
sources:
  - Jumper et al. 2021 (Nature 596:583); AlphaFold DB FAQ — https://alphafold.ebi.ac.uk
  - fold-switching / conformational-heterogeneity literature (e.g. Chakravarty & Porter 2022)
---

## Fact
A predicted structure (AF2/AF3/ESMFold/Boltz) is a single, static, most-likely 3D
model. It does **not** deliver:

- **Dynamics or conformational ensembles** — one snapshot, not the motions,
  alternative states, or **fold-switching** a protein may undergo.
- **The bound/functional state** by default — apo vs holo, active vs inactive,
  induced-fit changes are not captured unless the ligand/partner is modelled (AF3/
  Boltz).
- **Function, mechanism, or biological assembly** — a confident fold does not tell
  you what the protein does, its true oligomeric state, or its localization.
- **The effect of point mutations** on stability/function reliably — the models are
  largely insensitive to single substitutions.

## Why it matters
The single most common misuse is treating a high-pLDDT model as ground truth for a
question it cannot answer — reading a mechanism, an allosteric state, or a mutation
effect off one static structure. Knowing the boundary keeps predictions useful
(hypothesis generation, homology, domain layout) without overclaiming.

## Caveats
High confidence and wrongness can coexist (e.g. AF2's confident but unrealistic
β-solenoid repeat structures). Predictions are excellent starting models for
experiment (molecular replacement, cryo-EM fitting) — the limitation is
interpretation, not the structures being useless. Emerging methods coax ensembles
from these models, but that is not the default output.

## See also
[[structure-confidence-plddt-pae]] · [[alphafold2-msa-structure-prediction]] · [[sequence-determines-structure]]
