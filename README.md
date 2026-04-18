# project-template

A starter template for projects that follow a specific working pattern:

- **Two repos per project:** a private working repo (`{project}-private`) and a public mirror (`{project}-public`) synced continuously via GitHub Action. Per-file public/private control via a manifest.
- **`docs/` + `web/` layout:** markdown is the source of truth for language; `web/` holds standalone HTML pages rendered from it. GitHub Pages serves the public mirror.
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
5. Runs a Socratic discovery session to fill in the project-specific `CLAUDE.md` sections.
6. Commits, pushes, verifies the first sync.

Full procedure lives in `CLAUDE.md` §0 of this repo.

## Prerequisites for bootstrap

- `gh` CLI installed and authenticated (`gh auth login` with at least `repo` + `admin:public_key` scopes).
- `git` configured with an identity.
- SSH client available (for keypair generation).
- Claude (or a Claude-based assistant) with file + shell access to the local project folder.

## Template contents

```
project-template/
├── README.md                             # This file
├── CLAUDE.md                             # Generic sections + Socratic prompts + §0 bootstrap
├── .gitignore                            # OS cruft + deploy-key guard
├── .sync-public.yml                      # Manifest of paths that sync to the public mirror
├── .github/
│   └── workflows/
│       └── sync-public.yml               # Sync workflow (generalized; derives target from repo name)
├── docs/                                 # PRIVATE ONLY — canonical written content
│   ├── INDEX.md                          # Entry point for canonical content
│   └── home.md                           # Home page spec with frontmatter + Socratic prompts
├── website/                              # Project website (served by Pages via the public mirror)
│   ├── INDEX.md
│   └── home.html                         # Minimal single-file home with main-nav scaffolding
└── brand/                                # Brand asset files (logos, palette, fonts) — guidelines in docs/brand/
    └── INDEX.md
```

## Conventions enforced by the template

- Repos follow the `{project}-private` / `{project}-public` naming convention. The sync workflow derives the target repo from `GITHUB_REPOSITORY`.
- `docs/` is PRIVATE ONLY — all canonical written content (strategy, research, briefs, decisions, copy drafts, brand guidelines, process docs) lives here with YAML frontmatter. Never listed in `.sync-public.yml`.
- Channel folders (`website/`, `brand/`, `ads/`, `social/`, `email/`, `sms/`, `messenger/`, `decks/`, `app/`) hold rendered or semi-rendered deliverables. Canonical names defined in `CLAUDE.md` §2; created on demand. Public artifacts (typically just `website/`) appear in the manifest.
- Within each channel, organize by platform first (e.g. `ads/google/`, `social/linkedin/`), then by campaign. Text content for the channel is canonical in `docs/copy/{channel}/`; the channel folder holds the rendered artifact.
- The "split at three" rule applies universally: when a category reaches three files, promote to a subfolder with its own `INDEX.md`.
- `INDEX.md` at every level — entry points listing immediate contents with one-line descriptions.
- Every markdown doc in `docs/` carries frontmatter (`title`, `type`, `status`, `last_updated`, `related`, optional `renders_to`) so a future knowledge graph can read cross-folder relationships without relying on folder hierarchy.
- HTML pages in `website/` are single-file, no build step, inline CSS/JS, shared main-nav block.

## Editing the template itself

Changes to this template affect future projects bootstrapped from it, not existing projects. Existing projects get a one-time snapshot at creation time.

To propagate a structural change (e.g. an update to the sync workflow) to existing projects, update the file in each project's `-private` repo manually. Template inheritance is not automatic after instantiation — this is a GitHub templating limitation, not a design choice.
