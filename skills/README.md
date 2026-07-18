# BCbB Skills

Skills for coding agents. Each one carries general, reusable knowledge for a kind
of task — patterns, tool flags, and the pitfalls worth knowing — so an agent
building something new does not have to re-derive it.

## Layout

Skills live at `skills/` in the repo root; `.claude/skills` is a symlink to it,
which is how Claude Code discovers them. Either path works — they are the same
directory. Note that `find` and `ls -R` do not follow the symlink by default, so
inspect `skills/` directly rather than `.claude/skills/`.

```
skills/                          ← real location  (.claude/skills → here)
├── README.md                    # this file
├── new-skill.sh                 # scaffolds a new skill from the template
├── _template/                   # not a live skill — .template suffix keeps it inert
│   ├── SKILL.md.template
│   └── reference.md.template
└── <skill-name>/
    ├── SKILL.md                 # required; name: must match the directory name
    ├── reference.md             # optional; deeper reference, loaded on demand
    ├── <topic>.md               # optional; extra reference docs (any name SKILL.md points to)
    └── assets/                  # optional; runnable files the skill copies/adapts
```

A skill is a directory containing `SKILL.md`. Beyond that it may carry any number
of reference docs (e.g. `seq-download-preprocess/` has `reference.md` and
`nf-core.md`) and an `assets/` folder of runnable, tested files the skill hands
out or adapts (e.g. a `lib/common.sh` baseline, a pipeline template, a test-data
generator). SKILL.md loads first; everything else is read only when it points there.

For how `skills/` is linked into an agent's skill directory (the repo-local
`.claude/skills` symlink, and the global-install script for all projects), see
the "Linking skills into an agent environment" section of the repo-root
[`README.md`](../README.md).

## Available skills

| Skill | Use for | Ships |
|---|---|---|
| `seq-download-preprocess` | Writing or debugging sequencing download + preprocessing scripts (SRA/GEO → trim → contaminant filter → align → BAM) | `reference.md`, `nf-core.md`, `assets/` (lib/common.sh baseline, pipeline template, synthetic-test-organism generator) |
| `organism-reference-setup` | Acquiring organism reference data (genome/GTF) from Ensembl/UCSC/NCBI/GENCODE, building indexes, wiring paths into `lib/common.sh` | `reference.md` |
| `protein-structure-prediction` | Predicting/analyzing protein 3D structure from sequence — model choice (AlphaFold2/ColabFold, AlphaFold3, Boltz, ESMFold), running, and pLDDT/PAE interpretation | `reference.md` |
| `be-domain-expert` | **Consulting** the domain-knowledge base while doing any domain task — recall what's known before answering (the default every-session reflex). Owns the base. | `reference.md`, `domain-knowledge/` (the base itself) |
| `domain-expert-learning` | **Building** the base — research a durable fact, distil it, record a sourced entry. Writes into `be-domain-expert`'s base. | `reference.md` |

Skills may call each other: `seq-download-preprocess` depends on references that
`organism-reference-setup` produces. The two knowledge skills are a **use/build
pair**: `be-domain-expert` reads the base (and is the default whenever a prompt
touches a domain topic); `domain-expert-learning` writes to it. The base is
**bundled inside `be-domain-expert`** (`domain-knowledge/`) so it travels with the
skill on install; the builder writes to it via the sibling path
`../be-domain-expert/domain-knowledge/`. Routing rule: if a task is to *build/record*
knowledge use `domain-expert-learning`, otherwise use `be-domain-expert`.

**The base currently covers** (see `domain-knowledge/INDEX.md` for the live list):
genomics reference conventions; **biochemistry** (protein structure levels,
Anfinsen, amino acids, domains); proteomics (missingness, LFQ, differential
expression); bioinformatics assay workflows — RNA-seq, **Ribo-seq** (periodicity,
P-site, CDS alignment), **scRNA-seq** (mapping, cell-barcode/UMI resolution,
quantification), **protein-structure prediction** (AlphaFold2/3, Boltz, ESMFold,
pLDDT/PAE), and the **nf-core standard pipelines** (ChIP-seq, ATAC-seq, variant
calling, bisulfite methylation, amplicon 16S / shotgun metagenomics); machine-
learning methods and **aging clocks**; and a statistics set spanning the **ANOVA
family**, count-model normalization, and common pitfalls (pseudoreplication,
cross-validation leakage, batch confounding).

## Creating a skill

```bash
skills/new-skill.sh my-skill
$EDITOR skills/my-skill/SKILL.md
```

That copies the template, strips the `.template` suffix, and sets `name:` to
match the directory. Fill in the frontmatter, then delete the preset blocks you
do not need. Start a new Claude Code session to pick up the skill.

## Frontmatter

| Field | Required | Notes |
|---|---|---|
| `name` | yes | kebab-case, matches the directory name |
| `description` | yes | third person, states **what** it does and **when** to use it |
| `allowed-tools` | no | restricts the skill to a tool subset, e.g. `Bash, Read, Grep` |

The `description` is the only part loaded into context up front — it is what the
agent matches against to decide whether to invoke the skill. Write it with the
words a user would actually type. `"Processes Ribo-seq FASTQ files"` is weak;
`"Runs the Ribo-seq preprocessing pipeline (SRA download, fastp trim, rRNA
depletion, STAR alignment). Use when the user mentions Ribo-seq, ribosome
profiling, GEO/SRA accessions, or riboseq preprocessing."` is what gets matched.

## Progressive disclosure

`SKILL.md` is loaded in full once the skill triggers, so keep it under ~500
lines. Anything long — full parameter tables, per-organism settings, background
theory — goes in a sibling file that `SKILL.md` points to, and the agent reads
it only if needed:

```markdown
For per-organism STAR settings, read `reference.md`.
```

## Scope

Skills carry **general, reusable knowledge** for future work — patterns, flag
rationale, and pitfalls that transfer across datasets. They are not a place for
one dataset's parameters or one study's conclusions.

`workbench/` holds temporary reference material. **Never point a skill at it.**
When a skill needs something from there, copy the extracted block or text into
the skill's own folder (`assets/` for runnable files) so the skill survives
workbench being cleared.

## Conventions

- Pipeline scripts are named `run_<order>_<topic>.sh` and source `lib/common.sh`.
- Scripts are idempotent: every step is skipped when its output already exists.
- Reference data lives under `data/`, results under a user-supplied `-o` dir.
- Long-running commands are the user's to launch, not the agent's — a skill
  should print the command and let the user run it unless told otherwise.
