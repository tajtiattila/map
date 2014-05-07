#!/bin/bash

DBNAME=gis

PGVER=9.3
CONFIG=main

ASPG="su postgres"
DATADIR="/var/lib/postgresql/$PGVER/$CONFIG"
CONFIGFILE="/etc/postgresql/$PGVER/$CONFIG/postgresql.conf"
POSTGRES="/usr/lib/postgresql/$PGVER/bin/postgres"
INITDB="/usr/lib/postgresql/$PGVER/bin/initdb"
PGISCONTRIB="/usr/share/postgresql/$PGVER/contrib/postgis-2.1"

function init() {
	# test if DATADIR is existent
	if [ ! -d $DATADIR ]; then
		echo "Creating Postgres data at $DATADIR"
		mkdir -p $DATADIR
	fi

	# test if DATADIR has content
	[ "$(ls -A $DATADIR)" ] && return

	echo "Initializing Postgres Database at $DATADIR"
	chown -R postgres $DATADIR
	$ASPG sh -c "$INITDB $DATADIR"

	# Start up Postgres for initialization
	$ASPG sh -c "$POSTGRES -D $DATADIR -c config_file=$CONFIGFILE" &
	PID=$!

	# Create the docker user
	$ASPG sh -c "psql" <<EOF
CREATE USER docker WITH SUPERUSER PASSWORD 'docker';
EOF

	# Create the database
	$ASPG sh -c "createdb -O docker $DBNAME"

	# Install the Postgis schema
	$ASPG sh -c "psql -q -d $DBNAME -f $PGISCONTRIB/postgis.sql"

	# Enable ST_Transform() operations on geometries
	$ASPG sh -c "psql -q -d $DBNAME -f $PGISCONTRIB/spatial_ref_sys.sql"

	# Set the correct table ownership
	$ASPG sh -c "psql -q -d $DBNAME" <<EOF
ALTER TABLE geometry_columns OWNER TO "docker";
ALTER TABLE spatial_ref_sys OWNER TO "docker";
EOF

	_shutdown
}

function _shutdown() {
	[ "$PID" == "" ] && return

	# Shut down server
	kill -SIGTERM $PID
	wait $PID
	unset PID
}

function serve() {
	trap _shutdown SIGTERM
	$ASPG sh -c "$POSTGRES -D $DATADIR -c config_file=$CONFIGFILE" &
	PID=$!
	wait
}

for arg; do
	$arg
done
