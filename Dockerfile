FROM ruby:2.6.0-alpine3.8

ENV BUNDLE_PATH /usr/local/bundle

RUN apk add bash git
RUN apk add sshpass openssh-client openssl-dev

RUN  echo "    IdentityFile /home/root/.ssh/id_rsa" >> /etc/ssh/ssh_config
WORKDIR src
CMD bash
