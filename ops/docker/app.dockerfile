# ==== Build Image ====

# Arguments
ARG MIX_ENV="prod"

# Dockerfile
FROM elixir:1.14 AS build

# install build dependencies
RUN apt-get update && \
  apt-get install -y \
  bash \
  curl \
  gcc \
  git\
  inotify-tools \
  libssl1.1 \
  make \
  openssl

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile configuration files
RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/

# compile deps
RUN mix deps.compile

# copy assets
COPY priv priv
COPY assets assets

# Compile assets
RUN mix assets.deploy

# compile project
COPY lib lib
RUN mix compile

# copy runtime configuration file
COPY config/runtime.exs config/

EXPOSE 443
EXPOSE 4000
EXPOSE 4369
EXPOSE 9001

CMD ["mix", "phx.server"]
