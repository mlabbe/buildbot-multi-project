FROM ubuntu:16.04
MAINTAINER Michael Labbe <mike@frogtoss.com>

ARG password

# multi-purpose
RUN apt-get update && apt-get dist-upgrade -y

# basic building things, followed by more specific things
RUN apt-get install -y clang-4.0 \
            git \
            libffi-dev \
            libssl-dev \
            python-dev \
            python-pip \
            curl \
            sudo
            
# Test runs produce a great quantity of dead grandchild processes.  In
# a non-docker environment, these are automatically reaped by init
# (process 1), # so we need to simulate that here.  See
# https://github.com/Yelp/dumb-init
RUN mkdir /buildbot-worker && \
    useradd -ms /bin/bash buildbot && chown -R buildbot /buildbot-worker && \
    chown -R buildbot /buildbot-worker && \
    curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init

COPY buildbot.tac /buildbot-worker/buildbot.tac

# Upgrade issue-rife ubuntu pip
RUN pip install -U pip virtualenv && \
# install buildbot worker
    pip --no-cache-dir install \
         'twisted[tls]' && \
    pip --no-cache-dir install buildbot-worker
    
# configure worker
COPY admin /buildbot-worker/info
COPY host /buildbot-worker/info
WORKDIR /buildbot-worker


RUN chown -R buildbot /buildbot-worker
USER buildbot

CMD ["/usr/local/bin/dumb-init", "twistd", "-ny", "buildbot.tac"]
