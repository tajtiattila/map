#!/bin/bash

src=$1
pfx=$2
BBOX=$3
TMP=/tmp

if [[ "$pfx" == "" || "$src" == "" || "$BBOX" == "" ]]; then
        echo "usage: $0 <src.fix> <prefix> <bbox>"
        exit 1
fi

BASE=$(basename $pfx)

# gdal_translate needs latitudes in the wrong order for some reason
IFS=',' read -ra BBOXV <<< "$BBOX"
PROJWIN="${BBOXV[0]} ${BBOXV[3]} ${BBOXV[2]} ${BBOXV[1]}"
unset BBOXV

# crop and fix coordinate system
gdal_translate -projwin $PROJWIN $src $TMP/$BASE-crop.tif &&
	gdalwarp -s_srs WGS84 -t_srs EPSG:3857 -r bilinear $TMP/${BASE}-crop.tif $TMP/${BASE}.tif &&
	rm $TMP/${BASE}-crop.tif

# color relief
#gdaldem color-relief $TMP/${pfx}.tif color-scale.txt ${pfx}-color-relief.tif
#gdaldem color-relief $TMP/${pfx}.tif gray-scale.txt ${pfx}-gray-relief.tif

# slopeshade
gdaldem slope -compute_edges $TMP/${BASE}.tif $TMP/${BASE}-slope.tif &&
	gdal_translate -ot Byte -scale 0 90 255 0 $TMP/${BASE}-slope.tif ${pfx}-slopeshade.tif &&
	rm $TMP/${BASE}-slope.tif

# hillshade
gdaldem hillshade -compute_edges -combined -z 2 $TMP/${BASE}.tif ${pfx}-hillshade.tif

# contours
gdal_contour -a elev -snodata 32767 -i 10 $TMP/${BASE}.tif ${pfx}-contour.shp

# cleanup projected file
rm $TMP/${BASE}.tif
