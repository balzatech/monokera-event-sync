#!/bin/bash
set -e

# Ejecutar migraciones y seeds
bundle exec rails db:prepare
bundle exec rails db:seed

echo "🚀 Iniciando el servidor..."
exec "$@"
