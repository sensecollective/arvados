# Copyright (C) The Arvados Authors. All rights reserved.
#
# SPDX-License-Identifier: AGPL-3.0

FROM ubuntu:precise
MAINTAINER Ward Vandewege <ward@curoverse.com>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies.
RUN /usr/bin/apt-get update && /usr/bin/apt-get install -q -y python2.7-dev python3 python-setuptools python3-setuptools libcurl4-gnutls-dev curl git libattr1-dev libfuse-dev libpq-dev python-pip build-essential unzip

# Install RVM
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys D39DC0E3 && \
    curl -L https://get.rvm.io | bash -s stable && \
    /usr/local/rvm/bin/rvm install 2.3 && \
    /usr/local/rvm/bin/rvm alias create default ruby-2.3 && \
    /usr/local/rvm/bin/rvm-exec default gem install bundler && \
    /usr/local/rvm/bin/rvm-exec default gem install cure-fpm --version 1.6.0b

# Install golang binary
ADD generated/go1.8.3.linux-amd64.tar.gz /usr/local/
RUN ln -s /usr/local/go/bin/go /usr/local/bin/

# Old versions of setuptools cannot build a schema-salad package.
RUN pip install --upgrade setuptools

ENV WORKSPACE /arvados
CMD ["/usr/local/rvm/bin/rvm-exec", "default", "bash", "/jenkins/run-build-packages.sh", "--target", "ubuntu1204"]
