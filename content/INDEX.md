# content/ — PRIVATE ONLY

The source of truth for all authored markdown in this project: strategy, research, briefs, decisions, copy drafts and final approved text, brand guidelines, process docs, service definitions, reference sheets. Nothing in `content/` is ever publicly mirrored — this folder is never listed in `.sync-public.yml`.

Every `.md` file here starts with YAML frontmatter (schema in `.claude/SCHEMA.md`; mechanics in `.claude/conventions.md` §1). Channel deliverables (a LinkedIn post's rendered screenshot, a sent email, a slide deck) live in their respective top-level channel folders; `content/` holds the canonical text those deliverables render or reference. Non-markdown raw assets (logos, palettes, photos, decks) live in `files/` at the repo root.

See `.claude/conventions.md` §1 for the canonical subfolder taxonomy, the "split at three" rule, and the frontmatter schema.

## Contents

- `home.md` — Home page spec; renders to `website/home.html`.

<!-- As content/ grows, list subfolders here too with one-line descriptions, e.g.:

## Subfolders

- `strategy/` — strategic positioning, market analysis, business framing.
- `research/` — source material, interviews, reading notes, raw inputs.
- `copy/` — canonical text destined for external channels; organized by channel (social/, email/, ads/, sms/, decks/, website/) and where applicable by platform (linkedin/, x/, google/, meta/, …).
- `briefs/` — short briefs that direct production work.
- `decisions/` — long-form decision records that exceed what fits in CLAUDE.md §5.
- `brand/` — brand guidelines (voice, visual principles, usage rules). Asset files live in top-level files/.
- `process/` — organizational process design docs.
- `services/` — service definitions (one file per named offer; typical frontmatter: type: reference, isa: [service]).
- `concepts/` — optional concept / framework stubs for isa: targets represented as graph nodes.

Each subfolder gets its own INDEX.md the moment it's created. Update both
this file and the subfolder's INDEX.md whenever a doc is added, moved, or retired. -->
