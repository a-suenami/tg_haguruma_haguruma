FROM ruby:3.3.0

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    curl \
    less \
    vim \
    git \
    jq \
    libyaml-dev \
    libsodium-dev \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && corepack enable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
