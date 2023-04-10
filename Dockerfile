FROM ubuntu:18.04
MAINTAINER David Hewitt <davidmhewitt@gmail.com>

# Enable source repositories so we can use `apt build-dep` to get all the
# build dependencies
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && \
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y -q && apt-get upgrade -y -q && apt-get update -y -q && \
    apt-get -q build-dep -y vala && \
    apt-get -q install -y \
    curl \
    git \
    unzip \
    xz-utils \
    && \
    cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws* \
    && \
    # Remove apt's lists to make the image smaller.
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root
COPY build /root/

WORKDIR /root