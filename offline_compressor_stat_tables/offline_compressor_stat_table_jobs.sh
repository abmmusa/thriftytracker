#!/bin/bash


#delay_bounds="1 2 4 24 40 48 56 80 96 112 128"


error_bounds="0 1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000"
#delay_bounds="0 8 16 32 64 128"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"

#
# osm2
#
# for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
# 	for delay in $delay_bounds; do
# 		for error in $error_bounds; do
			
# 			echo "python -W ignore produce_offline_compressor_stat_table.py -i ../traces/osm2/osm2_subject_${id}.txt.gz -o compressor_data_individual/osm2/d${delay}/stat_e${error}_i${id}.txt -e $error -d $delay"

# 		done
# 	done
# done


#
# msmls
#
for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
	for delay in $delay_bounds; do
		for error in $error_bounds; do
			
			echo "python -W ignore produce_offline_compressor_stat_table.py -i ../traces/msmls/msmls_subject_${id}.txt.gz -o compressor_data_individual/msmls/d${delay}/stat_e${error}_i${id}.txt -e $error -d $delay"

		done
	done
done


#
# uic
#
for id in 15 2 13 0; do
	for delay in $delay_bounds; do
		for error in $error_bounds; do
			
			echo "python -W ignore produce_offline_compressor_stat_table.py -i ../traces/uic/uic_shuttle_${id}.txt.gz -o compressor_data_individual/uic/d${delay}/stat_e${error}_i${id}.txt -e $error -d $delay"

		done
	done
done
