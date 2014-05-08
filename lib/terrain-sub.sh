#!/bin/bash

# ata
#BBOX=10,42,29,51

# baranya@hu
#BBOX=17.5,45.7,18.85,46.4
#BBOX=17.5,46.4,18.85,45.7

src=$1
pfx=$2
BBOX=$3
TMP=/tmp

if [[ "$pfx" == "" || "$src" == "" || "$BBOX" == "" ]]; then
        echo "usage: $0 <src.fix> <prefix> <bbox>"
        exit 1
fi

BASE=$(basename $pfx)
IFS=',' read -ra PROJWIN <<< "$BBOX"

# crop and fix coordinate system
gdal_translate -projwin ${PROJWIN[@]} $src $TMP/$BASE-crop.tif &&
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
