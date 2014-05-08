#!/bin/bash

if [ -z "$DB_PORT_5432_TCP_ADDR" ]; then
	echo "Linked container variable DB_PORT_5432_TCP_ADDR missing" 1>&2
	env
	exit 1
fi
PGPASSWORD=docker psql -h $DB_PORT_5432_TCP_ADDR -U docker $PGSQL_DBNAME $@
