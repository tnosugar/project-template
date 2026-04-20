# Knowledge Graph Schema

Authoritative reference for entity types, edge types, and frontmatter field definitions used across any project that adopts this schema. Synced from `tnosugar/project-template` via `scripts/sync-conventions.sh`; do not edit directly in a consumer project.

Works in concert with `.claude/conventions.md` §1 (frontmatter), which describes the *mechanics* of how frontmatter is written. This file describes the *vocabulary* of what can appear in it.

**Status: draft.** The schema is forward-looking. Typed fields are optional on all docs today; they become required for graph-relevant entity types once a query tool is built. Entity types and edge types will grow as real entities get cataloged in consumer projects; proposed extensions go through a PR against `tnosugar/project-template`.

---

## 1. Design approach

**Hybrid vocabulary.** Entity type names are borrowed from [Schema.org](https://schema.org) where the mapping is clean (Person, Organization, Article, Event). Names are invented where Schema.org does not fit the working-knowledge-graph use case (Project, Engagement, Topic, Measurement). Borrowing Schema.org names is not a commitment to Schema.org semantics; it is a cognitive saving and a forward-compatibility hook for emitting JSON-LD on public web pages if that ever becomes useful.

**Three orthogonal classifier layers: `type:`, `entity:`, `isa:`.** These answer different questions and can co-occur freely:

- **`type:`** — *what kind of document is this?* The doc's genre in the existing taxonomy: `strategy`, `research`, `copy`, `brief`, `decision`, `brand`, `process`, `spec`, `log`, `reference`. Matches the canonical subfolder the doc lives in (or would live in if split out).
- **`entity:`** — *what kind of thing in the world does this doc represent?* A doc can BE a Project, an Organization, a Person, a Content artifact, a Topic, a Measurement — the entity layer promotes the doc into a graph node. Optional; only set on graph-relevant docs.
- **`isa:`** — *what abstract class does the subject of the doc belong to?* `isa:` is separate from `entity:` because a document can be authored as Content (a Reference, say) *about* something in an abstract class the graph cares about. `speed-run-packages.md` is a Reference document *about* a Service — `entity: content, type: reference, isa: [service]`. Values are literal enums drawn from the controlled vocabulary in §3; the target does not need a corresponding file.

**Flat lists, not richer objects.** Cross-reference fields are flat arrays of repo-relative paths (`topics: [content/topics/marketing-attribution.md]`). `isa:` is the one exception: its values are literal enum strings, not paths, because its targets are abstract classes that may not have file nodes. A richer form (paths with role metadata per entry) may be added later if real queries require it; starting flat keeps the schema legible.

**Paths, not slugs.** Cross-references point at files, not abstract identifiers. This keeps the graph grounded in the filesystem and makes every edge verifiable by file-existence check. Slugs and display names belong inside the target file's own frontmatter. (Exception: `isa:` — see above.)

**Schema evolves with the corpus.** Every entity type in this document should be justified by at least one query someone has actually wanted to run. Speculative types are out of scope. New entity types, edge types, and `isa:` vocabulary values land as PRs with a named use case.

---

## 2. Entity types

Each entity type has a canonical name, a source (Schema.org-aligned or custom), a one-sentence definition, the `type:` values it typically carries in the existing doc taxonomy, and the key frontmatter fields that apply. Entity types defined at stub depth here; consumer projects are expected to flesh out per-entity registries as real entities land.

### Project
- **Source:** custom (Schema.org's `Project` is too thin).
- **Definition:** A named body of work with its own purpose, voice, and decision log. Typically one private/public repo pair today; under a unified graph, a subfolder.
- **Typical `type:` values:** `spec`, `process`, `strategy`.
- **Key fields:** `entity: project`, `client: []`, `people: []`, `topics: []`. A Project entity usually lives in the `CLAUDE.md` at the project's root (which carries its own frontmatter — see §4) or in a `content/projects/*.md` stub if multiple projects share a repo.
- **Example:** the NSC project's `CLAUDE.md` is a Project entity. So is the project-template's own `CLAUDE.md`.

### Organization
- **Source:** Schema.org (`Organization`).
- **Definition:** A company, firm, nonprofit, agency, or other institution referenced by the graph. Includes clients, partners, vendors, and the project-owning organization itself.
- **Typical `type:` values:** `brief`, `research`, or unset (an Organization entity may exist purely as a registry stub).
- **Key fields:** `entity: organization`, `people: []`, `topics: []`.
- **Lives in:** `content/organizations/` (create when the first Organization entity lands).

### Person
- **Source:** Schema.org (`Person`).
- **Definition:** An individual referenced by the graph. Includes project team members, client stakeholders, content authors, and named subjects.
- **Typical `type:` values:** usually unset (Person entities are registry stubs); occasionally `brief` for a detailed role description.
- **Key fields:** `entity: person`, `client: []` (if affiliated with a client organization), `project: []` (if affiliated with a project).
- **Lives in:** `content/people/` (create when the first Person entity lands).

### Content
- **Source:** custom parent; specific content kinds map to Schema.org (`Article`, `BlogPosting`, `SocialMediaPosting`, `VideoObject`, etc.) when useful.
- **Definition:** A discrete authored artifact: a published page, a LinkedIn post, a blog article, a podcast episode, an email, a deck, a video, OR an internal reference document, OR a service definition. The Content entity is the broad bucket for "this is a piece of authored prose"; `type:` carries the sub-flavor and `isa:` (when set) names the abstract class the subject belongs to.
- **Typical `type:` values:** `copy` (canonical text of a published artifact), `reference` (lookup/canon material like brand-copy blocks, glossaries, voice guides, or service definitions), `process` (long-form description of how something works), `spec` (page spec or design spec), or a channel-specific value on rendered artifacts.
- **Common `isa:` values when set:** `service`, `framework`, `method`, `pattern`, `voice_guide`, `reference_sheet`, `article` — see §3 for the full controlled vocabulary.
- **Key fields:** `entity: content`, `type:` (one of the above), `isa: []` (optional), `client: []`, `project: []`, `topics: []`, `people: []` (authors, subjects), `published: YYYY-MM-DD`, `channel:`, `platform:`. Content entities often also carry `derived_from: []` (source content this was built from) and `measurements: []` (performance records); those fields are introduced when Content becomes a tracked entity type in a consumer project.
- **Lives in:** anywhere under `content/`. Canonical text for channel artifacts in `content/copy/{channel}/[{platform}/]`; reference material in `content/brand/` or `content/services/` or alongside its peers; rendered artifact in the channel folder (`website/`, `social/`, etc.).

### Topic
- **Source:** custom.
- **Definition:** A subject-matter label attached to Content entities for retrieval. Flat or shallowly hierarchical; the taxonomy is per-project or per-graph.
- **Typical `type:` values:** usually unset (Topic entities are registry stubs with slug + description).
- **Key fields:** `entity: topic`, `related: []` (to parent or sibling topics in hierarchical taxonomies).
- **Lives in:** `content/topics/` (create when the first Topic entity lands). One file per topic; filename is the slug.
- **Governance note:** topic hygiene (consistent naming, avoiding synonyms, pruning unused topics) is the hard part of making Topic queries useful. Start narrow; add topics as content is tagged.

### Measurement
- **Source:** custom.
- **Definition:** A performance record linking a Content entity (or a campaign spanning multiple) to observed audience behavior and, where available, business outcomes. Measurements link out to where the real numbers live (dashboard URL, CRM export, anonymized snapshot); they do not embed sensitive client data.
- **Typical `type:` values:** `log` (a dated record of what happened) or `decision` (a synthesis of what multiple measurements show).
- **Key fields:** `entity: measurement`, `content: []` (the Content being measured), `client: []`, `project: []`, `published: YYYY-MM-DD` (when the measurement was taken).
- **Lives in:** `content/measurements/` (create when the first Measurement entity lands).
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
| `isa:` | Content → abstract class | asymmetric | "The subject of this doc belongs to this abstract class." Values are literal enums from the vocabulary below, not paths. Enables queries like "list every doc about a Service" without promoting Service to its own entity type. |
| `related:` | any → any | bidirectional by convention | Untyped fallback. See `.claude/conventions.md` §1. |

Bidirectionality is maintained by hand until a graph tool exists. When a graph tool is built, it audits asymmetries and surfaces them as candidates for fix.

### Controlled vocabulary for `isa:`

`isa:` values are enum strings. A doc can carry multiple (e.g. `isa: [service, pattern]`) when the subject legitimately belongs to several classes. New values land as PRs with a named use case — same rule as entity types.

| Value | Meaning | Example doc |
|---|---|---|
| `service` | The doc describes a named offer the organization sells. | A service-definition doc for "Speed Run Packages". |
| `framework` | The doc defines a named conceptual framework used internally or externally. | NSC's "Way of Work" and "Communications Compass" docs. |
| `method` | The doc describes a repeatable method or technique. | A doc describing a specific discovery interview method. |
| `pattern` | The doc describes a recurring pattern or template applied across instances. | A doc on "how we structure Week 1 of a discovery engagement". |
| `voice_guide` | The doc is a voice, tone, or copy reference used as raw material for generating other docs. | `brand-copy.md`-style reference sheets. |
| `reference_sheet` | Generic catch-all for lookup tables (glossaries, stakeholder lists, color palettes described in prose, etc.) that don't fit a more specific class. | A glossary of internal terms. |
| `article` | The doc is a catalog entry (metadata + editorial notes, not body text) for a published written artifact — a third-party publication piece, an owned-site blog post, or similar. Body text is typically not reproduced in the doc itself; the canonical URL points at the live artifact. | A catalog entry for a Psychology Today column piece or a Glinda's Edge blog post. |

A doc does not need an `isa:` — leave it unset if no vocabulary value applies, and open a PR if a new value is warranted.

---

## 4. Universal frontmatter fields

Fields present on every `content/*.md` regardless of entity type, AND on the project's root `CLAUDE.md` (treated as a Project entity). Defined here for reference; written on the doc per the YAML block in `.claude/conventions.md` §1.

- **`title`** — Human-readable title. Required.
- **`type`** — Internal doc category (`strategy | research | copy | brief | decision | brand | process | spec | log | reference`). Required. Determines canonical subfolder where applicable. `reference` is the genre for lookup/canon material (voice guides, brand-copy blocks, service definitions, glossaries) that isn't a channel artifact.
- **`status`** — Lifecycle state (`draft | review | final | archived`). Required.
- **`last_updated`** — ISO date of last meaningful body change. Required.
- **`related`** — Untyped peer associations (see §3 and `.claude/conventions.md` §1). Optional; default `[]`.
- **`renders_to`** — Rendered artifact paths. Optional; omit if the doc has no rendered artifact.

Entity-type-specific fields (`entity`, `isa`, `client`, `project`, `topics`, `people`, `published`, `channel`, `platform`, and others) are optional today and per-entity; see §2 for which fields matter for each entity type and §3 for edge semantics.

**Note on `CLAUDE.md`.** The project's root `CLAUDE.md` carries frontmatter and typically has `entity: project, type: spec`. It sits at the repo root rather than under `content/` because it is the project's working specification — the one file Claude reads first on every session. Being outside `content/` does not exempt it from the frontmatter rule; it is a deliberate exception to the "frontmatter on files under `content/`" surface, not an oversight.

---

## 5. Extending the schema

Schema extensions land as PRs against `tnosugar/project-template`. A PR to add a new entity type or edge type should include:

1. The new entity type or edge added to this file, at stub depth at minimum (name, source, definition, key fields, example).
2. A named use case: what query or workflow drove the extension. "It would be nice to have" is not sufficient; the schema only grows when a concrete need appears.
3. Any corresponding update to `.claude/conventions.md` §1 (the frontmatter block in the YAML example, or the prose around it).
4. Backfill guidance: whether existing docs need the new field, and if so, at what depth.

Consumer projects pull the change in via `scripts/sync-conventions.sh`.

---

*Last updated: 2026-04-20. Six entity types at stub depth (Project, Organization, Person, Content, Topic, Measurement). Ten edge types including `isa:` (literal-enum abstract-class edge with a seven-value controlled vocabulary: service, framework, method, pattern, voice_guide, reference_sheet, article). `type:` expanded to include `reference`. Three orthogonal classifier layers documented (`type:`, `entity:`, `isa:`). `CLAUDE.md` at project root carries Project-entity frontmatter.*
