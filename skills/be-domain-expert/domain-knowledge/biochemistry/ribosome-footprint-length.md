---
title: Ribosome footprint length is ~28–30 nt
area: biochemistry
tags: [ribosome, footprint, ribo-seq, rpf, translation]
confidence: established
updated: 2026-07-18
sources:
  - Ingolia et al. 2009, Science 324:218 (PMID 19213877)
---

## Fact
An elongating 80S (or 70S) ribosome physically shields a discrete stretch of
mRNA from nuclease digestion. That protected fragment — the ribosome-protected
fragment (RPF), or "footprint" — is **~28–30 nt** for the canonical elongating
state (broader window ~26–34 nt across protocols/organisms). Ribo-seq recovers
translation genome-wide by sequencing exactly these footprints. The tight,
non-random length distribution is a physical constraint of the ribosome, not a
library artefact.

## Why it matters
The footprint length dictates preprocessing choices that differ sharply from
RNA-seq: trim to a narrow length window (e.g. 22–36 nt) instead of leaving reads
untrimmed, and expect a peaked length histogram — a broad or shifted one signals
degradation or over/under-digestion. The length also sets the P-site offset scale
(~12 nt from the 5′ end).

## Caveats
The exact peak shifts with nuclease (MNase vs RNase I), drug (cycloheximide vs
none), ribosome state (initiating ~a few nt longer; disome/collided footprints
~2× length), and organism. Treat ~28–30 nt as the elongating-monosome default,
not a universal constant.

## See also
[[psite-offset]] · [[three-nt-periodicity]] · [[5prime-nontemplated-nt-trim]]
