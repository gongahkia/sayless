[![](https://img.shields.io/badge/sayless_1.0.0-passing-light_green)](https://github.com/gongahkia/sayless/releases/tag/1.0.0) 
[![](https://img.shields.io/badge/sayless_2.0.0-passing-green)](https://github.com/gongahkia/sayless/releases/tag/2.0.0) 
![](https://github.com/gongahkia/sayless/actions/workflows/ci.yml/badge.svg)

# `SayLess`

Full Stack Web App that generates [summaries](#endpoints) for [Anime, Manga, Books and Movies](#support).

## Rationale

I watched [Episode 1](https://www.imdb.com/title/tt10112240/?ref_=ttep_ep_1) of [Re:Zero](https://www.imdb.com/title/tt5607616) [Season 2](https://www.imdb.com/title/tt5607616/episodes/?season=2) last week and despised its setting so much I wished I could [go next](https://www.urbandictionary.com/define.php?term=go+next) and just skip Season 2 entirely. 

`SayLess` is (*maybe*) a small step in the right direction.

<div align="center">
  <img src="./asset/reference/subaru.gif" width="50%">
</div>

## Stack

* *Frontend*: [Next.js](https://nextjs.org/), [React](https://react.dev/), [TypeScript](https://www.typescriptlang.org/), [Tailwind CSS]()
* *Backend*: [Phoenix](https://www.phoenixframework.org/), [Elixir](https://elixir-lang.org/), [Ecto](https://hexdocs.pm/ecto/)
* *API*: [OpenLibrary API](https://openlibrary.org/), [MyAnimeList API](https://myanimelist.net/apiconfig/references/api/v2), [TMDb API](https://developer.themoviedb.org/docs/getting-started), [Gemini 2.0 Flash API](https://ai.google.dev/gemini-api/docs/api-key)

## Screenshots

### Light Mode, Dark Mode

<div style="display: flex; justify-content: space-between;">
  <img src="./asset/reference/LightVanilla.png" width="48%">
  <img src="./asset/reference/DarkVanilla.png" width="48%">
</div>

### Books (OpenLibrary), Movies (TMDb)

<div style="display: flex; justify-content: space-between;">
  <img src="./asset/reference/OpenLibrary.png" width="48%">
  <img src="./asset/reference/TheMovieDB.png" width="48%">
</div>

### MyAnimeList (Anime, Manga)

<div style="display: flex; justify-content: space-between;">
  <img src="./asset/reference/MyAnimeListAnime.png" width="48%">
  <img src="./asset/reference/MyAnimeListManga.png" width="48%">
</div>

## Usage

The below instructions are for locally hosting `SayLess`.

1. First execute the below.

```console
$ git clone https://github.com/gongahkia/sayless && cd sayless
$ make setup 
```

2. Get your [Gemini API key](https://ai.google.dev/gemini-api/docs/api-key) and [TMDb API Key](https://developer.themoviedb.org/reference/intro/getting-started), then create an `.env` file at [backend](./backend).

```env
GEMINI_API_KEY=XXX
TMDB_API_KEY=XXX
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
```

3. Then run the below to spin up `SayLess`' frontend and backend.

```console
$ make
```

4. Optionally run the below additional single-purpose commands.

```console
$ make frontend-test
$ make frontend-build
$ make backend-test
$ make smoke-backend
$ make smoke-api
```

5. Alternatively, run `SayLess`' full stack with Docker to skip local installation of Elixir.

```console
$ make docker-up
```

## Support

`SayLess` currently supports the following mediums.

* **Anime**: Search a series, load episodes, summarize a chosen episode
* **TV**: Search a show, load episodes by season, summarize a chosen episode
* **Movies**: Search a movie, summarize the full title overview
* **Manga**: Search a manga, summarize the full title synopsis
* **Books**: Search a work, summarize the full title description

## Endpoints

For the exclusive purpose of testing the [Elixir backend](./backend/).

1. First run the below.

```console
$ cd backend && mix phx.server
```

2. Then use `curl` via the following to test POST reqeuests to the [Backend](./backend/).

| Media Type | Source | Schema | Example command |
| :--- | :--- | :--- |:--- | 
| Anime | [MyAnimeList](https://myanimelist.net/) | `{"source": "myanimelistanime", "media_id": <SHOWID>, "target_name": "Episode <EP_NUM>"}` | `curl -X POST http://localhost:4000/api/v1/summarize -H "Content-Type: application/json" -d '{"source": "myanimelistanime", "media_id": 16498, "target_name": "Episode 1"}'` |
| Manga | [MyAnimeList](https://myanimelist.net/) | `{"source": "myanimelistmanga", "media_id": <MANGAID>}` | `curl -X POST http://localhost:4000/api/v1/summarize -H "Content-Type: application/json" -d '{"source": "myanimelistmanga", "media_id": 2}'` | 
| Book | [OpenLibrary](https://openlibrary.org/) | `{"source": "openlibrary", "media_id": "<BOOKID>"}` |`curl -X POST http://localhost:4000/api/v1/summarize -H "Content-Type: application/json" -d '{"source": "openlibrary", "media_id": "OL45804W"}'` |
| Movie | [TMDb](https://www.themoviedb.org/) | `{"source": "themoviedb", "media_id": <MOVIEID>}` | `curl -X POST http://localhost:4000/api/v1/summarize -H "Content-Type: application/json" -d '{"source": "themoviedb", "media_id": 550}'` |

## Architecture

```mermaid
graph TD
    subgraph Browser
        User[End User] -->|Interacts with| P([src/app/page.tsx]);
        P -->|Renders| SF(components/SummaryForm);
        SF -->|User submits form| H(handleSummarize function);
        H -->|POST /api/v1/summarize with form data| R(Phoenix Router);
        H -->|Receives JSON & transforms data| P;
        P -->|Passes props to| SD(components/SummaryDisplay);
        SD -->|Renders summary| User;
    end

    subgraph "Phoenix Backend API"
        R[lib/say_less_web/router.ex] -->|Routes to| SC(controllers/v1/summary_controller.ex);
        SC -->|Invokes business logic| SUM(ai/summarizer.ex);
        SUM -->|Selects appropriate client| CLIENT(external_apis/client.ex);
        CLIENT -->|Fetches data from| ExternalAPIs;
        ExternalAPIs -->|Returns raw data| CLIENT;
        CLIENT -->|Passes data back| SUM;
        SUM -->|Calls Gemini API with context| Gemini;
        Gemini -->|Returns AI-generated summary| SUM;
        SUM -->|Returns summary data| SC;
        SC -->|Renders JSON response via| VIEW(views/v1/summary_view.ex);
        VIEW -->|Sends response to frontend| H;
    end

    subgraph "External APIs"
        ExternalAPIs(Data Sources);
        Gemini(Google Gemini API);
        subgraph "Data Fetching Modules"
            TMDB(external_apis/the_movie_db.ex);
            MAL(external_apis/my_anime_list_....ex);
            OL(external_apis/open_library.ex);
        end
        CLIENT -.->|Delegates to| TMDB;
        CLIENT -.->|Delegates to| MAL;
        CLIENT -.->|Delegates to| OL;
    end

    %% Original Styles
    style User fill:#f9f,stroke:#333,stroke-width:2px
    style P fill:#bbf,stroke:#333,stroke-width:2px
    style R fill:#f80,stroke:#333,stroke-width:2px
    style ExternalAPIs fill:#9f9,stroke:#333,stroke-width:2px
    style Gemini fill:#9f9,stroke:#333,stroke-width:2px

    %% Added Styles
    %% Browser
    style SF fill:#cde,stroke:#333,stroke-width:2px
    style H fill:#dae,stroke:#333,stroke-width:2px
    style SD fill:#e9f,stroke:#333,stroke-width:2px

    %% Phoenix Backend
    style SC fill:#f9a,stroke:#333,stroke-width:2px
    style SUM fill:#fab,stroke:#333,stroke-width:2px
    style CLIENT fill:#fbc,stroke:#333,stroke-width:2px
    style VIEW fill:#fcd,stroke:#333,stroke-width:2px

    %% External APIs / Data Fetching
    style TMDB fill:#afA,stroke:#333,stroke-width:2px
    style MAL fill:#bfB,stroke:#333,stroke-width:2px
    style OL fill:#cfC,stroke:#333,stroke-width:2px
```

## Other notes

[Elixir](https://elixir-lang.org/) is awesome. A pain to learn at first, but awesome.
