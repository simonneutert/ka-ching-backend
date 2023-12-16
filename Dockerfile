FROM ruby:3.2-slim

ARG uid=1337
ARG user=killerbuchhalter
ARG gid=1337
ARG usergroup=killerbuchhaltergroup

ENV	LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8

ENV WORKDIR=/app
WORKDIR ${WORKDIR}

RUN apt-get update && \ 
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  build-essential \
  libjemalloc2 \
  libpq-dev \
  netbase \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --gid $gid $usergroup \
  && useradd --uid $uid --gid $uid -m $user 

COPY --chown=$uid:$gid Gemfile* ${WORKDIR}/
RUN bundle install -j4

COPY --chown=$uid:$gid . .

USER $user

CMD bundle exec rackup -o0
