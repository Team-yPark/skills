---
title: AlphaFold3 and Boltz — diffusion models for biomolecular complexes
area: bioinformatics
tags: [alphafold3, boltz, diffusion, complexes, ligands, nucleic-acids, docking]
confidence: established
updated: 2026-07-18
sources:
  - Abramson et al. 2024, AlphaFold3 (Nature 630:493) — https://github.com/google-deepmind/alphafold3
  - Wohlwend et al. 2024, Boltz-1; Boltz-2 (2025) open AF3-class model — https://github.com/jwohlwend/boltz
---

## Fact
AlphaFold3 (AF3) extends structure prediction from single proteins to **general
biomolecular complexes** — proteins with **DNA, RNA, small-molecule ligands, ions,
and modified residues** — in one model. Architecturally it replaces AF2's structure
module with a **diffusion** decoder that generates atomic coordinates directly
(iteratively denoising from noise), on top of a lightweight MSA/pairformer trunk.
Confidence is per-atom pLDDT plus PAE/pTM/ipTM.

**Boltz** (Boltz-1/Boltz-2) is an **open-source, AF3-class diffusion model** with
competitive accuracy, notable for protein–ligand pose (and Boltz-2 binding-affinity)
prediction — the practical open alternative to AF3's restricted access.

## Why it matters
Most biology is complexes and ligands, not lone chains. AF3/Boltz let you predict a
protein–ligand pose, a protein–nucleic-acid complex, or a multi-subunit assembly
from sequences (+ ligand SMILES) without docking pipelines. Boltz being open means
you can run it locally and at scale, unlike the AF3 server's usage limits.

## Caveats
Complex/interface accuracy is lower and more variable than single-chain folds —
lean on ipTM/PAE, and validate ligand poses. Diffusion can produce plausible-looking
but wrong poses and occasional hallucinated/overlapping atoms. AF3 access is via a
usage-limited server with licensing restrictions; capabilities and versions move
fast, so pin the model version. Predictions are still single static states.

## See also
[[alphafold2-msa-structure-prediction]] · [[structure-confidence-plddt-pae]] · [[esmfold-protein-language-models]]
