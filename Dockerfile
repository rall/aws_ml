FROM vitals/centos-ruby:7-ruby2.3.3
MAINTAINER services-engineering@vitals.com

# create the deploy user
RUN adduser -u 1000 -ms /bin/bash deploy

# install bundler for deploy user
RUN gem install bundler --no-ri --no-rdoc

RUN mkdir -p /app/vendor/cache
ADD .bundle/config /app/.bundle/config
ADD Gemfile /app/
ADD Gemfile.lock /app/
ADD vendor/cache /app/vendor/cache
RUN chown -R deploy:deploy /app
RUN chown -R deploy:deploy $RUBY_DIR

USER deploy
WORKDIR /app
RUN gem update --system
RUN bundle install --jobs 3 --retry 3 --system

USER root
COPY . /app
RUN chown -R deploy:deploy /app

USER deploy

ENTRYPOINT ["/app/docker-entrypoint.sh"]
