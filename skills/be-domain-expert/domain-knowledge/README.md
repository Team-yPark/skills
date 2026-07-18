# Domain Knowledge

A curated, versioned knowledge base of durable facts in biology, biochemistry,
genetics, genomics, proteomics, bioinformatics, machine learning, and the
statistics used to analyse them.

It exists so that research done once is not re-derived every session: each entry
distils a reusable fact — a mechanism, convention, tool behaviour, or number —
with its source, so it can be trusted and re-verified later.

Two skills work with this base: **`be-domain-expert`** *consults* it (recall — the
default every-session reflex) and owns this directory; **`domain-expert-learning`**
*builds* it (capture — research, distil, record an entry).

## Using it

- **Looking something up?** Start with [INDEX.md](INDEX.md) — one line per entry.
  Open the entries that match, follow their `See also` links.
- **Learned something durable?** Copy [`_template.md`](_template.md) into the
  right area directory, fill it in with a source, add a line to `INDEX.md`, then
  run the validator.

```bash
python3 validate.py
```

## What belongs here

Reusable scientific facts — true regardless of project. **Not** project/dataset
specifics (those go in the repo and `docs/log.md`), and **not** how-the-agent-
works notes (those are the agent's private memory). If a fact would not be just
as useful on a different project in six months, it does not belong here.

## Files at the root

```
domain-knowledge/
├── README.md       # this file
├── INDEX.md        # the map — every entry, one line, grouped by area. Scan first.
├── _template.md    # copy this to start a new entry
└── validate.py     # frontmatter + INDEX consistency check (run after any change)
```

## Subdirectory guide

Each top-level directory is an **area** (an entry's `area:` field must match its
top-level directory). Some areas nest **sub-areas** for a specific assay or method
family. `INDEX.md` is the authoritative, always-current list; this guide is for
orientation.

| Area | Holds | Sub-areas |
|---|---|---|
| `biology/` | organisms, physiology, aging, development | — |
| `biochemistry/` | molecules, structures, kinetics — incl. protein structure, folding, amino acids, domains | — |
| `genetics/` | inheritance, variation, gene regulation | *(placeholder — no entries yet)* |
| `genomics/` | genome structure, references, annotation + coordinate conventions | — |
| `proteomics/` | mass-spec proteomics data + methods (missingness, LFQ, DEP) | — |
| `bioinformatics/` | tools, formats, algorithms, and per-assay analysis workflows | `RNA-seq/`, `RIBO-seq/`, `scRNA-seq/`, `protein-structure/` |
| `machine-learning/` | ML models and methodology (representation learning, CV leakage, …) | `aging-clocks/` |
| `statistics/` | analysis methods (ANOVA family, normalization, robust/trend, pitfalls) | — |

### bioinformatics sub-areas

- **`RNA-seq/`** — bulk RNA-seq: splice-aware aligners (STAR/HISAT2/TopHat) and
  alignment-free transcript quantification (Salmon/Kallisto). (Some general RNA-seq
  facts also live at the `bioinformatics/` root and in `statistics/`.)
- **`RIBO-seq/`** — ribosome profiling: 3-nt periodicity, P-site offset +
  calibration, CDS-library alignment, 5′-nt trim, translation efficiency, pause.
- **`scRNA-seq/`** — single-cell raw processing: mapping/reference choice,
  cell-barcode correction, UMI resolution, quantification overview.
- **`protein-structure/`** — structure prediction from sequence: AlphaFold2,
  AlphaFold3/Boltz, ESMFold, pLDDT/PAE confidence, MSA depth, limitations.

The `bioinformatics/` root also holds cross-assay method and tooling entries
(STAR indexing, gene-ID mapping, WGCNA, deconvolution, **SAM/BAM/CRAM formats**,
**pysam/htslib**, gzip/FASTQ handling) and the **nf-core standard workflows**
(ChIP-seq, ATAC-seq, variant calling, bisulfite methylation, amplicon/shotgun
metagenomics).

### machine-learning sub-area

- **`aging-clocks/`** — biological-age predictors: transcriptomic clock, elastic
  net, PC regression, BayesAge, clock transfer / batch correction.

## Conventions

One fact per file; filenames are kebab-case slugs of the **claim**, not tool names
(`star-alignintronmax-genome-size.md`, not `star.md`). Each entry carries
`confidence` (established / emerging / contested) and an `updated` date — check
both before relying on an entry for anything load-bearing, because tool versions,
genome releases, and consensus all drift. Add a new area only when several entries
need it; add a sub-area when an assay/method accumulates its own cluster.

**Sourcing — bioinformatics entries must link the tool.** Every `bioinformatics/`
entry's `sources:` must carry the **GitHub repo or library homepage** for each
tool/library it describes (e.g. STAR → `https://github.com/alexdobin/STAR`,
Bioconductor packages → `https://bioconductor.org/packages/<name>`), not only the
paper citation. The paper explains the method; the repo is where an implementer
checks current flags, defaults, and versions. Keep both.
