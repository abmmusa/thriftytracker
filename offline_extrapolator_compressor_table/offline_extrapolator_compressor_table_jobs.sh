#!/bin/bash

#delay_bounds="0 8 16 32 64 128"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"

for category in "osm2" "uic" "msmls"; do
	for extr in 0 1 3; do
		for delay in $delay_bounds; do
			echo "python -W ignore produce_offline_extrapolator_compressor_table.py -e ../offline_budget_tables/duration_error_tables/${category}_x${extr}.txt -c ../offline_compressor_stat_tables/data/${category}_d${delay}.txt -o data/${category}_d${delay}_x${extr}.txt"
		done
	done
done
