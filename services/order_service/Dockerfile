# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.8
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Instalar dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  git \
  curl \
  libyaml-dev

# Crear directorio de trabajo
WORKDIR /app

# Copiar Gemfile primero y hacer bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copiar el resto de la aplicación
COPY . .

# Exponer el puerto de Rails
EXPOSE 3000

# Comando por defecto
CMD ["rails", "server", "-b", "0.0.0.0"]