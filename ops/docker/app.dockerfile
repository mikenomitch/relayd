# Dockerfile
FROM elixir:1.14

# install build dependencies
# RUN apk add --update git bash gcc libssl1.1 make openssl

RUN apt-get update && \
  apt-get install -y inotify-tools git bash gcc libssl1.1 make openssl

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock config ./
RUN mix deps.get --only prod

COPY ./ ./
EXPOSE 4000

CMD ["mix", "phx.server"]
