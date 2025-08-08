# ==============================================================================
# docker - scripts - apt install.local
# ==============================================================================
apt-get update -qq && \
  apt-get install -y \
    build-essential \
    libpq-dev \
    tzdata \
    less \
    libsodium-dev \
    git \
    curl \
    gnupg2 \
    lsb-release \
    unzip \
    libjemalloc2 \
    ca-certificates \
    watchman \
    libjq-dev

# pg_dump for pg15 のインストール
curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

apt-get update -qq && \
  apt-get install -y \
    postgresql-client-15 \

# Node.js と Yarn のインストール
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

apt-get update -qq && \
  apt-get install -y \
    nodejs \
    yarn