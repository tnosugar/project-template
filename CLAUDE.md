# CLAUDE.md — [TBD — Project Name]

This file is the working specification for the [TBD — project name] project. It is intended as the canonical orientation document for any Claude session working in this repository. Read it first before acting on any request that touches strategy, frameworks, copy, or web assets.

The spec is built iteratively through two-way Socratic questioning. Treat this as a living document: when something here is ambiguous, incomplete, or contradicted by a new decision, ask about it before acting, and update this file once the answer is clear.

---

## 0. FIRST-RUN BOOTSTRAP

**This section is removed once the project is initialized.** If you are reading this, the repo was just created from `tnosugar/project-template` and project-specific content has not been filled in yet.

Run this sequence in order. Each step is small; ask the user before moving to the next when there is ambiguity.

### Step 1 — Create the public mirror

This template assumes the two-repo pattern (see §10). The current repo is `{owner}/{project}-private`. Its public mirror is `{owner}/{project}-public`. Create the mirror now.

```bash
# Replace {owner} and {project} with the actual values.
gh repo create {owner}/{project}-public --public \
  --description "Public mirror of selected assets from {project}-private"
```

Then seed it with a single README commit so `main` exists (Pages and the sync workflow both need a branch to target):

```bash
gh api -X PUT repos/{owner}/{project}-public/contents/README.md \
  -f message="Initial README" \
  -f content="$(printf '# %s-public\n\nPublic mirror of selected assets from the private %s-private working repo. Auto-synced — do not edit directly.' "{project}" "{project}" | base64)"
```

### Step 2 — Generate the deploy keypair and install both halves

```bash
# Generate.
ssh-keygen -t ed25519 -C "{project}-public sync key" \
  -f ~/.ssh/{project}_public_sync -N ""

# Install public half on the public repo with write access.
gh api -X POST repos/{owner}/{project}-public/keys \
  -f title="{project}-private sync bot" \
  -f key="$(cat ~/.ssh/{project}_public_sync.pub)" \
  -F read_only=false

# Install private half as a secret on the private repo.
gh secret set PUBLIC_REPO_DEPLOY_KEY \
  -R {owner}/{project}-private \
  < ~/.ssh/{project}_public_sync
```

### Step 3 — Enable Pages on the public mirror

```bash
gh api -X POST repos/{owner}/{project}-public/pages \
  -f "source[branch]=main" \
  -f "source[path]=/"
```

### Step 4 — Run a Socratic discovery session

Walk the user through the project-specific sections (§1, §3, §4, §5 below — and, if they apply, §6+ for additional frameworks). Use the Socratic prompts embedded as HTML comments under each heading. For each section: ask the user the prompted questions, draft the answer in plain language, get sign-off, then replace the prompt with the drafted content.

Order to ask in:
1. §1 Project Purpose — one paragraph stating what this project is and why it exists.
2. §3 Project Snapshot — name, what it is, who it works with, how it shows up.
3. §4 Voice & Copy Conventions — derived from the user's existing materials if they have any; otherwise drafted from scratch and refined.
4. Add framework sections (§6+) as the user names them. Number them sequentially.

Keep §5 Web Asset Conventions, §7 Working Agreement, §8 Decisions Logged, §9 Open Questions, and §10 Two-Repo Pattern as they are. Add to §8 as decisions land during discovery.

### Step 5 — Update the README, manifest, and home assets

- Replace `[TBD — Project Name]` markers throughout `README.md`, `docs/home.md`, and `website/home.html`.
- Edit `.sync-public.yml` to reflect what should be public for this project (only channel-folder paths; `docs/` is private only).
- Run a first pass on `docs/home.md` and `website/home.html` to fill in the placeholders that have firm answers.

### Step 6 — Commit, push, verify

```bash
git add -A
git commit -m "Initialize {project}: filled in §1, §3, §4 of CLAUDE.md and home page placeholders"
git push origin main
```

The push triggers the sync workflow. Verify on the Actions tab that it succeeds, that `{project}-public` receives the manifest files, and that Pages serves at `https://{owner}.github.io/{project}-public/web/home.html`.

### Step 7 — Delete this section (§0)

Once everything above is done, remove §0 entirely from this file and renumber the remaining sections starting at §1. Commit the change with message: `Remove FIRST-RUN BOOTSTRAP section`.

---

## 1. Project Purpose

<!-- SOCRATIC: Ask the user for:
     - A one-line description of what this project is.
     - Why this project exists (the underlying problem or opportunity).
     - The two or three goals the work in this repo serves.
     Draft 2-3 paragraphs. Keep the standards line at the end ("Everything
     produced here should be held to the standards…"); make it project-specific. -->

[TBD — project purpose. See Socratic prompt above.]

---

## 2. Repository Layout

```
{project}-private/
├── CLAUDE.md                              # This file — project spec and working agreement
├── .sync-public.yml                       # Manifest: which paths sync to the public mirror
├── .github/
│   └── workflows/
│       └── sync-public.yml                # GitHub Action that mirrors manifest paths to the public repo
├── docs/                                  # PRIVATE ONLY — canonical written content
│   ├── INDEX.md
│   └── home.md
├── website/                               # The project's website — served by Pages via the public mirror
│   ├── INDEX.md
│   └── home.html
├── brand/                                 # Brand asset FILES (logos, palette, fonts) — guidelines in docs/brand/
│   └── INDEX.md
└── [channel folders]                      # Created on demand — see "Top-level channel folders" below
```

**The two halves of the repo.** This spec distinguishes private canonical content from channel deliverables:

- **`docs/` is private by default and stays that way.** It holds canonical written content — strategy, research, briefs, decisions, all copy drafts and final approved text, brand guidelines, process docs. **Nothing in `docs/` is ever added to `.sync-public.yml`.** When Claude writes final text for a channel (e.g. a LinkedIn post), the text lives in `docs/copy/{channel}/`; only the rendered or published artifact (screenshot, archive PDF, scheduled send config) lives in the channel folder.
- **Channel folders (including `website/`) hold deliverables.** Each top-level folder corresponds to a distinct channel or asset type. Paths here are candidates for `.sync-public.yml` when the artifact is publicly publishable (typically just `website/` content, occasionally a public deck). Non-public channels (ads creative, internal email sends, drafts in progress) stay private by never being listed in the manifest.

### Top-level channel folders

Created on demand. When a project needs a channel that doesn't yet exist, create the folder with an INDEX.md before adding content. Use these canonical names rather than synonyms:

- **`website/`** — the project's primary web presence, served via GitHub Pages. One HTML file per page, shared main nav, single-file (see §5 Website Conventions).
- **`brand/`** — brand asset FILES (`logo.svg`, `palette.json`, `fonts/`, `icons/`). Brand GUIDELINES (written voice, visual principles, usage rules) live in `docs/brand/` — this folder is just the physical assets every channel references with paths like `../brand/logo.svg`.
- **`ads/`** — digital advertising. Organize by platform first: `ads/google/`, `ads/linkedin/`, `ads/meta/`. Each platform holds campaigns: `ads/google/q2-launch/`. Creative lives here; ad copy (canonical text) lives in `docs/copy/ads/`.
- **`social/`** — social media posts. Organize by platform first: `social/linkedin/`, `social/x/`, `social/instagram/`. Each platform holds posts by campaign or chronologically. Post text (canonical) lives in `docs/copy/social/`.
- **`email/`** — email campaigns. Rendered HTML templates, plain-text fallbacks, send logs. Campaign copy (canonical) lives in `docs/copy/email/`.
- **`sms/`** — SMS campaigns. Message text (canonical) lives in `docs/copy/sms/`; send logs and per-platform configs live here.
- **`messenger/`** — messenger (WhatsApp, iMessage, Messenger, etc.) assets and conversation flows.
- **`decks/`** — slide decks (`.pptx`, `.pdf`). Outline and speaker notes (canonical) live in `docs/copy/decks/`.
- **`app/`** — application source code for marketing apps. Treat as a normal software project inside this folder.

When a channel is needed that doesn't fit any of the above, add a new top-level folder following the same pattern (singular lowercase name, platform-then-campaign nesting, INDEX.md at every level) and log it in §8 (Decisions Logged) so future projects inherit the name.

### Canonical subfolders in docs/

When `docs/` reaches the "split at three" threshold in a category, promote to a subfolder. Use these names:

- `docs/strategy/` — strategic positioning, market analysis, business framing
- `docs/research/` — source material, interviews, reading notes, raw inputs
- `docs/copy/` — all canonical text destined for external channels. Organize by channel: `docs/copy/social/`, `docs/copy/email/`, `docs/copy/ads/`, `docs/copy/decks/`, `docs/copy/website/`, `docs/copy/sms/`. Within social/ads/sms, nest by platform: `docs/copy/social/linkedin/post-q2-launch.md`.
- `docs/briefs/` — short briefs that direct production work (deck briefs, campaign briefs, design briefs)
- `docs/decisions/` — long-form decision records that exceed what fits in §8 below
- `docs/brand/` — brand guidelines (voice, visual principles, usage rules). Asset files live in top-level `brand/`.
- `docs/process/` — organizational process design docs (for internal/external communications)

### Universal conventions

**Split at three.** When a category at any level reaches three files, promote to a subfolder of the same canonical name and create an `INDEX.md` inside it. Applies inside `docs/`, inside any channel folder, inside any platform folder. Claude performs splits automatically when the threshold is crossed; if moved files are referenced from elsewhere or in the manifest, surface the move to the user first.

**INDEX.md at every level.** Every folder under `docs/` and every channel folder has an `INDEX.md` listing its immediate contents (subfolders and files) with one-line descriptions, and pointing outward to child INDEX.md files. Updated whenever files are added, moved, or retired. Subfolders get their own INDEX.md the moment they're created.

**Frontmatter on docs.** Every markdown file in `docs/` (excluding `INDEX.md` files) starts with a YAML frontmatter block:

```yaml
---
title: Home page spec
type: spec               # strategy | research | copy | brief | decision | brand | process | spec | log
status: draft            # draft | review | final | archived
last_updated: 2026-04-18
related: []              # repo-relative paths to related docs
renders_to: [website/home.html]   # optional; omit if this doc has no rendered artifact
---
```

The `related:` and `renders_to:` lists are the substrate for a future knowledge graph that connects `docs/` content to channel-folder artifacts across the repo. Folders organize content for humans; frontmatter organizes it for the graph. `type` matches the canonical subfolder this doc lives in (or would live in if split out). Update `last_updated` whenever the body changes meaningfully.

For `docs/copy/` entries specifically, a doc may also carry `channel:` (social | email | ads | sms | decks | website) and `platform:` (linkedin | x | google | meta | …) when those aren't already implicit in the path — useful for graph queries that span channels.

**Two-repo structure.** This (`{project}-private`) is the working repo — everything produced lives here. A paired public mirror (`{project}-public`) holds only the subset listed in `.sync-public.yml`, and is the repo that GitHub Pages actually serves. **`docs/` is never synced.** See §10 for the full pattern.

<!-- As the project grows — more docs subfolders, new channels, more campaigns
     within a channel — extend the tree above and keep the relevant INDEX.md
     files current. Preserve the docs/ ↔ channel boundary: canonical text
     belongs in docs/copy/{channel}/, artifacts belong in the channel folder. -->

---

## 3. Project / Organization Snapshot

<!-- SOCRATIC: Ask the user for:
     - Project / organization name (and any abbreviation).
     - What it is, in 1-2 sentences.
     - Who it works with or for (audience, customer profile, beneficiary).
     - How it shows up — voice, posture, stance, level of formality.
     - The engagement or relationship model (one-off, ongoing partner, subscription, etc.).
     Format as a short series of labelled paragraphs, not a bulleted list. -->

**Name:** [TBD]

**What it is:** [TBD]

**Who it works with:** [TBD]

**How it shows up:** [TBD]

**Engagement model:** [TBD]

---

## 4. Voice & Copy Conventions

<!-- SOCRATIC: Ask the user for:
     - Examples of writing they consider "on-voice" (links, files, or pasted samples).
     - Words and phrases they want to use, and ones they want to avoid.
     - Formality level (corporate, conversational, casual, irreverent).
     - Person (first, second, third).
     - Sentence cadence (short and punchy, longer and rhythmic, mixed).
     - Spelling convention (American, British, other).
     - Whether to allow emojis, exclamation points, em-dashes, etc.
     Synthesize into 8-10 short conventions, each starting with a bolded name.
     Format like the example below — replace the example with the project's actual
     conventions when ready. -->

[TBD — apply these when writing new copy. Example structure:]

- **Person.** [Second-person declarative / first-person plural / third-person neutral.]
- **Cadence.** [Short, confident sentences followed by one longer sentence that does the work.]
- **Jargon.** [No jargon scaffolding / industry jargon allowed in context / etc.]
- **Hedging.** [No hedging adverbs / measured hedging acceptable.]
- **Spelling.** [American English / British English.]
- **Emojis.** [No emojis in client-facing copy / minimal emoji use allowed.]

[TBD — replace the placeholder list with the project's actual voice rules. Add
the "When uncertain" test the user prefers — e.g. "Would this survive being read
aloud to [a specific reader profile]?" — at the end of the section.]

---

## 5. Website Conventions

The `website/*.html` files are standalone, single-file HTML pages served by GitHub Pages via the public mirror (see §10). These conventions apply to website pages specifically; other channels (`email/`, `ads/`, `decks/`, etc.) have their own conventions that get added as new sections below §5 when those channels are first used.

- **Deployment model: a home page plus standalone explainers, connected by a shared main nav.** Each HTML file stands on its own — no server-side includes, no shared shell — but every page in `website/` carries the same top nav block (see "Main nav convention" below) so a reader can move between pages from any starting point. Pages may evolve into a more traditional site over time; until then they remain single-file and self-contained.
- **Main nav convention.** Every HTML file in `website/` starts with the same nav. Left side is a text brand linking to `./home.html`. Right side is one link per sibling page (`./home.html`, `./<other-page>.html`, …). The current page marks its own item with `class="site-nav-link active" aria-current="page"`. CSS lives inline under a `/* ---------- Main nav ---------- */` block. If a page sets `body { padding }`, the nav uses negative margins to render edge-to-edge; otherwise regular padding. When a new page is added, extend the nav across all files.
- **Internal links.** Use relative `./<page>.html` links between website pages. Website pages never link into `docs/` because `docs/` is private — never synced to the public mirror.
- **Brand assets.** When a page needs a logo, palette value, or brand font file, reference it from `../brand/` (e.g. `<img src="../brand/logo.svg">`, `<link rel="icon" href="../brand/favicon.ico">`). Brand GUIDELINES that describe how to use those assets live in `docs/brand/` — not linked from website pages, since docs is private.
- **One file, no build step.** Inline `<style>` and `<script>`, single Google Fonts import (Inter by default), no external JS dependencies.
- **Font:** Inter (300/400/500/600/700) with `system-ui, sans-serif` fallback — override with the project's brand typography once `brand/` and `docs/brand/` are filled in.
- **Background:** `#f8fafc`. **Primary text:** `#0f172a`. **Muted text:** `#64748b` / `#94a3b8`. Override with the brand palette from `brand/palette.json` once defined.
- **Diagrams in inline SVG**, with `onclick` handlers calling named JS functions that reveal a detail panel below the diagram (when interactivity is needed).
- **Data lives in JS objects** at the top of the script block so copy edits are localized and obvious.
- **Viewport-responsive**, with one `@media (max-width: 720px)` fallback where needed.
- **No browser storage APIs** (no localStorage/sessionStorage).
- **Attribution line** at the bottom: "A project by **[Project Name]**".

When adding a new website page: mirror an existing one's structure rather than inventing a new pattern.

<!-- SOCRATIC ADDITION: Once the project has a brand visual system (palette,
     logo, typography) populated in brand/ and docs/brand/, replace the generic
     Inter / slate palette references above with the project's actual values. -->

---

## 6. [Project-Specific Section Slot]

<!-- SOCRATIC: As the user names project-specific frameworks, models, or
     concepts during discovery, add them as new sections here, numbered
     sequentially (§6, §7, §8, …). Each framework section should:
     - State what the framework is in one paragraph.
     - List its components with canonical names and one-line definitions.
     - Capture any color codes, diagrams, or visual conventions.
     - Note where it appears in web/ (which HTML page renders it).
     Once any project-specific sections are added, renumber §7-§10 below. -->

[TBD — add framework / model / concept sections as they emerge in discovery.]

---

## 7. Working Agreement with Claude

The user works by **iteratively building detailed specifications with a two-way Socratic approach**. This applies to everything in this repo, not just code.

Practical implications:

1. **Ask before building.** When a request is underspecified (audience, length, format, tone, success criteria), ask a clarifying question before producing a deliverable. Prefer the AskUserQuestion tool for multiple-choice clarifications.
2. **Propose, don't assume.** When a decision is needed that isn't covered by this spec, surface the decision explicitly with 2–3 reasoned options rather than picking silently.
3. **Small steps, visible reasoning.** Prefer short cycles — draft a section, check alignment, expand — over one large generation.
4. **Update this spec as decisions land.** When a new convention, naming decision, or framework refinement is made, add it here so future sessions inherit it.
5. **Source-of-truth discipline.** Canonical written content lives in `docs/` (private, with frontmatter). Channel folders (`website/`, `ads/`, `social/`, `email/`, `decks/`, etc.) render or reference that canonical content. If a channel artifact drifts from its `docs/` source, update `docs/` first and bring the artifact into alignment, not the other way around. Keep each folder's `INDEX.md` current when files are added, moved, or retired. Never add `docs/` paths to `.sync-public.yml` — docs is private only.
6. **Verify before declaring done.** For any non-trivial change, include a verification step: re-read the changed file, diff against the source `docs/` copy, or view the rendered HTML.

---

## 8. Decisions Logged

Decisions made through Socratic iteration. Newest at the top.

[TBD — decisions land here as the project develops. Each entry: date — short title, then a paragraph or two describing what was decided and why, plus pointers to any sections it supersedes.]

---

## 9. Open Questions / To Revisit

Items the current spec does not fully answer. Raise them only when a new request makes resolution necessary.

[TBD — open questions land here as they emerge. When any of these resolve, capture the answer in §8 (Decisions Logged) and update the relevant section above.]

---

## 10. Two-Repo Pattern: {project}-private + {project}-public

This project uses a paired-repo structure to get per-file public/private control without leaving GitHub. There is a working repo (`{project}-private`) where everything produced lives, and a public mirror (`{project}-public`) that holds only what is meant for the world. GitHub Pages serves the public mirror.

### Why two repos

GitHub Pages on the personal plan only serves public repos, and a single repo only has one visibility setting — there is no per-file or per-folder visibility control inside one repo. Splitting the work into two repos and syncing a curated subset is the cleanest way to keep strategy, internal notes, drafts, and decision logs private while still publishing the finished pages and any public canonical docs.

### Roles

- **`{owner}/{project}-private`** — Private. The working repo. All strategy docs, drafts, the spec (`CLAUDE.md`), the manifest, and the sync workflow live here. **This is the repo you push commits to.**
- **`{owner}/{project}-public`** — Public. The mirror. Contents are written entirely by the sync workflow. **Never edit `{project}-public` directly** — anything added by hand will be wiped on the next sync, except files explicitly listed under `preserve:` in the manifest.

### What gets published

The list lives in `/.sync-public.yml` at the root of `{project}-private`. To grow or shrink the public surface area, edit `.sync-public.yml`, commit, push.

The `preserve:` list names files that may live in `{project}-public` only — the sync workflow leaves them alone instead of wiping them.

### Sync mechanism

The workflow at `.github/workflows/sync-public.yml` runs on:

- **`push` to `main`** — every push to `{project}-private` propagates approved files to `{project}-public` automatically.
- **`workflow_dispatch`** — manual resync from the Actions tab in `{project}-private`, useful for re-running after fixing a misconfiguration without needing a new commit.

It checks out both repos, parses the manifest, removes anything in `{project}-public` that is no longer in `include` (and not in `preserve`), copies the manifest files in, and pushes a commit to `{project}-public` with the message `Sync from {project}-private @ <short-sha>`. Private commit messages are not propagated.

The workflow derives the target repo from `GITHUB_REPOSITORY` by stripping `-private` and appending `-public`, so this file does not need editing per project — the naming convention is enforced by the workflow itself.

### Auth

The workflow writes to `{project}-public` via an SSH deploy key:

- The **public half** of the keypair is installed as a deploy key with **write access** on `{owner}/{project}-public`.
- The **private half** is stored as a repository secret named `PUBLIC_REPO_DEPLOY_KEY` on `{owner}/{project}-private`.

### Live URLs

Pages serves from `{project}-public` (`main` / root). URLs keep the repo nesting:

- Home: `https://{owner}.github.io/{project}-public/website/home.html`
- (Add more here as the project grows.)

### Operating rules

- **Always commit to `{project}-private`.** Never push directly to `{project}-public`. The mirror is a build artifact.
- **Treat `.sync-public.yml` as a security boundary.** Before adding a path, ask: is this safe to publish? If unsure, don't add it. Removing a path from the manifest also removes it from `{project}-public` on the next sync.
- **The manifest will evolve.** As public pages add new dependencies (images, fonts, additional canonical docs), grow the include list to match.
- **Rotate the deploy key if compromised.** Generate a new keypair, update `PUBLIC_REPO_DEPLOY_KEY` on `{project}-private`, replace the deploy key on `{project}-public`, delete the old one. When pasting the new private half into the GitHub secret UI, use the file-based workaround (write the key to `.public-repo-deploy-key` in the workspace, gitignored, open in a plain text editor, copy from there) rather than copying out of a chat or rendered code block — chat/markdown rendering can corrupt the key value, producing an `error in libcrypto` failure on the next sync.

---

*Last updated: [TBD — set when §0 is removed].*
