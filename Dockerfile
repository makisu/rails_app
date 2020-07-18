FROM ruby:2.7.1
LABEL maintainer="Xavi Ablaza <xavi@makisu.co>"

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && \
  apt-get upgrade -y && \
  apt-get install -y libldap2-dev libidn11-dev build-essential libpq-dev nodejs postgresql-client nodejs yarn && \
  # Keep image size small:
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV APP=/app
RUN mkdir $APP
WORKDIR $APP

ENV BUNDLE_GEMFILE=$APP/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle \
  PATH=./bin:$PATH \
  RAILS_ENV=production \
  NODE_ENV=production \
  SECRET_KEY_BASE=4e2ba1cf3ffc0cd4f5c5b2efed22adab6e0d5157b1129af4891248e4a7edadb1339f12330550f898ce355dc84c1d28e1063125ed815f3158588d6fb76971bf0c

RUN mkdir $BUNDLE_PATH

ADD Gemfile $APP/Gemfile
ADD Gemfile.lock $APP/Gemfile.lock

RUN bundle config --local build.sassc --disable-march-tune-native

RUN gem install bundler --no-document && \
  bundle install --jobs 20 --retry 5 --without development test

ADD . $APP

RUN bundle exec rails assets:precompile && \
  bundle exec rails assets:clean

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000"]
