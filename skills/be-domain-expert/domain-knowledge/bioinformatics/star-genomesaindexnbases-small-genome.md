---
title: STAR --genomeSAindexNbases must shrink for small references
area: bioinformatics
tags: [star, indexing, genome-size, alignment, memory]
confidence: established
updated: 2026-07-18
sources:
  - STAR manual (alexdobin/STAR), genomeGenerate / --genomeSAindexNbases
  - verified empirically, BCbB worm setup (100 Mb → 12), 2026-07
---

## Fact
STAR's suffix-array pre-index length `--genomeSAindexNbases` defaults to 14,
which suits a mammalian-sized genome. For a smaller reference (a compact genome,
or a transcript/CDS FASTA) it must be reduced. The STAR manual gives:

```
min(14, floor(log2(GenomeLength) / 2 - 1))
```

Examples: a ~100 Mb genome → 12; a few-Mb transcript library → 8–9.

## Why it matters
Leaving the default of 14 on a small reference makes `genomeGenerate` allocate
absurd amounts of memory or fail outright. The value is not auto-scaled — the
caller must compute it from the actual reference length:

```bash
L=$(awk '/^>/{next}{t+=length($0)}END{print t}' ref.fa)
python3 -c "import math; print(min(14, int(math.log2($L)/2 - 1)))"
```

## Caveats
- This governs index build only; it does not change alignment results.
- `--sjdbOverhang` is a separate small-genome-independent knob (set from read
  length) and, unlike this one, is baked into the index and cannot be changed at
  alignment time.
- The formula is a recommendation; the practical requirement is simply "much
  smaller than 14 for a small reference".

## See also
[[reference-seqname-conventions]]
