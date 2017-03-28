# See https://github.com/phusion/passenger-docker
FROM phusion/passenger-ruby24
MAINTAINER Pieter Martens "pieter@cg.nl"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Allow all host's
RUN echo "StrictHostKeyChecking no " > /root/.ssh/config

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
ADD vhost.conf /etc/nginx/sites-enabled/dcgw.conf
ADD http.conf /etc/nginx/conf.d/http.conf
ADD env.conf /etc/nginx/main.d/env.conf
VOLUME /var/log/nginx/log

# Create application environment
ADD . /app
WORKDIR /app

# Using temporary Github SSH key and excute bundler
RUN gem install bundler
RUN bundle install --jobs 4 --retry 5

# Create log folder
RUN mkdir -p /app/log
RUN chmod 0664 /app/log

RUN mkdir -p /app/tmp/cache
RUN chown -Rf app /app/tmp/cache

RUN /sbin/my_init

EXPOSE 80