# ./Dockerfile

# Extend from the official Elixir image
FROM elixir:latest

ENV WORKDIR /app
ENV NODE_ENV=prod
ENV NODE_MAJOR 14
ENV MIX_ENV prod
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# RUN apt-get update && apt-get install -y curl postgresql-client git

RUN mkdir "$WORKDIR"
COPY . "$WORKDIR"

WORKDIR "$WORKDIR"

RUN mix local.hex --force &&\
  mix local.rebar --force &&\
  MIX_ENV=prod mix deps.get --only prod &&\
  MIX_ENV=prod mix compile &&\
  curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash - && apt-get install -y nodejs inotify-tools &&\
  npm install --prefix ./assets &&\
  npm run deploy --prefix ./assets &&\
  mix phx.digest

EXPOSE 4000
CMD ["mix", "phx.server"]
