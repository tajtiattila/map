#!/bin/bash

ASPG="su postgres"
DATADIR="/var/lib/postgresql/9.3/main"
CONF="/etc/postgresql/9.3/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/9.3/bin/postgres"
INITDB="/usr/lib/postgresql/9.3/bin/initdb"
PGISCONTRIB="/usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql"

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
		$ASPG sh -c "$INITDB $DATADIR"
		$ASPG sh -c "$POSTGRES --single -D $DATADIR -c config_file=$CONF" <<< "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';"
	fi
}

function startdb() {
	trap "echo \"Sending SIGTERM to postgres\"; killall -s SIGTERM postgres" SIGTERM

	$ASPG sh -c "$POSTGRES -D $DATADIR -c config_file=$CONF" &
}

function createdb() {
	dbname=gis

	# check if database exists
	$ASPG -c 'psql -d '$dbname' -c '"''"' >/dev/null 2>&1' && return

	# Create the database
	$ASPG postgres createdb -O docker $dbname

	# Install the Postgis schema
	$ASPG psql -d $dbname -f $PGISCONTRIB/postgis.sql

	# Set the correct table ownership
	$ASPG psql -d $dbname -c 'ALTER TABLE geometry_columns OWNER TO "docker"; ALTER TABLE spatial_ref_sys OWNER TO "docker";'
}

initdb
startdb
createdb

if ! tty --silent; then
	wait $!
else
	bash
	killall -s SIGTERM postgres
fi
