# ==============================================================================
# env
# ==============================================================================
# Usage: `source env.sh`
project_name='haguruma'

if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz colors
  colors
  RPROMPT="[%{${fg_bold[magenta]}%}$project_name%{${reset_color}%}]"
elif [ -n "$BASH_VERSION" ]; then
  prefix="(\[\e[35m\]$project_name\[\e[0m\])"
  PS1="$prefix $PS1"
fi

if command -v docker &> /dev/null; then
  # aliases for host machine, not in docker container
  alias docker-compose="docker compose -p $project_name"
  alias build="docker-compose build"
  alias up="rm -f tmp/pids/server.pid && docker-compose up"
  alias stop="docker-compose stop"
  alias app="rm -f tmp/pids/server.pid && up app"
  alias rails="bundle exec rails"
  alias rake="bundle exec rake"
  alias rspec="docker-compose-run -e RAILS_ENV=test app rspec"
  alias rspec_parallel="docker-compose-run -e RAILS_ENV=test --rm app bash -c 'CORES=${PARALLEL_JOBS:-$( (command -v nproc >/dev/null && nproc) || getconf _NPROCESSORS_ONLN || sysctl -n hw.ncpu || echo 4 )}; bundle exec rake parallel:create parallel:prepare && bundle exec parallel_test --type rspec -n $CORES'"
  alias rubocop="bundle exec rubocop -DES --cache true"
  alias lint="bundle exec rubocop -a"
  alias rubocop_show_class="bundle exec rubocop -D"
  alias guard="docker-compose run -e RAILS_ENV=test --rm app bundle exec guard"
  alias yarn="docker-compose-run app yarn"
  alias tapioca="docker-compose-run -e RAILS_ENV=test app bin/tapioca"
  alias annotate="docker-compose-run app bundle exec annotate"

  # Helper function to use exec if container is running, otherwise use run
  docker-compose-run() {
    if docker compose -p $project_name ps app 2>/dev/null | grep -q "Up\|running"; then
      docker compose -p $project_name exec "$@"
    else
      docker compose -p $project_name run --rm "$@"
    fi
  }

  bundle() {
    docker-compose-run -e RAILS_ENV=${RAILS_ENV:=development} app bundle "$@"
  }
fi

# json formatting and copy
function jpy {
  echo $1 | jq | pbcopy
}

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
