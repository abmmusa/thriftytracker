#!/bin/bash

for category in "osm" "uic" "msmls"; do
	
	rm /tmp/trip_durations_$category
	
	trace_dir="traces/$category"
	trace_files=`ls $trace_dir`

	for file in $trace_files; do
		gunzip -c $trace_dir/$file | scripts/trip_durations.sh >> /tmp/trip_durations_$category
	done

	cat /tmp/trip_durations_$category | sort -n | cdf > data/cdf_trip_durations_$category
done