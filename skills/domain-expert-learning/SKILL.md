---
name: domain-expert-learning
description: Builds and curates the domain-knowledge base — researches a durable scientific fact, distils it, and records it as a sourced entry (biology, biochemistry, genetics, genomics, proteomics, bioinformatics, machine-learning, statistics). Use when the task is to ADD, record, extract, or update domain knowledge — keywords include record this, add to the knowledge base, extract domain knowledge from these docs, capture this fact, write a domain-knowledge entry, curate, remember this for future work. To merely CONSULT existing knowledge while doing other work, use the be-domain-expert skill instead.
---

# Domain Expert Learning

Turns one-off research into a compounding, reusable knowledge base. This skill is
the **build** side: after learning something durable, you distil it into one
small, sourced markdown entry so the team never re-derives it. **Consulting** the
base while doing other work is a different skill (`be-domain-expert`).

## Routing — which skill

- **Building/recording knowledge** (add an entry, extract facts from a document,
  correct or update the base) → **this skill**.
- **Just consulting** the base during a normal task → **`be-domain-expert`**.

If a task is "read the docs in X and save what's reusable," that is this skill.
If it is "do task Y" and Y happens to touch a domain topic, that is
`be-domain-expert` (it will hand off to this skill when it finds a gap worth
recording).

## Where the base lives

One base, owned by the `be-domain-expert` skill and shared by both. It is
`domain-knowledge/` **inside the `be-domain-expert` skill directory** — a sibling
of this skill:

```
skills/
├── be-domain-expert/
│   └── domain-knowledge/     ← the base you write into (INDEX.md, validate.py, area dirs)
└── domain-expert-learning/   ← this skill
```

Write to `../be-domain-expert/domain-knowledge/` relative to this skill's base
directory (both skills install together, so the sibling path resolves — under
symlink *and* copy installs, since both skills land side by side). Resolve it
against the skill directory, **not** the current working project.

### Install mode matters for captures (not for reads)

The base is canonical only when it is a live **git working tree** — i.e. you are
in the repo, or the skills were installed by **symlink** into it (the repo's
`scripts/link_skills.sh` does this). Then a new entry lands in the repo and a
commit/PR shares it with the team.

On a **copy-based** skill install (some Agent-Skills CLIs copy the skill dir), the
base is a detached per-machine copy: reads still work, but a captured entry is
**local-only** and never reaches git. The validator (capture step 6) detects this
and prints an `ADVISORY`. When you see it, do not consider the capture "done" —
recreate the entry in the source repo (or re-install the skills by symlink) so the
knowledge is actually shared. Never write into a detached copy and assume the team
has it.

## Scope: what belongs here

**The base holds external, reusable scientific facts** — true regardless of which
project you are in: mechanisms, definitions, conventions, tool behaviours,
parameter rationale, numeric constants, method trade-offs.

It is **not**:

- **Project or dataset specifics** — "our GSE184209 adapter is X", "this run used
  25 samples". Those live in the repo, `docs/log.md`, or the code.
- **How-I-work / user / feedback facts** — those go in the built-in memory
  (`~/.claude/.../memory/`). The base is versioned in the repo and shared with the
  team; memory is private and cross-project.
- **A search-result dump.** An entry is the distilled claim, not the page it came
  from.

Quick test before writing: *would this fact be just as true and useful on a
different project six months from now?* If no, it does not belong here.

## Entry format

Copy `domain-knowledge/_template.md`. One fact per file; filenames are kebab-case
slugs of the **claim** (`star-alignintronmax-genome-size.md`), not vague nouns
(`star.md`) — a file named after a whole tool becomes a dumping ground. Frontmatter,
all fields required:

```yaml
---
title: <the claim or concept, in a few words>
area: bioinformatics          # the TOP-LEVEL area dir (sub-topics may nest, e.g. bioinformatics/RIBO-seq/)
tags: [rna-seq, alignment, star]
confidence: established        # established | emerging | contested
updated: 2026-07-18            # ISO date; the fact's freshness
sources:
  - <citation, URL, or "verified empirically, <where>, <date>">
---
```

Body — four short sections, in this order:

```markdown
## Fact
<The distilled knowledge. A few sentences or a small table — the number, rule, or
mechanism you'd want without reading anything else.>

## Why it matters
<When this is load-bearing — the decision it changes, the failure it prevents.>

## Caveats
<Where it breaks, the exceptions, the contested edge. A fact with no caveats is
usually under-examined.>

## See also
<[[other-entry-slug]] links to related entries. Link liberally.>
```

If an entry grows past ~40 lines it is probably two facts; split it. `sources` is
not optional — an unsourced scientific claim is not trustworthy, and a future
reader must be able to re-verify it.

## Capture workflow

1. **Research.** Prefer primary/authoritative sources — official tool docs,
   textbooks, peer-reviewed papers, database documentation — over blogs and forum
   answers. Use WebSearch/WebFetch when available; cite what you verified
   empirically when you tested it yourself.
2. **Distil.** Reduce to the load-bearing claim: the number, rule, mechanism,
   trade-off. Discard the prose. If you cannot state it in a few sentences you do
   not understand it yet.
3. **Check for an existing entry.** Update rather than duplicate. If it
   contradicts one, resolve the conflict — correct the old entry, or mark both
   `contested` with the disagreement stated.
4. **Write** the file from `_template.md`; fill every frontmatter field, cite the
   source, set `confidence` honestly.
5. **Add one line to `INDEX.md`** under the area heading.
6. **Run the validator** — `python3 <be-domain-expert dir>/domain-knowledge/validate.py`
   (it locates the base from its own path). Catches missing frontmatter,
   area/directory mismatch, and INDEX drift.

## Confidence, honestly

- `established` — textbook / consensus / official documented behaviour.
- `emerging` — recent, plausible, not yet settled; few sources.
- `contested` — sources disagree, or it is method-dependent. State the
  disagreement in the entry rather than silently picking a side.

Downgrading is fine. If you later find an entry was wrong, correct it and note
what changed — a base people cannot trust to be current is worse than none.

## Anti-patterns

- **Dumping a search result verbatim.** Distil, or do not write.
- **A file per tool instead of per claim.** `star.md` rots; write the claim.
- **Unsourced claims.** No source, no entry.
- **Storing project specifics.** Wrong base — see Scope.
- **Writing without checking for a duplicate.** Update, do not fork.
- **Letting INDEX drift.** An entry not in INDEX is invisible to recall. Run the
  validator.

## Reference

`reference.md` — the area taxonomy, a worked capture example (search → distilled
entry), and source-quality guidance for this domain.
