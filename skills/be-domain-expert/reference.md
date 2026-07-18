# be-domain-expert — Reference

Loaded only when `SKILL.md` points here. How to find the right entry fast during a
task, and what each area holds.

## Navigate

1. **`INDEX.md` is the map.** It is grouped by area and sub-area, one line per
   entry with a hook and `[confidence, updated]`. Read it whole (it is small) or
   jump to the area heading.
2. **Follow `[[links]]`.** Entries cross-reference related facts under `See also`;
   one relevant hit usually leads to the cluster you need.
3. **Grep when you know a term.** `grep -ri "<term>" <skill dir>/domain-knowledge`
   finds entries by tag or body text when the INDEX hook does not match your
   wording.

## Area map

| Area | Holds | Examples |
|---|---|---|
| `biology` | organisms, physiology, aging, development | molecular noise increases with age |
| `biochemistry` | molecules, structures, kinetics | ribosome footprint length |
| `genetics` | inheritance, variation, regulation | — |
| `genomics` | genome structure, references, annotation | seqname conventions across sources |
| `proteomics` | MS proteomics data + methods | MNAR imputation; LFQ log2; DEP |
| `bioinformatics` | tools, formats, algorithms, assay workflows | STAR flags; WGCNA; deconvolution; gene-ID mapping; nf-core assay pipelines; RNA-seq / RIBO-seq / scRNA-seq sub-areas |
| `machine-learning` | models + ML methodology | autoencoders; adversarial invariance; CV leakage; aging-clocks |
| `statistics` | analysis methods | ANOVA family; DESeq2/limma; batch correction; pseudoreplication; robust trends |

Areas nest; the top-level directory is the entry's `area`. Current sub-areas:

- **`bioinformatics/RNA-seq`, `/RIBO-seq`, `/scRNA-seq`, `/protein-structure`** —
  assay/method depth (Ribo-seq: periodicity, P-site, CDS alignment; scRNA-seq:
  mapping, barcode correction, UMI resolution; protein-structure: AlphaFold2/3,
  Boltz, ESMFold, pLDDT/PAE, MSA depth, limitations).
- **`bioinformatics/`** (root) also holds cross-assay method entries and the
  **nf-core standard workflows** — ChIP-seq, ATAC-seq, variant calling (sarek),
  bisulfite/methylation, amplicon (16S) and shotgun metagenomics.
- **`machine-learning/aging-clocks`** — transcriptomic/PC/elastic-net/BayesAge
  clocks, batch-transfer.

`INDEX.md` is the authoritative, always-current list — this table is orientation.

## Reading an entry

Each entry is four sections: **Fact** (the claim/number/mechanism), **Why it
matters** (when it is load-bearing), **Caveats** (where it breaks — read these
before relying on it), **See also** (links). The frontmatter `confidence` and
`updated` tell you how much to trust it as-is:

- `established` — textbook/consensus; use directly.
- `emerging` — recent, few sources; verify if load-bearing.
- `contested` — sources disagree; the entry states the disagreement, don't pick a
  side blindly.

## When to re-verify rather than trust

Consult the base first, but treat an entry as a strong prior, not gospel, when:
the `updated` date predates a tool/reference release you are using; the entry is
`emerging`/`contested`; or the decision it informs is expensive or hard to
reverse. Re-verify against a current primary source in those cases, and if the
fact has changed, hand off to `domain-expert-learning` to correct the entry.
