FROM ruby:3.2

# Install system dependencies required for v0.7.2
RUN apt-get update && \
    apt-get install -y poppler-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY . .

CMD ["ruby", "ai_structured_console.rb"]