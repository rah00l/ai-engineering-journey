FROM ruby:3.2-alpine

# System deps (minimal)
RUN apk add --no-cache build-base

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock /app/
RUN bundle install

# Copy source
COPY . /app

CMD ["ruby", "openai_test.rb"]