---
title: scRNA-seq mapping — reference type sets what you can measure
area: bioinformatics
tags: [scrna-seq, mapping, alignment, pseudoalignment, reference, rna-velocity, snrna-seq]
confidence: established
updated: 2026-07-18
sources:
  - Heumos et al. 2023, sc-best-practices (Nat Rev Genet 24:550) — https://www.sc-best-practices.org/introduction/raw_data_processing.html
  - Srivastava et al. 2020 (alevin selective alignment, https://github.com/COMBINE-lab/salmon); Melsted et al. 2021 (kallisto|bustools, https://github.com/BUStools/bustools); STARsolo https://github.com/alexdobin/STAR
---

## Fact
The read-mapping step for droplet scRNA-seq differs by **reference** and **method**,
and the choice is not just speed:

| Reference | Method (tools) | Captures | Cost |
|---|---|---|---|
| Full genome | spliced alignment (STAR/STARsolo, Cell Ranger) | exonic **+ intronic** reads | slow, memory-heavy |
| Spliced transcriptome | pseudo/selective alignment (kallisto\|bustools, alevin) | exonic only | very fast |
| **Augmented** transcriptome (spliced + intronic/unspliced, decoy-aware) | selective alignment (alevin-fry) | exonic + intronic | fast |

Lightweight mapping (pseudoalignment) produces no per-read quality score and, on a
plain transcriptome, yields spurious mappings — the augmented/decoy-aware reference
is the modern compromise that keeps speed while cutting false mappings.

## Why it matters
Intronic reads are **required** for single-nucleus RNA-seq (mostly pre-mRNA) and
for **RNA velocity** (spliced vs unspliced ratio). A transcriptome-only reference
silently discards them, so the reference choice constrains which downstream
analyses are even possible — decide it up front, not after quantifying.

## Caveats
Pseudoalignment trades interpretable mapping quality for ~10–100× speed. Different
mappers give systematically different matrices — pin the tool and reference build.
Genome alignment is heavier but the only fully general choice; augmented
transcriptomes need the extra build step.

## See also
[[single-cell-rnaseq-quantification]] · [[scrna-umi-resolution]] · [[scrna-barcode-correction]]
