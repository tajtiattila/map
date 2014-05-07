#!/bin/bash

function dockerssh {
	ssh docker@docker docker $@
}

DOCKER=dockerssh
LDIR=/d/mapdata
DDIR=/media/sf_ddrive/mapdata

if [ ! -f $LDIR/work/out.tif ]; then
	#$DOCKER run -v $DDIR/work:/tmp homme/gdal:latest sh -c "'"'ls /tmp/*.tif'"'"
	$DOCKER run -v $DDIR/work:/tmp homme/gdal:latest \
		sh -c "'"'gdal_merge.py -o /tmp/out.tif /tmp/srtm*.tif'"'"
fi

if [ ! -f $LDIR/work/contours.shp ]; then
	$DOCKER run -v $DDIR/work:/tmp homme/gdal:latest \
		gdal_contour -i 5 -snodata 32767 -a height /tmp/out.tif /tmp/out.shp
fi
