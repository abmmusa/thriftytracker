#!/bin/bash

#TODO: begenning and end of each trip is neglected
for category in "osm" "uic" "msmls"; do
	#gunzip -c traces/$category/* | awk '{printf "%0.4f %0.4f %d\n", $1,$2,$3}' | \
	#	awk '($1!=lastlat || $2!=lastlon) {print $3-starttime; startlat=$1; startlon=$2; starttime=$3} {lastlat=$1; lastlon=$2; lasttime=$3}' | awk '$1<5000 && $1>0 {print}' \
	#	| sort -n | cdf > data/stationary_durations_$category


	echo -e "gunzip -c traces/$category/* | awk '(\$1!=lastlat || \$2!=lastlon) {print \$3-starttime; startlat=\$1; startlon=\$2; starttime=\$3} {lastlat=\$1; lastlon=\$2; lasttime=\$3}' | awk '\$1<5000 && \$1>0 {print}' | sort -n | cdf > data/stationary_durations_$category"

done