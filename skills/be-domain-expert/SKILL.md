---
name: be-domain-expert
description: Consult the stored domain-knowledge base while working on any biology, biochemistry, genetics, genomics, bioinformatics, proteomics, machine-learning, or statistics task — recall what is already known before answering. Use by DEFAULT whenever a prompt touches a scientific/domain topic (check the base first); keywords include what do we know about, background, recall, prior knowledge, is there an entry for, domain question, plus any concept/tool/method name in the sciences above. To ADD or record new knowledge instead, use the domain-expert-learning skill.
---

# Be a Domain Expert

This skill makes you *use* the accumulated knowledge base: before working on a
domain topic, you consult what has already been distilled and verified, so you
answer from the team's compounded expertise instead of re-deriving it. Reading is
this skill's whole job — **writing/curating entries is a different skill**
(`domain-expert-learning`).

## Routing — which skill

On each task, decide first:

- **Is the task to build/record/curate knowledge?** (extract facts from a
  document, add an entry, update the base) → use **`domain-expert-learning`**.
- **Otherwise** — any normal task that merely *touches* a domain topic → this
  skill: consult the base, recall the relevant entries, and proceed.

Default to this skill. It is the every-session reflex; the builder is the
occasional, deliberate one.

## Where the base lives

The base is `domain-knowledge/` **inside this skill's own directory** — the base
directory shown when the skill loads (e.g.
`…/skills/be-domain-expert/domain-knowledge/`). It travels with the skill on
install (symlink *or* copy), so **reading it works in any project** regardless of
install mode. All paths below are relative to that skill directory, **not** the
current working project. (Writing new entries has an install-mode caveat — that is
the `domain-expert-learning` skill's concern, not this one.)

```
<skill dir>/domain-knowledge/
├── INDEX.md           # one line per entry — scan this first
├── README.md          # what the base is
├── _template.md       # entry template (used by the builder skill)
├── validate.py        # consistency check
├── biology/  biochemistry/  genetics/  genomics/  proteomics/
├── bioinformatics/    # + sub-areas: RNA-seq/  RIBO-seq/  scRNA-seq/
│                      #   root also holds nf-core assay workflows (ChIP/ATAC/
│                      #   variant/methyl/metagenomics) and cross-assay methods
├── machine-learning/  # + aging-clocks/
└── statistics/
```

Current coverage (see `INDEX.md` for the full, authoritative list): basic
biochemistry (protein structure, folding, amino acids, domains); genomics
reference conventions; proteomics (missingness, LFQ, DEP); Ribo-seq, scRNA-seq, and
protein-structure prediction (AlphaFold2/3, Boltz, ESMFold, pLDDT/PAE); nf-core
standard workflows for the main assays; ML methods and aging clocks; and a
statistics set spanning the ANOVA family, count-model normalization, and common
pitfalls (pseudoreplication, CV leakage, batch confounding).

## During the session — check recall on every prompt

Make recall a **reflex on each new prompt or sub-question**: before answering or
acting, ask *does this touch a domain topic the base might cover?* If plausibly
yes, **scan `INDEX.md` first** and read the matching entries before proceeding.

- It is cheap. `INDEX.md` is one line per entry — a quick scan, not a research
  detour. Do it inline; do not announce it as a step.
- It applies **continuously**, not just at task start. A mid-session question
  that opens a new topic gets the same check.
- **Skip** for purely non-domain prompts (unrelated coding, admin, chit-chat).
- If the retrieved knowledge is questionable for the current task, don't hesitate
  to pull it back. Visit later again

## Recall workflow

1. **Scan `INDEX.md`** for the topic — it is grouped by area, one line per entry.
2. **Read the matching entries.** Follow their `See also` `[[links]]`.
3. **Check freshness.** If an entry is load-bearing and its `updated` date is old,
   or `confidence` is `emerging`/`contested`, re-verify against a current source
   before relying on it — tool versions, releases, and consensus drift.
4. **Use it, and say so.** When an entry informs your answer, **name it** (e.g.
   "per `domain-knowledge/statistics/one-way-anova.md`") so the reasoning is
   traceable and the user sees the base being used.

## When the base has a gap

If a prompt reveals a durable fact the base is **missing**, or one that
**contradicts** an existing entry, that is a capture trigger — hand off to
**`domain-expert-learning`** to research, distil, and record it (or, if you have
just verified something durable in this session, note it for capture). Do not
silently answer from memory and move on when the fact was worth keeping.

## Reference

`reference.md` — the area map (what lives where) and how to navigate the base
quickly during a task.
