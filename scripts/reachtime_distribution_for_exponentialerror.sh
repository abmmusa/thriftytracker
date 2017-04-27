#!/bin/bash

#const location extr
for bucket in 1 2 5 7 10 12 15 18 20 22 24 25 27 28 30 31 32 33 34; do
	for category in "osm" "uic" "msmls"; do
		cat data/reachtime_exponentialerror_$category.txt | awk '$2==b && $3!=0 {print $1, $3}' b=$bucket > data/reachtime_${category}_${bucket}
	done
done


#const velocity extr
for bucket in 1 2 5 7 10 12 15 18 20 22 24 25 27 28 30 31 32 33 34; do
	for category in "osm" "uic" "msmls"; do
		cat data/reachtime_exponentialerror_const_vel_$category.txt | awk '$2==b && $3!=0 {print $1, $3}' b=$bucket > data/reachtime_const_vel_${category}_${bucket}
	done
done


