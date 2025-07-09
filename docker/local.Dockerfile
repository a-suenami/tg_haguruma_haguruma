FROM ruby:3.4.4-alpine

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
    vim

WORKDIR /rails_app

# Install bundler
RUN gem install bundler

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Bundle install
RUN bundle install

# Copy the rest of the application
COPY . .

# Expose port
EXPOSE 3000

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]