[![](https://img.shields.io/badge/sayless_1.0.0-passing-green)](https://github.com/gongahkia/sayless/releases/tag/1.0.0) 

## Todo

* test backend is working properly
* figure out all the existing endpoints so that my frontend generation code is simple and can be focused on frontend
* add more endpoints within ./backend/lib/say_less/external_apis/
* add more backend external_apis support 
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

## Screenshots

...

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

## Endpoints

...

## Architecture

...

## Reference

...