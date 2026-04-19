## Summary

Two changes that turn the existing `related[]` + `renders_to:` substrate into a working knowledge-graph schema:

- **`.claude/conventions.md` §1 — Frontmatter on docs.** YAML example split into core fields (unchanged) and typed graph fields (`entity`, `client`, `project`, `topics`, `people`, `published`). New prose covers: `type:` vs `entity:` distinction; typed-fields-vs-`related[]` rule (typed fields take priority, `related[]` is untyped fallback); bidirectionality maintained by hand until a graph tool exists; body links vs frontmatter links (narrative vs index); pointer to SCHEMA.md as authoritative.
- **`.claude/SCHEMA.md` (new, 121 lines).** Knowledge-graph schema at stub depth. Six entity types: Project (custom), Organization (Schema.org), Person (Schema.org), Content (custom parent; Article / BlogPosting / etc. where applicable), Topic (custom), Measurement (custom). Nine edge types in a table. Design approach: hybrid vocabulary (Schema.org where clean, custom where not), flat lists not richer objects, paths not slugs, schema evolves with the corpus. Extension process: PRs against `tnosugar/project-template` with a named use case.
- **`scripts/sync-manifest.txt`.** `.claude/SCHEMA.md` added so it propagates to consumer projects on sync.

Typed fields are **optional on all docs today**. They become required for graph-relevant entity types once a query tool is built. The schema is drafted from two real queries that drove the design ("content pieces that performed best for clients X, Y, Z on CLV over 12 months" and "LinkedIn posts from content tagged with topic X over 3 years") and is expected to grow as real entities land in consumer projects.

## Test plan

- [ ] Review the typed-vs-`related[]` rule reads clearly for a new contributor.
- [ ] Confirm the six entity types cover the first cohort of docs in `tnosugar/nsc-private` without gaps.
- [ ] After merge: run `./scripts/sync-conventions.sh` from nsc-private and verify both files pull in cleanly.
- [ ] After merge: add `entity: project` + `project: []` frontmatter to nsc-private's existing `docs/*.md` files as a first-pass adoption, log in §9.
