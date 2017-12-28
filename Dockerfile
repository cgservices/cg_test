# See https://github.com/phusion/passenger-docker
FROM phusion/passenger-ruby23:0.9.19
MAINTAINER Pieter Martens "pieter@cg.nl"

ENV RAILS_ENV=production
ENV PASSENGER_APP_ENV=production

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update -qq && apt-get install -y \
                          build-essential \
                          locales \
                          nodejs \
                          mysql-client \
                          libmysqld-dev \
                          libmysqlclient-dev \
                          vim \
                          htop

# Use en_US.UTF-8 as our locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ARG RAILS_ENV

# Using Nginx and Passenger
RUN rm -f /etc/service/nginx/down

# Create Nginx environment
RUN rm /etc/nginx/sites-enabled/default
ADD vhost.conf /etc/nginx/sites-enabled/vhost.conf
ADD http.conf /etc/nginx/conf.d/http.conf
ADD env.conf /etc/nginx/main.d/env.conf
VOLUME /var/log/nginx

# Create application environment
ADD . /app
WORKDIR /app

# Using temporary Github SSH key and excute bundler
RUN gem install bundler
RUN bundle install --jobs 4 --retry 5 --without development

# Create log folder
RUN mkdir -p /app/log
RUN chmod 0664 /app/log

RUN mkdir -p /app/tmp/cache

# Change owner
RUN chown app:app -Rf /app

RUN bundle exec assets:precompile

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
