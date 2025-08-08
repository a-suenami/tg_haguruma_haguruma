#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails_app/tmp/pids/server.pid

# Install missing gems
bundle check || bundle install --jobs 4 --retry 3

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"