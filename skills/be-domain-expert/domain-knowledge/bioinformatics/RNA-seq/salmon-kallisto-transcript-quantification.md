---
title: Salmon and Kallisto — alignment-free transcript quantification
area: bioinformatics
tags: [salmon, kallisto, pseudoalignment, quantification, tpm, tximport, rna-seq]
confidence: established
updated: 2026-07-18
sources:
  - Bray et al. 2016, kallisto (Nat Biotechnol 34:525) — https://github.com/pachterlab/kallisto; Patro et al. 2017, Salmon (Nat Methods 14:417) — https://github.com/COMBINE-lab/salmon
  - Soneson et al. 2015, tximport (F1000Research 4:1521) — https://bioconductor.org/packages/tximport
---

## Fact
Salmon and Kallisto are **not aligners** — they quantify transcript abundance
**without base-level alignment**. They map reads to a **transcriptome** by
*pseudoalignment* (Kallisto) / *selective alignment* (Salmon) — identifying which
transcripts a read is compatible with (its equivalence class) rather than where
exactly — then resolve reads shared between isoforms with an **EM algorithm** to
estimate per-transcript abundance. Output: **TPM + estimated counts** per
transcript, plus **bootstrap/Gibbs replicates** for inferential uncertainty.

They are ~10–100× faster and far lighter than genome alignment. **Salmon** adds
**decoy-aware** indexing (the genome as decoy, so reads from unannotated regions
aren't force-mapped) and **GC/sequence-bias** correction; **Kallisto** is pure
pseudoalignment with bootstraps (paired with sleuth for DE).

## Why it matters
When you want expression, not a BAM, this is the fast, accurate default — and it
handles isoform-level assignment better than counting genome alignments. Because it
quantifies against the transcriptome, it needs no splice-aware alignment at all.

## Caveats
Estimated counts are **fractional, not integers**, and carry an **effective-length**
offset — feed them to DESeq2/edgeR via **tximport** (which builds the offset), not
as raw counts ([[count-models-need-raw-counts]]). Quality depends entirely on the
**transcriptome annotation**: unannotated/novel transcripts are missed, and you
cannot recover novel junctions, coverage tracks, or variants (use a genome aligner
for those, [[rna-seq-aligners-star-hisat2-tophat]]). Pseudoalignment without decoys
mis-assigns reads from intronic/intergenic RNA — prefer Salmon's decoy-aware mode.

## See also
[[rna-seq-aligners-star-hisat2-tophat]] · [[count-models-need-raw-counts]] · [[scrna-mapping-reference-choice]] · [[translation-efficiency]]
