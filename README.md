# project-template

A starter template for projects that follow a specific working pattern:

- **Two repos per project:** a private working repo (`{project}-private`) and a public mirror (`{project}-public`) synced continuously via GitHub Action. Per-file public/private control via a manifest.
- **`content/` + `website/` + channel-folder layout:** markdown is the source of truth for language (all authored `.md` under `content/`); channel folders (`website/`, `social/`, `email/`, `ads/`, …) hold rendered or semi-rendered deliverables. Non-markdown raw assets (logos, palettes, photos, decks, PDFs) live in `files/`. GitHub Pages serves the public mirror.
- **Split spec:** `.claude/conventions.md` holds shared conventions (synced from this template); `CLAUDE.md` holds project-specific spec (purpose, voice, frameworks, decisions).
- **Sync mechanism for shared conventions:** `scripts/sync-conventions.sh` pulls the latest shared files from this template into a consumer project on demand. Future structural tweaks propagate without rewriting `CLAUDE.md` across N repos.
- **Socratic working agreement:** project-specific content is built iteratively with Claude through two-way questioning rather than up-front specification.

## Using the template

Bootstrapping a new project happens through Claude. The short version:

```
User: Create a new project called acme-marketing
```

Claude, reading `CLAUDE.md` §0 of this template on first run, then:

1. Creates `{owner}/acme-marketing-private` from this template via `gh repo create --template`.
2. Creates `{owner}/acme-marketing-public` as a fresh public repo.
3. Generates an ed25519 deploy keypair, installs the public half on `acme-marketing-public` (write access), stores the private half as the `PUBLIC_REPO_DEPLOY_KEY` secret on `acme-marketing-private`.
4. Enables Pages on `acme-marketing-public`.
5. Runs `./scripts/sync-conventions.sh` to confirm shared files are current with the template.
6. Runs a Socratic discovery session to fill in the project-specific `CLAUDE.md` sections.
7. Commits, pushes, verifies the first sync.

Full procedure lives in `CLAUDE.md` §0 of this repo.

## Prerequisites for bootstrap

- `gh` CLI installed and authenticated (`gh auth login` with at least `repo` + `admin:public_key` scopes).
- `git` configured with an identity.
- SSH client available (for keypair generation).
- Bash 4+ available (for the sync script).
- Claude (or a Claude-based assistant) with file + shell access to the local project folder.

## Template contents

```
project-template/
├── README.md                             # This file
├── CLAUDE.md                             # PROJECT-SPECIFIC spec (purpose, voice, frameworks, decisions)
├── .claude/
│   ├── conventions.md                    # SHARED conventions (synced from this template)
│   └── sync-source.txt                   # Source repo URL for the sync script
├── .gitignore                            # OS cruft + deploy-key guard
├── .sync-public.yml                      # Manifest of paths that sync to the public mirror
├── .github/
│   └── workflows/
│       └── sync-public.yml               # Sync workflow (generalized; derives target from repo name)
├── scripts/
│   ├── sync-conventions.sh               # Pulls shared files from project-template into a consumer project
│   └── sync-manifest.txt                 # List of paths the sync script copies
├── content/                              # PRIVATE ONLY — all authored markdown (canonical prose, references, service defs, specs)
│   ├── INDEX.md                          # Entry point for canonical content
│   └── home.md                           # Home page spec with frontmatter + Socratic prompts
├── website/                              # Project website (served by Pages via the public mirror)
│   ├── INDEX.md
│   └── home.html                         # Minimal single-file home with main-nav scaffolding
└── files/                                # Non-markdown raw assets (logos, palettes, fonts, photos, decks, PDFs) — guidelines in content/brand/
    └── INDEX.md
```

## Conventions enforced by the template

- **Spec is split:** shared conventions live in `.claude/conventions.md` (authoritative from this template, synced to consumers via `scripts/sync-conventions.sh`); project-specific content lives in each project's `CLAUDE.md`. To deviate from a shared convention in a single project, log the deviation in that project's `CLAUDE.md` §5 — don't edit `.claude/conventions.md` in the consumer (the next sync overwrites it).
- Repos follow the `{project}-private` / `{project}-public` naming convention. The sync workflow derives the target repo from `GITHUB_REPOSITORY`.
- `content/` is PRIVATE ONLY — all authored markdown (strategy, research, briefs, decisions, copy drafts, brand guidelines, process docs, service definitions, reference sheets) lives here with YAML frontmatter. Never listed in `.sync-public.yml`.
- Channel folders (`website/`, `files/`, `ads/`, `social/`, `email/`, `sms/`, `messenger/`, `decks/`, `app/`) hold rendered or semi-rendered deliverables and non-markdown raw assets. Canonical names defined in `.claude/conventions.md` §1; created on demand. Public artifacts (typically just `website/`, plus any `files/` referenced by public pages) appear in the manifest.
- Within each channel, organize by platform first (e.g. `ads/google/`, `social/linkedin/`), then by campaign. Text content for the channel is canonical in `content/copy/{channel}/`; the channel folder holds the rendered artifact.
- `files/` is flat by default — non-markdown raw assets (logo, palette, fonts, photos, decks). Subdirectories grow organically; no pre-declared taxonomy.
- The "split at three" rule applies universally: when a category reaches three files, promote to a subfolder with its own `INDEX.md`.
- `INDEX.md` at every level — entry points listing immediate contents with one-line descriptions.
- Every markdown doc in `content/` AND the project's root `CLAUDE.md` carry frontmatter (`title`, `type`, `status`, `last_updated`, plus optional typed graph fields — `entity`, `isa`, `client`, `project`, `topics`, `people`, `renders_to`, `published`) so a future knowledge graph can read cross-folder relationships without relying on folder hierarchy. Schema lives in `.claude/SCHEMA.md`.
- HTML pages in `website/` are single-file, no build step, inline CSS/JS, shared main-nav block.

## Editing the template itself

There are two kinds of changes, with different propagation behavior:

**Changes to shared conventions** (anything listed in `scripts/sync-manifest.txt` — today: `.claude/conventions.md`, `.github/workflows/sync-public.yml`, `.gitignore`, and the sync scripts themselves) — these are inherited by every project that runs the sync. Workflow:

1. Open a PR against this repo.
2. Once merged, run `./scripts/sync-conventions.sh` from each existing consumer project to pull the change in.
3. The sync script shows a diff and asks for confirmation before writing.

To add a new shared file, add its path to `scripts/sync-manifest.txt`, commit, push — the next sync run in each consumer picks it up.

**Changes to template-only files** (the `[TBD]` placeholders in `CLAUDE.md`, `content/home.md`, `website/home.html`, the `INDEX.md` files, this README, etc.) — these only affect future projects bootstrapped from the template, not existing projects. Existing projects get a one-time snapshot at creation time and are expected to diverge from the template scaffolding as they grow.

If you want a template-only change to land in an existing project anyway, copy it by hand. There is no automatic mechanism for backporting non-shared template changes — that's by design, since divergence is the whole point of project-specific files.
