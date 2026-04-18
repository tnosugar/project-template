# website/

The project's primary web presence — standalone HTML pages served by GitHub Pages via the public mirror. One of several top-level channel folders (see `CLAUDE.md` §2); peers include `ads/`, `social/`, `email/`, `decks/`, etc.

Every page here traces back to a canonical doc in `docs/` via that doc's `renders_to:` frontmatter field. Text on pages must not drift from the canonical source; if a page is edited directly, update the corresponding doc first and re-render.

Website pages reference brand assets from `../brand/` (e.g. `../brand/logo.svg`). Brand guidelines themselves live in `docs/brand/` — not linked from website pages, since docs is private.

See `CLAUDE.md` §5 for page-level conventions (single-file, shared main nav, Inter font, viewport rules, no build step, no browser storage).

## Contents

- `home.html` — Home page; rendered from `docs/home.md`.

<!-- As website/ grows, list additional pages here. Each entry names the page
and the canonical doc it renders from. When a sibling page is added, update
the main nav block in every HTML file so they all link to each other. -->
