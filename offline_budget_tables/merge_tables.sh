#!/bin/bash

# mean error tables
# categories="simulation"
# delay_bounds="0 8 32"

# for category in $categories; do
# 	for delay in $delay_bounds; do
# 		echo "python merge_tables.py -i tables_individual_trace/$category/d$delay/ -o budget_exponentialerror_table_offline/${category}_x0_d${delay}.pkl"
# 	done
# done


# max errror tables
#categories="osm2 uic msmls"
#categories="osm2"
categories="uic msmls"
#delay_bounds="0 8 32"
#delay_bounds="16 64"
#delay_bounds="1 2 4 24 40 48 56 80 96 112 128"
delay_bounds="0 8 16 32 64"

for category in $categories; do
	for extrapolator in 1 3; do
	#for extrapolator in 0 1 3; do
		for delay in $delay_bounds; do
			echo "python merge_tables.py -i tables_individual_trace_maxerror/$category/x$extrapolator/d$delay/ -o budget_exponentialerror_table_offline/maxerror_${category}_x${extrapolator}_d${delay}.pkl"
		done
	done
done
