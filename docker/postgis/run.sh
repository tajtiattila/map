#!/bin/bash

ASPG="su postgres"
DATADIR="/var/lib/postgresql/$PGSQL_VER/$PGSQL_CFG"
CONFIGFILE="/etc/postgresql/$PGSQL_VER/$PGSQL_CFG/postgresql.conf"
POSTGRES="/usr/lib/postgresql/$PGSQL_VER/bin/postgres"
INITDB="/usr/lib/postgresql/$PGSQL_VER/bin/initdb"
PGISCONTRIB="/usr/share/postgresql/$PGSQL_VER/contrib/postgis-$PGIS_VER"

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
	$ASPG sh -c "createdb -O docker $PGSQL_DBNAME"

	# Install the Postgis schema
	$ASPG sh -c "psql -q -d $PGSQL_DBNAME -f $PGISCONTRIB/postgis.sql"

	# Enable ST_Transform() operations on geometries
	$ASPG sh -c "psql -q -d $PGSQL_DBNAME -f $PGISCONTRIB/spatial_ref_sys.sql"

	# Set the correct table ownership
	$ASPG sh -c "psql -q -d $PGSQL_DBNAME" <<EOF
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

function help() {
	cat <<EOF
Available arguments for this "run" script:
init      initialiase database in /var/lib/postgresql
          (database: gis, superuser/password: docker/docker)
serve     serve database in /var/lib/postgresql on port 5432
EOF
}

for arg; do
	$arg
done
