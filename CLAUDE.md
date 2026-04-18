# CLAUDE.md — [TBD — Project Name]

This file is the **project-specific** working specification for the [TBD — project name] project.

**Before acting on anything in this repo, read `.claude/conventions.md`.** That file holds the shared conventions — repository layout, website conventions, working agreement with Claude, and the two-repo pattern — that every project following this pattern inherits. It is authoritative from `tnosugar/project-template` and kept in sync via `scripts/sync-conventions.sh`.

`CLAUDE.md` is for what makes this project different: purpose, snapshot, voice, frameworks, decisions, and open questions. The spec is built iteratively through two-way Socratic questioning (see `conventions.md` §3). Treat this file as a living document: when something here is ambiguous, incomplete, or contradicted by a new decision, ask about it before acting, and update this file once the answer is clear.

---

## 0. FIRST-RUN BOOTSTRAP

**This section is removed once the project is initialized.** If you are reading this, the repo was just created from `tnosugar/project-template` and project-specific content has not been filled in yet.

Run this sequence in order. Each step is small; ask the user before moving to the next when there is ambiguity.

### Step 1 — Create the public mirror

This template assumes the two-repo pattern (see `.claude/conventions.md` §4). The current repo is `{owner}/{project}-private`. Its public mirror is `{owner}/{project}-public`. Create the mirror now.

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

### Step 4 — Confirm shared conventions are current

```bash
./scripts/sync-conventions.sh
```

The template was just instantiated, so usually nothing changes. If the script reports updates, review the diff before applying — those are conventions changes that landed in `tnosugar/project-template` after the template version this project was created from.

### Step 5 — Run a Socratic discovery session

Walk the user through the project-specific sections in this file (§1, §2, §3 — and, if they apply, §4 for additional frameworks). Use the Socratic prompts embedded as HTML comments under each heading. For each section: ask the prompted questions, draft the answer in plain language, get sign-off, then replace the prompt with the drafted content.

Order to ask in:

1. §1 Project Purpose — one paragraph stating what this project is and why it exists.
2. §2 Project / Organization Snapshot — name, what it is, who it works with, how it shows up.
3. §3 Voice & Copy Conventions — derived from the user's existing materials if they have any; otherwise drafted from scratch and refined.
4. Add framework sections (§4+) as the user names them. Number them sequentially and renumber §5 / §6 accordingly.

Add to §5 (Decisions Logged) as decisions land during discovery.

### Step 6 — Update the README, manifest, and home assets

- Replace `[TBD — Project Name]` markers throughout `README.md`, `docs/home.md`, and `website/home.html`.
- Edit `.sync-public.yml` to reflect what should be public for this project (only channel-folder paths; `docs/` is private only).
- Run a first pass on `docs/home.md` and `website/home.html` to fill in the placeholders that have firm answers.

### Step 7 — Commit, push, verify

```bash
git add -A
git commit -m "Initialize {project}: filled in §1, §2, §3 of CLAUDE.md and home page placeholders"
git push origin main
```

The push triggers the sync workflow. Verify on the Actions tab that it succeeds, that `{project}-public` receives the manifest files, and that Pages serves at `https://{owner}.github.io/{project}-public/website/home.html`.

### Step 8 — Delete this section (§0)

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

## 2. Project / Organization Snapshot

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

## 3. Voice & Copy Conventions

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

## 4. [Project-Specific Section Slot]

<!-- SOCRATIC: As the user names project-specific frameworks, models, or
     concepts during discovery, add them as new sections here, numbered
     sequentially (§4, §5, §6, …). Each framework section should:
     - State what the framework is in one paragraph.
     - List its components with canonical names and one-line definitions.
     - Capture any color codes, diagrams, or visual conventions.
     - Note where it appears in website/ (which HTML page renders it).
     Once any project-specific sections are added, renumber §5 / §6 below. -->

[TBD — add framework / model / concept sections as they emerge in discovery.]

---

## 5. Decisions Logged

Decisions made through Socratic iteration. Newest at the top.

If a decision deviates from a shared convention in `.claude/conventions.md`, note that explicitly here — this file overrides the shared convention for this project only. If the deviation is broadly useful, also propose a PR against `tnosugar/project-template`.

[TBD — decisions land here as the project develops. Each entry: date — short title, then a paragraph or two describing what was decided and why, plus pointers to any sections it supersedes.]

---

## 6. Open Questions / To Revisit

Items the current spec does not fully answer. Raise them only when a new request makes resolution necessary.

[TBD — open questions land here as they emerge. When any of these resolve, capture the answer in §5 (Decisions Logged) and update the relevant section above.]

---

*Last updated: [TBD — set when §0 is removed].*
