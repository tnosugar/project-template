# website/

The project's primary web presence — standalone HTML pages served by GitHub Pages via the public mirror. One of several top-level channel folders (see `.claude/conventions.md` §1); peers include `ads/`, `social/`, `email/`, `decks/`, etc.

Every page here traces back to a canonical doc in `content/` via that doc's `renders_to:` frontmatter field. Text on pages must not drift from the canonical source; if a page is edited directly, update the corresponding doc first and re-render.

Website pages reference brand assets from `../files/` (e.g. `../files/logo.svg`). Once enough brand assets accumulate to warrant a subdirectory they move to `../files/brand/` and page references update accordingly. Brand guidelines themselves live in `content/brand/` — not linked from website pages, since content is private.

See `.claude/conventions.md` §2 for page-level conventions (single-file, shared main nav, Inter font, viewport rules, no build step, no browser storage).

## Contents

- `home.html` — Home page; rendered from `content/home.md`.

<!-- As website/ grows, list additional pages here. Each entry names the page
and the canonical doc it renders from. When a sibling page is added, update
the main nav block in every HTML file so they all link to each other. -->
