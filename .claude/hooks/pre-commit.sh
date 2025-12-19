#!/bin/bash
# Pre-commit hook
# Runs rspec before git commit

set -e

PROJECT_NAME="haguruma"

# Function to run command in Docker or locally
run_in_docker_or_local() {
  local cmd="$1"
  local env_vars="${2:-}"

  if command -v docker &> /dev/null && docker compose -p "$PROJECT_NAME" ps app 2>/dev/null | grep -qE "Up|running"; then
    docker compose -p "$PROJECT_NAME" exec -T $env_vars app $cmd
  else
    $cmd
  fi
}

echo "Running rspec before commit..."

# Run rspec with test environment
if ! run_in_docker_or_local "bundle exec rspec" "-e RAILS_ENV=test"; then
  echo ""
  echo "============================================"
  echo "ERROR: Tests failed. Commit blocked."
  echo "============================================"
  echo ""
  # Exit code 2 blocks the tool execution in Claude Code hooks
  exit 2
fi

echo "All tests passed. Proceeding with commit."
exit 0
