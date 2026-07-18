# Domain Knowledge

A curated, versioned knowledge base of durable facts in biology, biochemistry,
genetics, genomics, bioinformatics, and the statistics used to analyse them.

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

## Layout

```
domain-knowledge/
├── INDEX.md        # the map — scan this first
├── _template.md    # copy to start an entry
├── validate.py     # frontmatter + INDEX consistency check
├── biology/        biochemistry/   genetics/
└── genomics/       bioinformatics/  statistics/
```

One fact per file; filenames are slugs of the claim, not tool names. Each entry
carries `confidence` (established / emerging / contested) and an `updated` date —
check both before relying on an entry for anything load-bearing, because tool
versions, genome releases, and consensus all drift.
