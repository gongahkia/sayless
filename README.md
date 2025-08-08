[![](https://img.shields.io/badge/sayless_1.0.0-passing-green)](https://github.com/gongahkia/sayless/releases/tag/1.0.0) 

# `SayLess`

Full Stack Web App that generates summaries for [Multiple Entertainment Mediums](#endpoints) *(anime, manga, books, movies)*.

Made mostly to practise [this stack](#stack). Other comments can be found [here](#other-notes).

## Rationale

I watched [Episode 1](https://www.imdb.com/title/tt10112240/?ref_=ttep_ep_1) of [Re:Zero](https://www.imdb.com/title/tt5607616)'s [Second Season](https://www.imdb.com/title/tt5607616/episodes/?season=2) last week and hated the setting so much I wished I could skip Season 2 and just [go next](https://www.urbandictionary.com/define.php?term=go+next).

So I made [***this Web App***](https://github.com/gongahkia/sayless) to serve that end.

<div align="center">
  <img src="./asset/reference/subaru.gif" width="50%">
</div>

## Stack

* *Frontend*: [Next.js](https://nextjs.org/), [React](https://react.dev/), [TypeScript](https://www.typescriptlang.org/)
* *Backend*: [Phoenix](https://www.phoenixframework.org/), [Elixir](https://elixir-lang.org/), [Ecto](https://hexdocs.pm/ecto/)
* *API*: [OpenLibrary API](https://openlibrary.org/), [MyAnimeList API](https://myanimelist.net/apiconfig/references/api/v2), [TMDb API](https://developer.themoviedb.org/docs/getting-started)

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
$ chmod +x dev.sh
```

2. Get your [Gemini API key](https://ai.google.dev/gemini-api/docs/api-key) and [TMDb API Key](https://developer.themoviedb.org/reference/intro/getting-started), then create an `.env` file at [backend](./backend).

```env
GEMINI_API_KEY=XXX
TMDB_API_KEY=XXX
```

3. Finally run the below.

```console
$ make
```

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

![](...)

## Other notes

[Elixir](https://elixir-lang.org/) is awesome. A pain to learn at first, but awesome.