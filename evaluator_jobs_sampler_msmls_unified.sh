#!/bin/bash

error_bounds="1 2 5 10 20 50 100 200 500"
delay_bounds="0 8 16 32 64 128"
budget_bounds="0.25 0.5 1 2 4 8" #bytes/sec
periods="1800.0 3600.0"

#
# error delay
#
for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
	for split in 0 1 2 3 4; do
		for error_bound in $error_bounds; do
            # strawman
			echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/" 

			for delay_bound in $delay_bounds; do
				echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t offline_error_tables/error_duration_tables/msmls_x2.txt -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/"

			done
		done
	done
done




#
# budget delay
#
for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
	for split in 0 1 2 3 4; do
		for budget_bound in $budget_bounds; do
			#strawman
			echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/" 

			for delay_bound in $delay_bounds; do
				for period in $periods; do
					echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 13 -x 3 -b $budget_bound -d $delay_bound -r $period -o evaluator_output_p${period}_msmls_new/split_${split}/ -i $id -t offline_extrapolator_compressor_table/data/msmls_d${delay_bound}_x3.txt -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/"

				done
			done
		done
	done
done



#
# error budget
#

for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
	for split in 0 1 2 3 4; do
		for error_bound in $error_bounds; do
			for budget_bound in $budget_bounds; do
				for period in $periods; do

					echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 21 -x 2 -e $error_bound -b $budget_bound -r $period -o evaluator_output_p${period}_msmls_new/split_${split} -m delays_p${period}_msmls_new/split_${split}/ -i $id -t offline_error_tables/error_duration_tables/msmls_x2.txt -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/ -u data_new/error_delay_table_error${error_bound}_msmls_extr2"
				done
			done
		done
	done
done
