#!/bin/bash


#budget_bounds="1 2 5 8 10 15 30" #bytes/sec
#budget_bounds="0.1 0.25 0.5 0.75 1 2 5 8 10 15" #bytes/sec

#budget_bounds="0.1640625 0.328125 0.65625 1.3125 2.625 5.25 10.5" #bytes/sec
#budget_bounds="0.1 0.25 0.5 0.75 1 2 3.5 5 8" #bytes/sec
budget_bounds="0.125 4" #bytes/sec
#delay_bounds="0 8 16 32 64"
delay_bounds="16 64"



expected_error_table[0]=""


# extrapolator 0 and 1
#for category in "msmls" "msmls2" "uic" "osm"; do
for category in "msmls" "uic"; do
	for extrapolator in 0 1; do

		trace_dir="traces/$category"
		trace_files=`ls $trace_dir`
		
		for file in $trace_files; do
			id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
	
            #straw-man single sample
			for budget_bound in $budget_bounds; do 
				echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 4 -x $extrapolator -b $budget_bound -o evaluator_output_${category}_new -i $id" 
			done


            #budget-delay bound sampler [statistical]
			for budget_bound in $budget_bounds; do
 				for delay_bound in $delay_bounds; do
					# MAX error
					echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 11 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_${category}_new -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_${category}_x${extrapolator}_d${delay_bound}.pkl" 

				done
			done

		done

	done
done



# #
# #special case of msmls interpolated
# #
# category="msmls_interpolated"
# trace_dir="traces/$category"
# trace_files=`ls $trace_dir`
# extrapolator="0"
		
# for file in $trace_files; do
# 	id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
	
#     #straw-man single sample
# 	for budget_bound in $budget_bounds; do 
# 		echo "gunzip -c traces/msmls_interpolated_estimated/$file | python -W ignore evaluator_new.py -s 4 -x $extrapolator -b $budget_bound -o evaluator_output_${category}_new -i $id" 
# 	done


#     #budget-delay bound sampler [statistical]
# 	for budget_bound in $budget_bounds; do
#  		for delay_bound in $delay_bounds; do
# 			# MAX error
# 			echo "gunzip -c traces/msmls_interpolated_estimated/$file | python -W ignore evaluator_new.py -s 11 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_${category}_new -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_${category}_x${extrapolator}_d${delay_bound}.pkl" 
			
# 		done
# 	done	
# done


############
# osm2
###########

for category in "osm2"; do
	for extrapolator in 0 1; do
		for id in `seq 16 63`; do
	
            #straw-man single sample
			for budget_bound in $budget_bounds; do 
				echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz  | python -W ignore evaluator_new.py -s 4 -x $extrapolator -b $budget_bound -o evaluator_output_${category}_new -i $id" 
			done


            #budget-delay bound sampler [statistical]
			for budget_bound in $budget_bounds; do
 				for delay_bound in $delay_bounds; do
					# MAX error
					#echo $id $budget_bound $delay_bound
					echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_${category}_new -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_${category}_x${extrapolator}_d${delay_bound}.pkl"

				done
			done

		done
	done
done




#
#Unified
#

# msmls
#budget-delay bound sampler [statistical]
for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
	for split in 0 1 2 3 4; do
		for budget_bound in $budget_bounds; do
			#strawman
			echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/" 

 			for delay_bound in $delay_bounds; do
				echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_msmls_x3_d${delay_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls/all/for_split_${split}/"
			done
		done
	done
done	


# # msmls2
# for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do
# 	for split in 0 1 2 3 4; do
# 		for budget_bound in $budget_bounds; do
# 			#strawman
# 			echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_msmls2_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls2/all/for_split_${split}/" 

#  			for delay_bound in $delay_bounds; do
# 				echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_msmls2_new/split_${split}/ -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_msmls2_x3_d${delay_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c unified_extrapolator_data_sources/msmls2/all/for_split_${split}/"

# 			done
# 		done
# 	done
# done	


# uic
for id in 15 2 13 0; do
	for split in 0 1 2 3 4; do
		for budget_bound in $budget_bounds; do
			#strawman
			echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_uic_new/split_${split}/ -i $id -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_uic_generic_turn_probs.txt -c unified_extrapolator_data_sources/uic/all/for_split_${split}/" 

 			for delay_bound in $delay_bounds; do
				echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_uic_x3_d${delay_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g map_matching/osmdb/planet-130507_uic_generic_turn_probs.txt -c unified_extrapolator_data_sources/uic/all/for_split_${split}/"
			done
		done
	done
done	

# #osm
# for id in 14569 39026 48906 69173 69414; do
# 	for split in 0 1 2 3 4; do
# 		for budget_bound in $budget_bounds; do
# 			#strawman
# 			echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_osm_new/split_${split}/ -i $id -c unified_extrapolator_data_sources/osm/all/for_split_${split}/" 

#  			for delay_bound in $delay_bounds; do
# 				echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_osm_x3_d${delay_bound}.pkl -c unified_extrapolator_data_sources/osm/all/for_split_${split}/"
# 			done
# 		done
# 	done
# done	



#OSM2

for id in `seq 16 63`; do
    #straw-man single sample
	for budget_bound in $budget_bounds; do 
		echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 3 -b $budget_bound -o evaluator_output_osm2_new -i $id -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

	done


    #budget-delay bound sampler [statistical]
	for budget_bound in $budget_bounds; do
 		for delay_bound in $delay_bounds; do
			# MAX error
			#echo $id $budget_bound $delay_bound
			echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_osm2_x3_d${delay_bound}.pkl -f map_matching/pickle/moscow-140114_300km.pkl -p map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c unified_extrapolator_data_sources/osm2/all/subjects_8_15/"

		done
	done
done
