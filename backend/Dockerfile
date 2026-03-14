FROM hexpm/elixir:1.17.3-erlang-27.0.1-debian-bookworm-20240612

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

RUN mix local.hex --force && mix local.rebar --force

COPY backend/mix.exs backend/mix.lock ./
COPY backend/config ./config

RUN mix deps.get

COPY backend ./

ENV MIX_ENV=dev
ENV PHX_SERVER=true
ENV PORT=4000

EXPOSE 4000

CMD ["mix", "phx.server"]
