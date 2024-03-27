FROM ruby:3.2.2

WORKDIR /app

ENV RAILS_ENV=development \
    RAILS_LOG_TO_STDOUT=true

RUN apt-get update -qq && apt-get install -y postgresql-client netcat-openbsd && rm -rf /var/lib/apt/lists/*

RUN gem install bundler:2.4.21
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN export $(cat .env | xargs)
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

