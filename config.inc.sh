#!/bin/bash

WORKDIR=/media/sf_ddrive/mapdata/work
NAME=baranya
BBOX=17.5,45.7,18.85,46.4

# STRM file to clip BBOX from
DEMSRC=$WORKDIR/srtm.tif

# OSM file that includes BBOX
OSMSRC=$WORKDIR/../dl/osm/clip-ata.osm.pbf

