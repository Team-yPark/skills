---
title: MSA depth and coevolution drive MSA-based prediction accuracy
area: bioinformatics
tags: [msa, coevolution, alphafold, structure-prediction, orphan-proteins, contacts]
confidence: established
updated: 2026-07-18
sources:
  - Jumper et al. 2021 (Nature 596:583); coevolution/contact-prediction literature — https://github.com/google-deepmind/alphafold
  - Lin et al. 2023, ESMFold (Science 379:1123) — https://github.com/facebookresearch/esm
---

## Fact
The signal that lets MSA-based predictors (AlphaFold2, RoseTTAFold) place residues
in 3D is **coevolution**: residues that physically contact in the fold tend to
mutate in a correlated way across homologs to preserve the structure. A deep,
diverse **multiple-sequence alignment (MSA)** exposes those correlations; a shallow
one does not. So prediction confidence rises with the **number and diversity of
homologous sequences** available for the target.

## Why it matters
It explains *when* AlphaFold works and fails: well-conserved proteins with hundreds
of homologs → high confidence; **orphan proteins, fast-evolving families, de-novo
designed proteins, and many viral/metagenomic sequences** have shallow MSAs → low
confidence, regardless of how "simple" the protein looks. Checking MSA depth up
front predicts whether an AF2 run is worth trusting. Single-sequence language
models (ESMFold) exist precisely to cover the shallow-MSA regime, trading some
accuracy for MSA-independence.

## Caveats
More sequences help only if they are **diverse and correctly aligned** — thousands
of near-identical sequences add little, and a bad alignment injects noise. Deep MSA
does not rescue genuinely disordered or multi-state proteins. Coevolution reflects
evolutionary constraint, which usually but not always equals a single native
contact map.

## See also
[[alphafold2-msa-structure-prediction]] · [[esmfold-protein-language-models]] · [[predicted-structure-caveats]]
