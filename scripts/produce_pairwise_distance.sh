#!/bin/bash

for category in "osm" "uic" "msmls"; do
	rm data/pairwise_time_distance_$category.txt

	gunzip -c traces/$category/* | python ./scripts/test_trace_pairwise_distance.py >> data/pairwise_time_distance_$category.txt

done


#produce the cdfs
for category in "osm" "uic" "msmls"; do
	cat data/pairwise_time_distance_$category.txt | awk '{print $3}' | sort -n | cdf > data/cdf_pairwise_time_distance_$category.txt
done
