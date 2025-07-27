#!/bin/bash
set -e

# Realiza cualquier tarea de configuración inicial
echo "Esperando a que la base de datos esté disponible..."

echo "Postgres está disponible, ejecutando migraciones..."
bundle exec rails db:migrate

# Ejecuta el comando que se le pasa al contenedor (web server, worker, etc.)
echo "Ejecutando el comando: $@"
exec "$@"
