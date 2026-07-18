# Skills For Computational Biologist

It is a set of skills and domain-specific knowledge that provides context for skill usage.

- **`skills/`** — agent skills for computational-biology tasks. See
  [`skills/README.md`](skills/README.md).
- **`skills/be-domain-expert/domain-knowledge/`** — a versioned base of durable
  domain facts, bundled inside (and installed with) the `be-domain-expert` skill.
  Two skills use it: `be-domain-expert` *consults* it during work, and
  `domain-expert-learning` *builds* it. See
  [its README](skills/be-domain-expert/domain-knowledge/README.md).

##  🚧 Note  🚧
This repository is under active development.
We are exploring ways to create more condensed context for each domain while developing better, simpler indexing architectures for Markdown files.

## Linking skills into an agent environment

An agent harness discovers skills by looking in a specific directory. This repo
supports two ways to expose `skills/` to one, at two different scopes.

### Every project (global install)

To make these skills available in **all** projects — and to other harnesses —
run the maintainer script [`scripts/link_skills.sh`](scripts/link_skills.sh). It
symlinks each skill directory into the per-user skill folders each harness reads:

```bash
scripts/link_skills.sh
#   ~/.claude/skills/<skill>  → <repo>/skills/<skill>   (Claude Code)
#   ~/.agents/skills/<skill>  → <repo>/skills/<skill>   (Codex / Agent-Skills harnesses)
```
