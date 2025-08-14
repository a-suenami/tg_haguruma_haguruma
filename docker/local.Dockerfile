FROM ruby:3.3.0-alpine

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    nodejs \
    yarn \
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
    libstdc++

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