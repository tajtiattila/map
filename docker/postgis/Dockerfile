FROM ubuntu:12.04

# based on https://github.com/helmi03/docker-postgis from Helmi <helmi@tuxuri.com>

MAINTAINER Attila Tajti <attila.tajti@gmail.com>

# Set the locale. This affects the encoding of the Postgresql template
# databases.
ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install ca-certificates
RUN apt-get -y install wget
RUN wget --quiet --no-check-certificate -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 postgis
RUN echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "port = 5432" >> /etc/postgresql/9.3/main/postgresql.conf

ENV PGSQL_DBNAME gis
ENV PGSQL_CFG main
ENV PGSQL_VER 9.3
ENV PGIS_VER 2.1

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config and logs
VOLUME  ["/etc/postgresql", "/var/log/postgresql"]

ADD run.sh /usr/local/bin/run
ADD psql-link.sh /usr/local/bin/psql-link
RUN chmod 0755 /usr/local/bin/run /usr/local/bin/psql-link

CMD ["/usr/local/bin/run", "init", "serve"]
