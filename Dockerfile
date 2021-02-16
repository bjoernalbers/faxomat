FROM ruby:2.0
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    nodejs \
    libcups2-dev && \
  rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/faxomat
WORKDIR /opt/faxomat
VOLUME /opt/faxomat/storage
COPY Gemfile* ./
RUN bundle install --binstubs
COPY . .
EXPOSE 3000
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
