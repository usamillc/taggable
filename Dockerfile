FROM ruby:2.5

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy application files and install the bundle
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .

# Run asset pipeline.
RUN bundle exec rake assets:precompile

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true

EXPOSE 8080
EXPOSE 7433
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-p", "8080", "-e", "production"]
