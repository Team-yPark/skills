---
title: P-site offset calibration by start-codon metagene (riboWaltz two-step)
area: bioinformatics
tags: [ribo-seq, p-site, calibration, metagene, ribowaltz]
confidence: established
updated: 2026-07-18
sources:
  - Lauria et al. 2018, riboWaltz (PMC6112680)
  - Xiao et al. 2019, integer-programming A/P-site (PMC6472398)
---

## Fact
Per-length P-site offsets are calibrated empirically from a **metagene profile
of 5′-read-ends around the annotated start codon**, using a two-step algorithm
(riboWaltz, and the same logic in most tools):

1. **Per-length peak.** Accumulate 5′-end coverage in a window around the AUG
   (e.g. [−50, +150] nt). For each read length, take the dominant local maximum
   in the upstream region (~[−30, −5] nt) as that length's initial offset — this
   is the ribosome's 5′ overhang.
2. **Cross-length correction.** Compute a global consensus offset
   (read-abundance-weighted mode across lengths); for each length pick the local
   maximum nearest the consensus. This pulls low-coverage lengths toward the
   biologically coherent offset instead of a noisy peak.

## Why it matters
Offsets vary by organism, ribosome, and digestion conditions, so copying a
published table is unreliable — calibrate per dataset. The cross-length step is
what makes the result robust: individual low-count lengths often have spurious
peaks that the consensus overrides. Alternatives exist (change-point analysis;
integer programming over (length, frame)) but the start-codon metagene is the
common denominator.

## Caveats
Needs enough start-proximal reads; genes with strong start-codon pausing can
bias the peak. A common bug: a "rescue" that swaps to a higher-in-frame offset
even when it still fails the periodicity threshold — only rescue to an offset
that actually passes, else keep the metagene-peak offset.

## See also
[[psite-offset]] · [[three-nt-periodicity]]
