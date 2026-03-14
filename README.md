[![](https://img.shields.io/badge/sayless-vNext-informational)](https://github.com/gongahkia/sayless)

# `SayLess`

`SayLess` is a full-stack media summary app for people who want to skip ahead without losing the plot.

The product now centers on a consumer-friendly workflow:

1. Pick a source
2. Search a title
3. Choose a summary target
4. Select a spoiler level
5. Generate a structured recap

Anime and TV support episode-level summaries. Movies, manga, and books stay title-level and are labeled honestly as such.

## Why this repo exists

The original motivation was simple: sometimes you do not want to sit through a whole episode, chapter, or season just to keep going.

`SayLess` started as a stack-practice project and now aims to be a stronger portfolio repo by showing:

- A clearer full-stack product flow instead of raw-ID API testing
- A typed frontend/backend contract
- Source-aware search and target discovery
- Structured AI output with spoiler controls
- Better backend reliability and testability

## Stack

- Frontend: Next.js, React, TypeScript, Tailwind CSS
- Backend: Phoenix, Elixir
- Data sources: Jikan/MyAnimeList, TMDb, OpenLibrary
- AI: Gemini

## Product behavior

- `Anime`: search a series, load episodes, summarize a chosen episode
- `TV`: search a show, load episodes by season, summarize a chosen episode
- `Movies`: search a movie, summarize the full title overview
- `Manga`: search a manga, summarize the full title synopsis
- `Books`: search a work, summarize the full title description

Spoiler levels are available across all sources:

- `light`
- `standard`
- `full`

Recent summaries are stored in browser local storage only. There is no auth and no backend persistence in this version.

## Local setup

### Prerequisites

- Elixir and Mix
- Node.js and npm

### Backend configuration

Create `backend/.env`:

```env
GEMINI_API_KEY=YOUR_GEMINI_KEY
TMDB_API_KEY=YOUR_TMDB_KEY
```

### Frontend configuration

Optional:

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
```

If omitted, the frontend defaults to `http://localhost:4000`.

### Run locally

From the repo root:

```console
make
```

Or run each app separately:

```console
cd backend && mix phx.server
cd frontend && npm install && npm run dev
```

## API

### `GET /api/v1/search`

Searches titles for a specific source.

Example:

```console
curl "http://localhost:4000/api/v1/search?source=myanimelistanime&query=rezero"
```

### `GET /api/v1/media/:source/:media_id/targets`

Returns the valid summary targets for a selected title.

Example:

```console
curl "http://localhost:4000/api/v1/media/themoviedbtv/1399/targets"
```

### `POST /api/v1/summarize`

Creates a structured summary for a title or episode.

Example title-level request:

```console
curl -X POST http://localhost:4000/api/v1/summarize \
  -H "Content-Type: application/json" \
  -d '{
    "source": "themoviedbmovie",
    "media_id": "550",
    "target_type": "title",
    "spoiler_level": "standard"
  }'
```

Example episode-level request:

```console
curl -X POST http://localhost:4000/api/v1/summarize \
  -H "Content-Type: application/json" \
  -d '{
    "source": "themoviedbtv",
    "media_id": "1399",
    "target_type": "episode",
    "target_id": "1:1",
    "spoiler_level": "full"
  }'
```

Successful summary responses include:

- `media`
- `target`
- `summary.characters`
- `summary.key_events`
- `summary.plot_points`
- `summary.skip_context`
- `meta`

Error responses are normalized to:

```json
{
  "errors": {
    "code": "invalid_target_type",
    "detail": "This source does not support the requested target type."
  }
}
```

## Architecture

At a high level:

- The Next.js app owns source selection, search, target selection, spoiler level, and local recent-history state
- Phoenix exposes a small workflow API: `search`, `targets`, and `summarize`
- Source adapters normalize Jikan, TMDb, and OpenLibrary data into one internal shape
- The summarizer requests structured JSON from Gemini and validates the returned fields before responding

## Current tradeoffs

- Episode depth depends on what upstream public APIs expose
- There is no database, user account system, or server-side history
- Movies, books, and manga are intentionally title-level in this version
- Frontend test tooling is not set up yet; backend request coverage is the stronger test layer today

## Screenshots

Reference screenshots from the earlier UI are kept in [`asset/reference`](./asset/reference), but the current product flow has been redesigned around guided search and structured summary output.
