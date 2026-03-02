# Node.js を公式イメージからコピー（arm64/amd64 両対応）
FROM node:22-alpine AS node

FROM ruby:3.3.0-alpine

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Node.js をコピー
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    tzdata \
    git \
    bash \
    curl \
    less \
    vim \
    autoconf \
    automake \
    libtool \
    jq \
    jq-dev \
    yaml-dev \
    libsodium-dev \
    gcompat \
    libstdc++ && \
    npm install -g yarn

WORKDIR /rails_app

# Install bundler
RUN gem install bundler

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Bundle install
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Add entrypoint script
COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Expose port
EXPOSE 3000

# Set entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]