FROM ruby:2.6.1

RUN apt-get update -qq && apt-get install -y apt-utils && apt-get install -y curl && apt-get install -y postgresql-client && apt-get install -y rubygems && gem install bundler -v "~>2.0.2" && apt-get install -y lsof

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN mkdir /projects
RUN mkdir /projects/docker_deploy
COPY . /projects/docker_deploy
WORKDIR /projects/docker_deploy

RUN bundle install --deployment --without development test

ENV RAILS_ENV production

RUN set -e

# Remove a potentially pre-existing server.pid for Rails.
#RUN kill -9 $(lsof -i :3000)
#RUN rm -f /projects/docker_deploy/tmp/pids/server.pid
# Then exec the container's main process (what's set as CMD in the Dockerfile).
RUN cd /projects/docker_deploy && bundle exec rails assets:precompile
 
# Start the server
RUN cd /projects/docker_deploy && bundle exec rails db:create db:migrate db:seed
RUN cd /projects/docker_deploy && bundle exec rails server -b 0.0.0.0


#ENTRYPOINT ['/projects/docker_deploy/docker_deploy_entrypoint.sh']
