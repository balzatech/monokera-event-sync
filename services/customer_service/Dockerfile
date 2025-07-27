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

# Copia el script entrypoint y le da permisos de ejecución
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# El entrypoint se encargará de las tareas de inicio (ej. migraciones)
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

# El CMD es el comando por defecto. Si no se especifica un 'command'
# en docker-compose.yml, se ejecutará este.
CMD ["rails", "server", "-b", "0.0.0.0"]
