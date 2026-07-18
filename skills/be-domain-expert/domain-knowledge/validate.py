#!/usr/bin/env python3
"""Validate the domain-knowledge base: frontmatter completeness + INDEX consistency.

No external dependencies (frontmatter is parsed by hand, not via PyYAML).

Areas may be nested (e.g. bioinformatics/RIBO-seq/foo.md); the "area" of an entry
is its TOP-LEVEL directory under domain-knowledge/, and sub-directories below it
are free-form topic groupings.

Checks, per entry (every *.md under an area directory except README/INDEX/_template):
  - has a YAML frontmatter block
  - required fields present: title, area, tags, confidence, updated, sources
  - area matches the top-level directory
  - confidence is one of established | emerging | contested
  - updated is an ISO date (YYYY-MM-DD)
  - sources is non-empty
  - the entry is linked from INDEX.md (by its path relative to domain-knowledge/)

And, across the base:
  - every file linked from INDEX.md exists

Exit status is non-zero if anything fails, so it can gate a commit or CI.

Usage:
    python3 domain-knowledge/validate.py
"""
import datetime
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent
NON_ENTRY = {"README.md", "INDEX.md", "_template.md"}
REQUIRED = ["title", "area", "tags", "confidence", "updated", "sources"]
CONFIDENCE = {"established", "emerging", "contested"}


def base_in_git_worktree():
    """True if this base sits inside a git working tree (the canonical,
    contributable checkout — even if files are not yet committed); False if it is
    a detached copy outside any repo (e.g. a copy-based skill install); None if
    git is unavailable. A symlink install resolves to the repo path via
    __file__.resolve(), so it reads as True."""
    try:
        r = subprocess.run(
            ["git", "-C", str(ROOT), "rev-parse", "--is-inside-work-tree"],
            capture_output=True, text=True)
        return r.returncode == 0 and r.stdout.strip() == "true"
    except FileNotFoundError:
        return None


def parse_frontmatter(text):
    """Return (fields, error). Minimal YAML: scalars and simple lists."""
    if not text.startswith("---"):
        return None, "no frontmatter block (must start with '---')"
    end = text.find("\n---", 3)
    if end == -1:
        return None, "frontmatter block not closed with '---'"
    body = text[3:end].strip("\n")

    fields, key = {}, None
    for raw in body.split("\n"):
        if not raw.strip():
            continue
        if re.match(r"^\s+-\s+", raw):  # list item under the previous key
            if key is None:
                return None, "list item before any key"
            fields.setdefault(key, [])
            if isinstance(fields[key], list):
                fields[key].append(raw.strip()[1:].strip())
            continue
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", raw)
        if not m:
            return None, f"unparseable line: {raw!r}"
        key, val = m.group(1), m.group(2).strip()
        if val == "":
            fields[key] = []            # list follows, or empty
        elif val.startswith("[") and val.endswith("]"):
            inner = val[1:-1].strip()
            fields[key] = [x.strip() for x in inner.split(",") if x.strip()]
        else:
            fields[key] = val
    return fields, None


def index_targets(index_path):
    """Relative paths linked from INDEX.md, e.g. bioinformatics/foo.md."""
    if not index_path.exists():
        return set()
    text = index_path.read_text()
    return set(re.findall(r"\]\(([^)]+\.md)\)", text))


def main():
    errors = []
    areas = [d for d in ROOT.iterdir() if d.is_dir() and not d.name.startswith("_")]
    linked = index_targets(ROOT / "INDEX.md")
    entries = []

    for area in sorted(areas):
        for md in sorted(area.rglob("*.md")):        # recurse into topic sub-dirs
            if md.name in NON_ENTRY:
                continue
            rel = md.relative_to(ROOT).as_posix()    # e.g. bioinformatics/RIBO-seq/x.md
            entries.append(rel)
            fields, err = parse_frontmatter(md.read_text())
            if err:
                errors.append(f"{rel}: {err}")
                continue

            for f in REQUIRED:
                if f not in fields or (isinstance(fields[f], str) and not fields[f]):
                    errors.append(f"{rel}: missing/empty frontmatter field '{f}'")

            if fields.get("area") and fields["area"] != area.name:
                errors.append(
                    f"{rel}: area '{fields['area']}' != top-level directory '{area.name}'")
            if fields.get("confidence") and fields["confidence"] not in CONFIDENCE:
                errors.append(
                    f"{rel}: confidence '{fields['confidence']}' not in {sorted(CONFIDENCE)}")
            if fields.get("updated"):
                try:
                    datetime.date.fromisoformat(str(fields["updated"]))
                except ValueError:
                    errors.append(f"{rel}: updated '{fields['updated']}' is not YYYY-MM-DD")
            if not fields.get("sources"):
                errors.append(f"{rel}: sources is empty — every claim needs a source")

            if rel not in linked:
                errors.append(f"{rel}: not linked from INDEX.md (invisible to recall)")

    for tgt in sorted(linked):
        if not (ROOT / tgt).exists():
            errors.append(f"INDEX.md links '{tgt}' but the file does not exist")

    if errors:
        print(f"FAIL — {len(errors)} problem(s):")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(f"OK — {len(entries)} entr{'y' if len(entries)==1 else 'ies'}, "
          f"INDEX consistent")

    # Capture-safety advisory (non-fatal): a base that is not a tracked file in a
    # git working tree is a detached/copied install — new entries written here are
    # local-only and will NOT reach the team via git. Reads are fine either way.
    if base_in_git_worktree() is False:
        print("ADVISORY: this base is not in a git working tree — a detached/copied install.")
        print("  New entries are local-only; contribute them to the source repo")
        print("  (or install the skills by symlink so writes land in the repo).")

    return 0


if __name__ == "__main__":
    sys.exit(main())
