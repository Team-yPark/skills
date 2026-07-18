---
title: Bisulfite sequencing measures DNA methylation via C→T conversion
area: bioinformatics
tags: [methylation, bisulfite, bismark, cpg, epigenetics, methylseq]
confidence: established
updated: 2026-07-18
sources:
  - nf-core/methylseq pipeline — https://github.com/nf-core/methylseq
  - Krueger & Andrews 2011, Bismark (Bioinformatics 27:1571) — https://github.com/FelixKrueger/Bismark
---

## Fact
Bisulfite treatment converts **unmethylated cytosine → uracil → thymine** while
**methylated cytosine (5mC) is protected** and stays C. Methylation is then read
out as the C/T ratio at each cytosine. Workflow (methylseq):

1. Trim (Trim Galore).
2. **Three-letter alignment** — Bismark converts all C→T *in silico* in both reads
   and reference, aligns in that reduced alphabet (via Bowtie2), so
   methylation state does not bias mapping.
3. **Methylation calling** by cytosine context: **CpG** by default (the mammalian
   regulatory context); `--comprehensive` adds CHG/CHH (relevant in plants).
4. Per-cytosine **% methylation** = methylated / total coverage → bedGraph/coverage.

## Why it matters
Naively aligning bisulfite reads fails: C→T conversion makes reads mismatch the
reference everywhere unmethylated. The three-letter reduction is what makes
mapping unbiased. Context matters — reporting CHH methylation as if it were CpG
misreads plant vs mammalian biology.

## Caveats
Incomplete bisulfite conversion inflates apparent methylation — check the
conversion rate (often via a spike-in or the CHH rate). Bisulfite degrades DNA and
reduces complexity; coverage per cytosine is the limiting factor for calling.
5mC and 5hmC are indistinguishable by standard bisulfite (needs oxBS/TAB).
Differential methylation (DMR) testing is a separate statistical step.

## See also
[[germline-somatic-variant-calling]] · [[nf-core-standardized-pipelines]]
