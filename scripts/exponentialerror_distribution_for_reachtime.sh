#!/bin/bash

#const location extr
for time in 1 2 5 10 30 60 120 180 300 600 900 1200 1500 1700; do
	for category in "osm" "uic" "msmls"; do
		cat data/reachtime_exponentialerror_$category.txt | awk '$1==t && $3!=0 {print $2, $3}' t=$time > data/exponentialerror_${category}_${time}
	done
done


#const velocity extr
for time in 1 2 5 10 30 60 120 180 300 600 900 1200 1500 1700; do
	for category in "osm" "uic" "msmls"; do
		cat data/reachtime_exponentialerror_const_vel_$category.txt | awk '$1==t && $3!=0 {print $2, $3}' t=$time > data/exponentialerror_const_vel_${category}_${time}
	done
done


