#!/bin/bash

error_bounds="1 2 5 10 20 50 100"
delay_bounds="0 8 64 128"
budget_bounds="0.25 0.5 2 4 8"
#budget_bounds="2 8"
periods="1800.0 3600.0"



#
# budget delay
#
for id in `seq 16 63`; do
	for budget_bound in $budget_bounds; do
		for delay in $delay_bounds; do
			for period in $periods; do
				#only extrapolator table
				#echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 12 -x 3 -b $budget_bound -d $delay -r $period -o evaluator_output_p${period}_osm2_test -i $id -t offline_budget_tables/duration_error_tables/osm2_x3.txt -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"
				
				#extrapolator and compressor table
				echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 13 -x 3 -b $budget_bound -d $delay -r $period -o evaluator_output_p${period}_osm2_test -i $id -t offline_extrapolator_compressor_table/data/osm2_d${delay}_x3.txt -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

			done
		done
	done
done
