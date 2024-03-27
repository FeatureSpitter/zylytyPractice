#!/bin/bash
set -e

rm -f /myapp/tmp/pids/server.pid

# Check environment variables
: "${DB_HOST:?DB_HOST not set}"
: "${DB_PASSWORD:?DB_PASSWORD not set}"
: "${DB_PORT:?DB_PORT not set}"
: "${DB_USERNAME:?DB_USERNAME not set}"
: "${RAILS_ENV:?RAILS_ENV not set}"


# Wait for the database to be ready
while ! nc -z $DB_HOST $DB_PORT; do
  echo "Waiting for the database to be ready..."
  sleep 2
done

# Initialize the database
rails db:prepare

echo "Database is up - executing command"
exec "$@"
