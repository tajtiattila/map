FROM ubuntu:latest
MAINTAINER Attila Tajti <attila.tajti@gmail.com>

# Set the locale. This affects the encoding of the Postgresql template
# databases.
ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

RUN apt-get update -y

# Install development dependencies
RUN apt-get install -y git-core tar unzip wget bzip2 build-essential autoconf libtool

# Install specific dependencies
RUN apt-get install -y libxml2-dev libgeos++-dev libpq-dev libbz2-dev libproj-dev \
	libprotobuf-c0-dev protobuf-c-compiler lua5.2 liblua5.2-dev

# Install osm2pgsql
RUN cd /tmp && git clone git://github.com/openstreetmap/osm2pgsql.git
RUN cd /tmp/osm2pgsql && \
    ./autogen.sh && \
    ./configure && \
    make && make install

# Install osmconvert
RUN wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o /usr/local/bin/osmconvert
