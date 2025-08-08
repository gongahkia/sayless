[![](https://img.shields.io/badge/sayless_1.0.0-passing-green)](https://github.com/gongahkia/sayless/releases/tag/1.0.0) 

## Todo

* continue debugging from this point onward https://www.perplexity.ai/search/i-want-to-create-a-full-stack-74p4e0tvRUSYH.gSf.0sAg and attempt the change perplexity suggested
* add more backend external_apis support 
* test backend is working properly
* properly debug and ensure i understand what's happening with the backend
* then generate frontend
* then link backend and frontend
* furnish README.md

# `SayLess`

... add funny logo here

## Rationale

... Something about spoilers and not wanting to rewatch Rezeero season 2

## Stack

* *Frontend*: [Next.js](https://nextjs.org/), [React](https://react.dev/), [TypeScript](https://www.typescriptlang.org/)
* *Backend*: [Phoenix](https://www.phoenixframework.org/), [Elixir](https://elixir-lang.org/), [Ecto](https://hexdocs.pm/ecto/)
* *DB*: 
* *Auth*: 
* *Cache*: 

## Usage

The below instructions are for locally hosting `SayLess`.

1. First execute the below.

```console
$ git clone https://github.com/gongahkia/sayless && cd sayless
$ cd backend && mix deps.get
```

2. Get your [Gemini API key](https://ai.google.dev/gemini-api/docs/api-key) and create an `.env` file at [backend](./backend).

```env
GEMINI_API_KEY=XXX
```

3. Finally run the below.

```console
$ mix phx.server
```

## Screenshots

...

## Architecture

...

## Reference

...