# SayLess Repository Audit

## 1) Repository Structure, Intent, and Purpose

`sayless` is a full-stack media summary product that helps people skip parts of media while keeping enough context to continue.

Current structure:

- `frontend/`: Next.js client with search, target selection, spoiler-level selection, and structured summary rendering.
- `backend/`: Phoenix JSON API for search, target discovery, and summary generation.
- `backend/lib/say_less/external_apis/`: adapters for MyAnimeList (via Jikan), TMDb, and OpenLibrary.
- `backend/lib/say_less/ai/summarizer.ex`: Gemini-backed summarization engine using a strict JSON response schema.
- `scripts/`: setup and smoke-test scripts.
- `.github/workflows/ci.yml`: frontend and backend CI checks.

Product intent:

- Turn fragmented upstream metadata into a consistent summary contract.
- Let users choose summary depth (`light`, `standard`, `full`) before generation.
- Support both segment-level skips (anime/TV episodes) and title-level recaps (movie/manga/book).

## 2) Ideal User Personas

Persona A: Continuity-focused skipper
- Job-to-be-done: skip weak episodes/arcs without losing narrative continuity.
- Best served by: episode targets, carry-forward context, key events.

Persona B: Time-constrained media explorer
- Job-to-be-done: decide quickly whether to continue a show/book/movie.
- Best served by: fast search, title-level synopsis compression, consistent output schema.

Persona C: Demo/recruiter/portfolio reviewer
- Job-to-be-done: evaluate architecture and product quality quickly.
- Best served by: clear API contracts, deterministic tests, one-command confidence checks.

## 3) Pain Relievers and Gain Creators

### Existing pain relievers

- Source-specific complexity is hidden behind one frontend flow (`search -> target -> summarize`).
- Invalid requests are blocked early in backend validation with explicit error codes.
- Structured output (`characters`, `key_events`, `plot_points`, `skip_context`) reduces “wall of text” summaries.
- Local recents reduce repeat search friction during repeated use/demo sessions.

### Existing gain creators

- Spoiler-level control creates configurable trust and user agency.
- Segment-aware sources (anime/TV) increase perceived precision and usefulness.
- Unified API contract across sources makes frontend integration and testing straightforward.

### Gaps that limit value today

- Local onboarding confidence is fragmented across several commands.
- CI parity is not obvious for contributors without local `mix`.
- Duplicate frontend Next config files create avoidable ambiguity.

## 4) How General Users Will Pick This Up

For a general user who wants fast pickup, the highest-value path is:

1. Setup dependencies once.
2. Run frontend/backend dev servers.
3. Search a title, choose a target, and generate a summary.
4. Run one quality command before sharing or opening a PR.

The repository already supports steps 1-3 well. The biggest pickup improvement is step 4: a single local CI parity command that matches GitHub Actions behavior.

## 5) Engineering Audit

### Strengths

- Clear backend layering:
  - request validation
  - source adapter dispatch
  - summarization orchestration
- Good external API error normalization (`upstream_*` code family).
- Test strategy uses a fake HTTP client to avoid network dependence during backend tests.
- Frontend contract typing is explicit and consistent with backend payload shape.

### Risks and friction points

- Tooling parity risk: contributors without local Elixir cannot easily run backend CI-equivalent checks.
- Config ambiguity risk: both `frontend/next.config.ts` and `frontend/next.config.mjs` exist.
- Stub signal risk: placeholder comment in Next config weakens “production-ready” impression.
- Operational UX risk: no single command that mirrors CI across frontend + backend checks.

## 6) User-Facing Audit

### Strengths

- Workflow is intuitive and linear.
- Copy explains target-level differences across sources.
- Error handling already surfaces backend-provided human-readable detail.

### Improvement opportunities

- User trust is reinforced when engineering reliability is demonstrable with one command.
- Contributor and evaluator experience improves when repository configuration has one obvious path.

## 7) Changes Implemented in This Audit

The following improvements are implemented directly in this repository:

- Added `scripts/ci_local.sh` to run CI-equivalent checks locally.
- Added Docker backend fallback in `scripts/ci_local.sh` for environments without `mix`.
- Added `make ci-local` entrypoint in `Makefile`.
- Fixed backend Docker base image to a valid maintained tag (`elixir:1.17`).
- Fixed Docker backend reachability in dev via `PHX_BIND_ALL` support.
- Added deterministic mode to `scripts/smoke_api.sh` (`MODE=validation`).
- Added strict runtime env validation in backend (`runtime.exs`) for required keys and port parsing.
- Removed redundant `frontend/jsconfig.json` to avoid config overlap.
- Removed unused frontend UI scaffolding files and dependencies.
- Cleared frontend dependency vulnerabilities to `0` via lockfile updates (`npm audit` clean).
- Consolidated Next config to `frontend/next.config.ts`.
- Removed duplicate `frontend/next.config.mjs`.
- Replaced placeholder Next config comment with explicit, non-stub config.

## 8) Rationale for Each Implemented Change

- `doc.md`: centralizes product/persona/value and audit analysis in a maintained doc without editing `README.md`.
- `scripts/ci_local.sh`: removes contributor uncertainty and creates repeatable pre-push confidence.
- Docker fallback in `scripts/ci_local.sh`: keeps backend verification accessible when Elixir toolchain is not installed locally.
- `Makefile` target: lowers command-discovery friction for general users.
- Backend Docker base image fix: prevents hard failures when building/running backend in Docker.
- `PHX_BIND_ALL` support: ensures containerized backend is reachable from host-mapped ports.
- Deterministic `smoke_api.sh` mode: enables stable smoke checks without live upstream dependencies.
- Strict runtime env validation: fails fast on missing/empty secrets and malformed numeric settings.
- Removal of redundant frontend configs/scaffolding: reduces cognitive load and dead code maintenance.
- Dependency hygiene update: reduces security risk and suppresses avoidable audit noise.
- Next config consolidation: removes ambiguity and avoids split-brain configuration behavior.

## 9) Remaining Backlog (Not Modified in This Pass)

- Add explicit environment templates for frontend runtime variables.
- Add explicit contributor guide for expected local toolchains and troubleshooting.
- Expand frontend tests for error-code-specific user messaging and stale-request race scenarios.

## 10) Remaining Stub/Partial Areas Worth Upgrading

- Frontend error UX currently passes through backend messages directly; adding code-aware client messaging would improve guidance quality.

## 11) Engineering Considerations

- Reliability:
  - Add request timeouts and retry/backoff policies per upstream adapter, with explicit circuit-breaker behavior for 429/5xx patterns.
- Observability:
  - Add structured logs with source, media_id, target_type, and error code dimensions for debugging and upstream monitoring.
- Contract safety:
  - Add schema-level integration tests that assert frontend contract compatibility against backend JSON fixtures.
- Security:
  - Ensure no API keys are ever logged and enforce redaction in all error paths.
- Performance:
  - Cache target lists/search results briefly in backend for repeated queries in short windows.

## 12) High-Value Feature Ideas

- Account-based history:
  - Persist summaries across devices instead of browser-local recents only.
- “What changed if I skip?” mode:
  - Add a dedicated delta section that highlights only state transitions.
- Character map mode:
  - Add relationship snapshots and alliance/conflict updates after skipped segments.
- Confidence labels:
  - Add metadata confidence based on upstream data completeness and summary context quality.
- Export modes:
  - One-click export to markdown/plain-text for notes, group chats, and watch-party contexts.
