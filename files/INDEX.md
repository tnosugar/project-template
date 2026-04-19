# files/

Non-markdown raw assets that the rest of the repo references: logos, color palette definitions, typography files, icon sets, favicons, photos, decks, PDFs, anything binary or structured-data. Flat by default; subdirectories grow organically when a cluster of related assets reaches enough mass to earn one (e.g. `files/brand/` once several brand assets accumulate, `files/photos/` for a photo library).

Every channel (`website/`, `ads/`, `social/`, `email/`, `decks/`, …) references these with relative paths like `../files/logo.svg` or `../../files/palette.json`.

Brand GUIDELINES (how to use these assets: voice, visual principles, layout rules, dos and don'ts) live in `content/brand/` as markdown — this folder is just the physical assets.

See `.claude/conventions.md` §1 for where `files/` sits in the overall repo layout.

## Contents

*(Empty — populate during project setup. Typical shape below.)*

<!-- Typical files/ contents once populated:

- `logo.svg`            — Primary logo, scalable.
- `logo-dark.svg`       — Primary logo for dark backgrounds.
- `logo-monochrome.svg` — Single-color fallback.
- `favicon.ico`         — Favicon for the website.
- `palette.json`        — Color palette (HEX/RGB values for named colors like "ink", "paper", "accent").
- `fonts/`              — Font files (.woff2), if not using Google Fonts.
- `icons/`              — Named icon set (SVG sources).

Once more than a handful of brand assets accumulate, promote them into a
`files/brand/` subdirectory. Same for photos (`files/photos/`), decks
(`files/decks/`), etc. The split-at-three rule from conventions.md applies.

Keep this INDEX.md in sync with actual folder contents. When an asset is
added, renamed, or retired, update this list so every channel that
references it can find what it needs. -->
