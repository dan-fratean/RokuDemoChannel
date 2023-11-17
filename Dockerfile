FROM ruby:3.0

WORKDIR /roku

RUN apt-get update
RUN apt-get -y install joe
RUN apt-get -y install zip
RUN apt-get -y install iputils-ping
RUN apt-get -y install rlwrap
RUN apt-get -y install telnet

#keeping it alive
# CMD tail -f /dev/null