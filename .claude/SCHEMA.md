# Knowledge Graph Schema

Authoritative reference for entity types, edge types, and frontmatter field definitions used across any project that adopts this schema. Synced from `tnosugar/project-template` via `scripts/sync-conventions.sh`; do not edit directly in a consumer project.

Works in concert with `.claude/conventions.md` §1 (frontmatter), which describes the *mechanics* of how frontmatter is written. This file describes the *vocabulary* of what can appear in it.

**Status: draft.** The schema is forward-looking. Typed fields are optional on all docs today; they become required for graph-relevant entity types once a query tool is built. Entity types and edge types will grow as real entities get cataloged in consumer projects; proposed extensions go through a PR against `tnosugar/project-template`.

---

## 1. Design approach

**Hybrid vocabulary.** Entity type names are borrowed from [Schema.org](https://schema.org) where the mapping is clean (Person, Organization, Article, Event). Names are invented where Schema.org does not fit the working-knowledge-graph use case (Project, Engagement, Topic, Measurement). Borrowing Schema.org names is not a commitment to Schema.org semantics; it is a cognitive saving and a forward-compatibility hook for emitting JSON-LD on public web pages if that ever becomes useful.

**Flat lists, not richer objects.** Cross-reference fields are flat arrays of repo-relative paths (`topics: [docs/topics/marketing-attribution.md]`). A richer form (paths with role metadata per entry) may be added later if real queries require it; starting flat keeps the schema legible.

**Paths, not slugs.** Cross-references point at files, not abstract identifiers. This keeps the graph grounded in the filesystem and makes every edge verifiable by file-existence check. Slugs and display names belong inside the target file's own frontmatter.

**Schema evolves with the corpus.** Every entity type in this document should be justified by at least one query someone has actually wanted to run. Speculative types are out of scope. New entity types and edge types land as PRs with a named use case.

---

## 2. Entity types

Each entity type has a canonical name, a source (Schema.org-aligned or custom), a one-sentence definition, the `type:` values it typically carries in the existing doc taxonomy, and the key frontmatter fields that apply. Entity types defined at stub depth here; consumer projects are expected to flesh out per-entity registries as real entities land.

### Project
- **Source:** custom (Schema.org's `Project` is too thin).
- **Definition:** A named body of work with its own purpose, voice, and decision log. Typically one private/public repo pair today; under a unified graph, a subfolder.
- **Typical `type:` values:** `spec`, `process`, `strategy`.
- **Key fields:** `entity: project`, `client: []`, `people: []`, `topics: []`. A Project entity usually lives in a `CLAUDE.md` at the project's root or in a `docs/projects/*.md` stub if multiple projects share a repo.
- **Example:** the NSC project's `CLAUDE.md` is a Project entity.

### Organization
- **Source:** Schema.org (`Organization`).
- **Definition:** A company, firm, nonprofit, agency, or other institution referenced by the graph. Includes clients, partners, vendors, and the project-owning organization itself.
- **Typical `type:` values:** `brief`, `research`, or unset (an Organization entity may exist purely as a registry stub).
- **Key fields:** `entity: organization`, `people: []`, `topics: []`.
- **Lives in:** `docs/organizations/` (create when the first Organization entity lands).

### Person
- **Source:** Schema.org (`Person`).
- **Definition:** An individual referenced by the graph. Includes project team members, client stakeholders, content authors, and named subjects.
- **Typical `type:` values:** usually unset (Person entities are registry stubs); occasionally `brief` for a detailed role description.
- **Key fields:** `entity: person`, `client: []` (if affiliated with a client organization), `project: []` (if affiliated with a project).
- **Lives in:** `docs/people/` (create when the first Person entity lands).

### Content
- **Source:** custom parent; specific content kinds map to Schema.org (`Article`, `BlogPosting`, `SocialMediaPosting`, `VideoObject`, etc.) when useful.
- **Definition:** A discrete content artifact that was (or will be) published to an audience: a LinkedIn post, a blog article, a podcast episode, an email, a deck, a video.
- **Typical `type:` values:** `copy` (for canonical text of the artifact) or a channel-specific frontmatter on the rendered artifact itself.
- **Key fields:** `entity: content`, `client: []`, `project: []`, `topics: []`, `people: []` (authors, subjects), `published: YYYY-MM-DD`, `channel:`, `platform:`. Content entities often also carry `derived_from: []` (source content this was built from) and `measurements: []` (performance records); those fields are introduced when Content becomes a tracked entity type in a consumer project.
- **Lives in:** canonical text in `docs/copy/{channel}/[{platform}/]`; rendered artifact in the channel folder (`website/`, `social/`, etc.).

### Topic
- **Source:** custom.
- **Definition:** A subject-matter label attached to Content entities for retrieval. Flat or shallowly hierarchical; the taxonomy is per-project or per-graph.
- **Typical `type:` values:** usually unset (Topic entities are registry stubs with slug + description).
- **Key fields:** `entity: topic`, `related: []` (to parent or sibling topics in hierarchical taxonomies).
- **Lives in:** `docs/topics/` (create when the first Topic entity lands). One file per topic; filename is the slug.
- **Governance note:** topic hygiene (consistent naming, avoiding synonyms, pruning unused topics) is the hard part of making Topic queries useful. Start narrow; add topics as content is tagged.

### Measurement
- **Source:** custom.
- **Definition:** A performance record linking a Content entity (or a campaign spanning multiple) to observed audience behavior and, where available, business outcomes. Measurements link out to where the real numbers live (dashboard URL, CRM export, anonymized snapshot); they do not embed sensitive client data.
- **Typical `type:` values:** `log` (a dated record of what happened) or `decision` (a synthesis of what multiple measurements show).
- **Key fields:** `entity: measurement`, `content: []` (the Content being measured), `client: []`, `project: []`, `published: YYYY-MM-DD` (when the measurement was taken).
- **Lives in:** `docs/measurements/` (create when the first Measurement entity lands).
- **Confidentiality note:** Measurement records should never embed raw client financials or CRM exports. Store only: the link, the dated snapshot or summary, and the definition of the metric used.

---

## 3. Edge types

Edges are the typed cross-reference fields in frontmatter. Each edge names what it connects and whether it is expected to be symmetric (bidirectional) or asymmetric.

| Field | Connects | Direction | Notes |
|---|---|---|---|
| `client:` | any → Organization | asymmetric | "This doc is for this client-org." Reciprocal is usually implicit. |
| `project:` | any → Project | asymmetric | "This doc belongs to this project." |
| `topics:` | Content → Topic | asymmetric | "This content is about these topics." |
| `people:` | any → Person | asymmetric | Role is implicit or stated inline. |
| `content:` | Measurement → Content | asymmetric | "This measurement measures this content." |
| `derived_from:` | Content → Content | asymmetric | "This content was built from these sources." |
| `measurements:` | Content → Measurement | asymmetric | Reciprocal of `content:` on the measurement side. |
| `renders_to:` | doc → channel artifact | asymmetric | Existing field; markdown renders to HTML/PDF/etc. |
| `related:` | any → any | bidirectional by convention | Untyped fallback. See `.claude/conventions.md` §1. |

Bidirectionality is maintained by hand until a graph tool exists. When a graph tool is built, it audits asymmetries and surfaces them as candidates for fix.

---

## 4. Universal frontmatter fields

Fields present on every `docs/*.md` regardless of entity type. Defined here for reference; written on the doc per the YAML block in `.claude/conventions.md` §1.

- **`title`** — Human-readable title. Required.
- **`type`** — Internal doc category (`strategy | research | copy | brief | decision | brand | process | spec | log`). Required. Determines canonical subfolder.
- **`status`** — Lifecycle state (`draft | review | final | archived`). Required.
- **`last_updated`** — ISO date of last meaningful body change. Required.
- **`related`** — Untyped peer associations (see §3 and `.claude/conventions.md` §1). Optional; default `[]`.
- **`renders_to`** — Rendered artifact paths. Optional; omit if the doc has no rendered artifact.

Entity-type-specific fields (`entity`, `client`, `project`, `topics`, `people`, `published`, `channel`, `platform`, and others) are optional today and per-entity; see §2 for which fields matter for each entity type.

---

## 5. Extending the schema

Schema extensions land as PRs against `tnosugar/project-template`. A PR to add a new entity type or edge type should include:

1. The new entity type or edge added to this file, at stub depth at minimum (name, source, definition, key fields, example).
2. A named use case: what query or workflow drove the extension. "It would be nice to have" is not sufficient; the schema only grows when a concrete need appears.
3. Any corresponding update to `.claude/conventions.md` §1 (the frontmatter block in the YAML example, or the prose around it).
4. Backfill guidance: whether existing docs need the new field, and if so, at what depth.

Consumer projects pull the change in via `scripts/sync-conventions.sh`.

---

*Last updated: 2026-04-19. Initial skeleton: six entity types (Project, Organization, Person, Content, Topic, Measurement) at stub depth, nine edge types, universal fields documented.*
