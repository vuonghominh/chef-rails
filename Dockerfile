# Base image:
FROM ruby:2.4-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libmysqlclient-dev

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /home/web/site
RUN mkdir -p $RAILS_ROOT

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Gems:
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install

COPY config/puma.rb config/puma.rb

# Copy the main application.
COPY . .

EXPOSE 3000

# Starts the Puma server.
CMD bundle exec puma -C config/puma.rb
