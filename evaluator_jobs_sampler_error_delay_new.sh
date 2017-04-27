#!/bin/bash


#error_bounds="1 2 5 10 20 50 100 500"
#delay_bounds="0 1 8 32 64 128 256"
error_bounds="1 2 5 10 20 50 100 500"
delay_bounds="0 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384"

expected_error_table[0]=""
expected_error_table[1]="_const_vel"


# for category in "uic" "msmls"; do
# 	for extrapolator in 0 1; do
# 		trace_dir="traces/$category"
# 		trace_files=`ls $trace_dir`

# 		for file in $trace_files; do
# 			id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
			
# 			# straw-man with single sample tx
# 			for error_bound in $error_bounds; do
# 				echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 3 -x $extrapolator -e $error_bound -o evaluator_output_${category}_new -i $id" 
# 			done
			

# 			#error-delay
# 			for error_bound in $error_bounds; do
# 				for delay_bound in $delay_bounds; do
# 					echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_${category}_new -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/${category}${expected_error_table[$extrapolator]}.pkl" 
# 				done
# 			done

# 		done
# 	done
# done

#######
#OSM2
#######
for extrapolator in 0; do
	for id in `seq 16 63`; do
		for error_bound in $error_bounds; do
		    # strawman
			echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x $extrapolator -e $error_bound -o evaluator_output_osm2_new -i $id"

			for delay_bound in $delay_bounds; do
				echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/osm2_x${extrapolator}.pkl" 

				#echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt" 
			
			done
		done
	done
done	




###############
# unified
###############

# # msmls
# for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
# 	for split in 0 1 2 3 4; do
# 		for error_bound in $error_bounds; do
# 			# strawman
# 			echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/" 

# 			for delay_bound in $delay_bounds; do
# 				echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/"

# 			done
# 		done
# 	done
# done	


# #msmls2
# for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do
# 	for split in 0 1 2 3 4; do
# 		for error_bound in $error_bounds; do
# 			# strawman
# 			echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_msmls2_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls2/all/for_split_${split}/" 

# 			for delay_bound in $delay_bounds; do
# 				echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_msmls2_new/split_${split}/ -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls2/all/for_split_${split}/"

# 			done
# 		done
# 	done
# done	


# # uic
# for id in 15 2 13 0; do
# 	for split in 0 1 2 3 4; do
# 		for error_bound in $error_bounds; do
# 			# strawman
# 			echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_uic_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_uic_generic_turn_probs.txt -c unified_extrapolator_data_sources/uic/all/for_split_${split}/" 

# 			for delay_bound in $delay_bounds; do
# 				echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_uic_generic_turn_probs.txt -c unified_extrapolator_data_sources/uic/all/for_split_${split}/"

# 			done
# 		done
# 	done
# done	

# #osm
# for id in 14569 39026 48906 69173 69414; do
# 	for split in 0 1 2 3 4; do
# 		for error_bound in $error_bounds; do
# 			# strawman
# 			echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_osm_new/split_${split}/ -i $id -c unified_extrapolator_data_sources/osm/all/for_split_${split}/" 

# 			for delay_bound in $delay_bounds; do
# 				echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x2_e${error_bound}.pkl -c unified_extrapolator_data_sources/osm/all/for_split_${split}/"
# 			done
# 		done
# 	done
# done	



# #OSM2
# for id in `seq 16 63`; do
# 	for error_bound in $error_bounds; do
# 		#strawman
# 		echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x 2 -e $error_bound -o evaluator_output_osm2_new/ -i $id -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/" 

# 		for delay_bound in $delay_bounds; do
# 			echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x 2 -e $error_bound -d $delay_bound -o evaluator_output_osm2_new/ -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/osm2_x2_e${error_bound}.pkl -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

# 		done
# 	done
# done	

