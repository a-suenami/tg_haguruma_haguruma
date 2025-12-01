#!/bin/bash
# Post-edit hook for Ruby files
# Runs rubocop and sorbet after editing Ruby files

set -e

PROJECT_NAME="haguruma"

# Get the file path from CLAUDE_TOOL_INPUT (JSON format)
# Example: {"file_path": "/path/to/file.rb", ...}
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' 2>/dev/null || echo "")

# Skip if not a Ruby file
if [[ ! "$FILE_PATH" =~ \.rb$ ]]; then
  exit 0
fi

# Skip if file doesn't exist
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Function to run command in Docker or locally
run_in_docker_or_local() {
  local cmd="$1"

  if command -v docker &> /dev/null && docker compose -p "$PROJECT_NAME" ps app 2>/dev/null | grep -qE "Up|running"; then
    docker compose -p "$PROJECT_NAME" exec -T app $cmd
  else
    $cmd
  fi
}

# Get relative path for rubocop
RELATIVE_PATH="${FILE_PATH#$(pwd)/}"

echo "Running rubocop on $RELATIVE_PATH..."
run_in_docker_or_local "bundle exec rubocop -A $RELATIVE_PATH" || true

echo "Running sorbet type check..."
run_in_docker_or_local "bundle exec srb tc ." || true

echo "Post-edit checks completed."
