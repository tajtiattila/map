#!/bin/bash

DBNAME=gis

PGVER=9.3
CONFIG=main

ASPG="su postgres"
DATADIR="/var/lib/postgresql/$PGVER/$CONFIG"
CONFIGFILE="/etc/postgresql/$PGVER/$CONFIG/postgresql.conf"
LOGFILE="/var/log/postgresql/postgresql-$PGVER-$CONFIG.log"
PGCTL="/usr/lib/postgresql/$PGVER/bin/pg_ctl"
INITDB="/usr/lib/postgresql/$PGVER/bin/initdb"
PGISCONTRIB="/usr/share/postgresql/$PGVER/contrib/postgis-2.1"

function initdb() {
	# test if DATADIR is existent
	if [ ! -d $DATADIR ]; then
		echo "Creating Postgres data at $DATADIR"
		mkdir -p $DATADIR
	fi

	# test if DATADIR has content
	if [ ! "$(ls -A $DATADIR)" ]; then
		echo "Initializing Postgres Database at $DATADIR"
		chown -R postgres $DATADIR
		$ASPG sh -c "$PGCTL -D $DATADIR initdb"
	fi
}

function startdb() {
	echo "Starting database"
	if tty --silent; then
		LOG="-l $LOGFILE"
	else
		LOG=
	fi
	$ASPG sh -c "$PGCTL -D $DATADIR $LOG -o '-c config_file=/etc/postgresql/9.3/main/postgresql.conf' start"
	sleep 5
}

function stopdb() {
	echo "Stopping database"
	$ASPG sh -c "$PGCTL -D $DATADIR stop"
}

function createuser() {
	#$ASPG sh -c "createuser -d -s -r -l docker"
	#$ASPG sh -c "psql postgres" <<EOF
#ALTER USER docker WITH ENCRYPTED PASSWORD 'docker';
#EOF
}

function createdb() {
	# Create the docker user
	$ASPG sh -c "psql -c " <<EOF
CREATE USER docker WITH SUPERUSER PASSWORD 'docker';
EOF

	# Create the database
	$ASPG sh -c "createdb -O docker $DBNAME"

	# Install the Postgis schema
	psql -q -U docker -d $DBNAME -f $PGISCONTRIB/postgis.sql

	# Enable ST_Transform() operations on geometries
	psql -q -U docker -d $DBNAME -f $PGISCONTRIB/spatial_ref_sys.sql

	# Set the correct table ownership
	psql -q -U docker -d $DBNAME <<EOF
ALTER TABLE geometry_columns OWNER TO "docker";
ALTER TABLE spatial_ref_sys OWNER TO "docker";
EOF
}

initdb
startdb

# check if database exists
if ! $ASPG sh -c "psql -d $DBNAME -c '' >/dev/null 2>&1"; then
	createuser
	createdb
fi

if tty --silent; then
	# Drop the user into the shell before exiting
	bash
	stopdb
else
	trap stopdb SIGTERM
	# Wait forever
	tail -f /dev/null
fi
