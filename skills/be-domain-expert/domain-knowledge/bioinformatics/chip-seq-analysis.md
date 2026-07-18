---
title: ChIP-seq analysis — align, call peaks, consensus, QC
area: bioinformatics
tags: [chip-seq, peak-calling, macs2, frip, transcription-factor, histone]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/chipseq pipeline — https://github.com/nf-core/chipseq
  - Zhang et al. 2008, MACS (Genome Biology 9:R137) — https://github.com/macs3-project/MACS; ENCODE ChIP-seq guidelines
---

## Fact
ChIP-seq maps where a protein (transcription factor or histone mark) binds the
genome. Standard workflow: adapter/quality trim → align (BWA) → filter (remove
duplicates, multimappers, blacklist/mito reads) → **peak calling with MACS2**
against an input/IGG control → consensus peaks across replicates → annotate peaks
to genes and test differential binding.

- **Narrow peaks** for point-source factors (TFs); **broad peaks** (`--broad`) for
  diffuse histone marks (H3K27me3, H3K36me3).
- A matched **input control** is essential — it models the background so enriched
  regions are real binding, not open chromatin or copy-number artefacts.

## Why it matters
Skipping the input control or mis-choosing narrow vs broad gives systematically
wrong peaks. QC is quantitative and standardized: **FRiP** (fraction of reads in
peaks), strand cross-correlation (NSC/RSC), and library complexity flag failed
ChIPs before biological interpretation.

## Caveats
FRiP and peak counts depend on the peak-calling settings, so compare to standards
(ENCODE) only when the processing matches. Antibody quality dominates results —
no pipeline rescues a bad ChIP. Consensus-peak stringency (min replicates) trades
sensitivity for reproducibility. Blacklist regions must be removed or they
generate false peaks.

## See also
[[atac-seq-analysis]] · [[nf-core-standardized-pipelines]] · [[reference-seqname-conventions]]
