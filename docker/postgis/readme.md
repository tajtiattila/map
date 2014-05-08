
PostGIS Docker
==============

This Dockerfile creates a container that runs PostGIS with:

	user = docker
	password = docker
	dbname = gis
	port = 5432

Furthermore, it provides a script "psql-link" that connects with the
above credentials to the linked container "db".

Usage
=====

Build the image with:

	docker build -t postgis .

Create and start database:

	docker run -d --name pgis postgis

Create and start database with the database with persistence outside the container,
in this case inside $HOME/pgis-data:

	docker run -d --name pgis -v $HOME/pgis-data:/var/lib/postgresql postgis

Load data into database, e.g. with files $SHPDIR/contours.(shp|shx|dbf|prj) generated
by from gdal_contours, using shp2pgsql provided by the image:

	docker run --rm --link pgis:db -v $SHPDIR:/data ataz-postgis \
	  sh -c "shp2pgsql -c -D -s EPSG:3857 /data/contour contours | psql-link -q"

Connect to the database using psql:
	docker run --rm -i --link pgis:db postgis psql-link


