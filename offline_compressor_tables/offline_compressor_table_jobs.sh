#!/bin/bash


#delay_bounds="1 2 4 24 40 48 56 80 96 112 128"
#delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"

delay_bounds="0 8 16 32 64 128"


for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
	for delay in $delay_bounds; do
		echo "python -W ignore produce_offline_compressor_table.py -i ../traces/osm2/osm2_subject_${id}.txt.gz -o compressor_data_individual/osm2_d${delay}_$id.txt -d $delay"
	done
done