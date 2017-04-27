#!/bin/bash


for delay in 1 4 5 9 10 15 16 20 40 120; do

    # const location extrapolator
	for category in "osm" "uic"; do
		bytes=`echo $delay | ./scripts/get_bytes.sh`
		echo "cat data/expected_meanerror_$category.txt | awk '{print \$1, b/(\$1+d), \$2}' d=$delay b=$bytes > data/expected_meanerror_bytes_sec_d${delay}_$category.txt"
	done

    # constant velocity extrapolator
	for category in "osm" "uic"; do
		bytes=`echo $delay | ./scripts/get_bytes.sh`
		echo "cat data/expected_meanerror_const_vel_$category.txt | awk '{print \$1, b/(\$1+d), \$2}' d=$delay b=$bytes > data/expected_meanerror_bytes_sec_const_vel_d${delay}_${category}.txt"

	done

done