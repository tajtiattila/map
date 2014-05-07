#!/usr/bin/env python

from __future__ import division

LON=(11,29)
LAT=(42,51)

FMT1='srtm_{x:02d}_{y:02d}.zip'
FMTX='srtm_{xr}_{yr}.zip'
#ROOT='ftp://xftp.jrc.it/pub/srtmV4/tiff'
ROOT='http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff'

DLDIR='D:/mapdata/dl/srtm90m'
WDIR='D:/mapdata/work'

minlon, maxlon = LON
minlat, maxlat = LAT

def lb(x):
    return x//5
def ub(x):
    d, r = x//5, x%5
    return d if r != 0 else d-1

minx = lb(minlon+180)+1
maxx = ub(maxlon+180)+1

miny = lb(60-maxlat)+1
maxy = ub(60-minlat)+1

print '#!/bin/sh'
print '#', minx, maxx, miny, maxy
print 'mkdir -p ' + DLDIR
print 'cd ' + DLDIR
print 'curl -C - -L -O ' + ROOT + '/' + \
        FMTX.format(xr='[{:02d}-{:02d}]'.format(minx,maxx), yr='[{:02d}-{:02d}]'.format(miny,maxy))
print 'mkdir -p ' + WDIR
print 'cd ' + WDIR
print 'ls -p ' DLDIR + '/*.zip | xargs -n 1 unzip'


#for x in range(minx, maxx+1):
    #for y in range(miny, maxy+1):
        #print ROOT + '/' + (FMT1.format(x=x, y=y))
