FROM ruby:2.0
# Run on Ubuntu as:
#
# docker run -d -p 4567:4567 -v /etc/nagios3:/etc/nagios3 \
# -v /var/cache/nagios3:/var/cache/nagios3
# -v /var/lib/nagios3:/var/lib/nagios3 ortym/nagira
#
MAINTAINER Dmytro Kovalov <dmytro.kovalov@gmail.com>
RUN gem install --no-document nagira
CMD RACK_ENV=production /usr/local/bundle/bin/nagira -p 4567
