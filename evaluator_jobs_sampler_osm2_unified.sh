#!/bin/bash

error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"
budget_bounds="0.125 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8" #bytes/sec
periods="1800.0 3600.0"

#
# error delay
#
#OSM2
for id in `seq 16 63`; do
      for error_bound in $error_bounds; do
              #strawman
              echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_osm2_new/ -i $id -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/" 

              for delay_bound in $delay_bounds; do
                      echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_osm2_new/ -i $id -t offline_error_tables/error_duration_tables/osm2_x2.txt -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

              done
      done
done  




#
# budget delay
#
for id in `seq 16 63`; do
    #straw-man single sample
	for budget_bound in $budget_bounds; do 

		echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_osm2_new -i $id -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

	done


    #budget-delay bound sampler [statistical]
	for budget_bound in $budget_bounds; do
		for delay in $delay_bounds; do
			for period in $periods; do 

				echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 13 -x 3 -b $budget_bound -d $delay -r $period -o evaluator_output_p${period}_osm2_new -i $id -t offline_extrapolator_compressor_table/data/osm2_d${delay}_x3.txt -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

			done
		done
	done
done






#
# error budget
#

#osm2
for id in `seq 16 63`; do
	for error_bound in $error_bounds; do
		for budget_bound in $budget_bounds; do
			for period in $periods; do
				
				echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 21 -x 2 -e $error_bound -b $budget_bound -r $period -o evaluator_output_p${period}_osm2_new/ -m delays_p${period}_osm2_new/ -i $id -t offline_error_tables/error_duration_tables/osm2_x2.txt -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/ -u data_new/error_delay_table_error${error_bound}_osm2_extr2"
			done
		done
	done
done

