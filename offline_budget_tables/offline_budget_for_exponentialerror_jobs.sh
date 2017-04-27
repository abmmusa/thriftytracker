#!/bin/bash

#error_bounds="1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000"
error_bounds="1 5 10 25 50 100 200 500 1000 2000"

#delay_bounds="0 8 32"
#delay_bounds="16 64"
#delay_bounds="1 2 4 24 40 48 56 80 96 112 128"
delay_bounds="0 8 16 32 64"

window=900


# uses constant location extrapolator

#echo "python -W ignore produce_offline_budget_exponentialerror_table.py -x 0 -i traces/osm/ -o budget_exponentialerror_table_offline/osm_x0_d0.pkl -w $window"
#echo "python -W ignore produce_offline_budget_exponentialerror_table.py -x 0 -i traces/uic/ -o budget_exponentialerror_table_offline/uic_x0_d0.pkl -w $window"
#echo "python -W ignore produce_offline_budget_exponentialerror_table.py -x 0 -i traces/msmls/ -o budget_exponentialerror_table_offline/msmls_x0_d0.pkl -w $window"
#echo "python -W ignore produce_offline_budget_exponentialerror_table.py -x 0 -i traces/msmls2/ -o budget_exponentialerror_table_offline/msmls2_x0_d0.pkl -w $window"

#categories="msmls_interpolated msmls2_interpolated"
# categories="msmls uic"
# for category in $categories; do
# 	for extrapolator in 0 1; do
# 		for trace in `ls ../traces/${category}`; do
# 			for delay in $delay_bounds; do
# 				id=`echo $trace | sed 's/.txt.gz//'`
# 				window_with_offset=`echo $window $delay | awk '{print int($1+1.5*$2)}'`
# 	   		    # MAX error
# 				echo "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x $extrapolator -i ../traces/${category}/$trace -o tables_individual_trace_maxerror/${category}/x$extrapolator/d$delay/maxerror_${category}_${id}_x0.pkl -w $window_with_offset -d $delay"
# 			done
# 		done
# 	done
# done





#CL and CV extrapolators for osm2
# for extrapolator in 0 1; do
# 	for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do 
# 		for delay in $delay_bounds; do
# 			window_with_offset=`echo $window $delay | awk '{print int($1+1.5*$2)}'`
			
# 			echo "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x $extrapolator -i ../traces/osm2/osm2_subject_${id}.txt.gz -o tables_individual_trace_maxerror/osm2/x$extrapolator/d$delay/maxerror_osm2_${id}_x0.pkl -w $window_with_offset -d $delay"

# 		done
# 	done
# done




# #
# # unified extrapolators
# #
# # MSMLS2
# for delay in $delay_bounds; do
# 	for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
# 		window_with_offset=`echo $window $delay | awk '{print $1+1.5*$2}'`
# 		echo -n "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -i None -o tables_individual_trace_maxerror/msmls2/x3/d$delay/maxerror_msmls2_${id}_x3.pkl -w $window_with_offset -d $delay"
# 		for split in 0 1 2 3 4; do
#       # unified extrapolator no. 2
# 			echo -n ";python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x 3 -i ../split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o tables_individual_trace_maxerror/msmls2/x3/d$delay/maxerror_msmls2_${id}_x3.pkl -w $window_with_offset -d $delay -f ../map_matching/pickle/planet-130507_msmls_bbx.pkl -p ../map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g ../map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c ../unified_extrapolator_data_sources/msmls2/all/for_split_${split}/ -t tables_individual_trace_maxerror/msmls2/x3/d$delay/maxerror_msmls2_${id}_x3.pkl"
# 		done;
# 		echo ""
# 	done
# done


# MSMLS
for delay in $delay_bounds; do
	for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
		window_with_offset=`echo $window $delay | awk '{print int($1+1.5*$2)}'`
		echo -n "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -i None -o tables_individual_trace_maxerror/msmls/x3/d$delay/maxerror_msmls_${id}_x3.pkl -w $window_with_offset -d $delay"
		for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
			echo -n ";python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x 3 -i ../split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o tables_individual_trace_maxerror/msmls/x3/d$delay/maxerror_msmls_${id}_x3.pkl -w $window_with_offset -d $delay -f ../map_matching/pickle/planet-130507_msmls_bbx.pkl -p ../map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g ../map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c ../unified_extrapolator_data_sources/msmls/all/for_split_${split}/ -t tables_individual_trace_maxerror/msmls/x3/d$delay/maxerror_msmls_${id}_x3.pkl"
		done;
		echo ""
	done
done



# UIC
for delay in $delay_bounds; do
	for id in 15 2 13 0; do
		window_with_offset=`echo $window $delay | awk '{print int($1+1.5*$2)}'`
		echo -n "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -i None -o tables_individual_trace_maxerror/uic/x3/d$delay/maxerror_uic_${id}_x3.pkl -w $window_with_offset -d $delay"
		for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
			echo -n ";python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x 3 -i ../split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz -o tables_individual_trace_maxerror/uic/x3/d$delay/maxerror_uic_${id}_x3.pkl -w $window_with_offset -d $delay -f ../map_matching/pickle/planet-130507_uic_bbx.pkl -p ../map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g ../map_matching/osmdb/planet-130507_uic_generic_turn_probs.txt -c ../unified_extrapolator_data_sources/uic/all/for_split_${split}/ -t tables_individual_trace_maxerror/uic/x3/d$delay/maxerror_uic_${id}_x3.pkl"
		done;
		echo ""
	done
done



# # OSM
# for delay in $delay_bounds; do
# 	for id in 14569 39026 48906 69173 69414; do
# 		window_with_offset=`echo $window $delay | awk '{print $1+1.5*$2}'`
# 		echo -n "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -i None -o tables_individual_trace_maxerror/osm/x3/d$delay/maxerror_osm_${id}_x3.pkl -w $window_with_offset -d $delay"
# 		for split in 0 1 2 3 4; do
#         # unified extrapolator no. 2
# 			echo -n ";python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x 3 -i ../split_traces/osm/split_${split}/${id}.txt.gz -o tables_individual_trace_maxerror/osm/x3/d$delay/maxerror_osm_${id}_x3.pkl -w $window_with_offset -d $delay -c ../unified_extrapolator_data_sources/osm/all/for_split_${split}/ -t tables_individual_trace_maxerror/osm/x3/d$delay/maxerror_osm_${id}_x3.pkl"
# 		done;
# 		echo ""
# 	done
# done


# # OSM2
# for delay in $delay_bounds; do
# 	for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do 
# 		window_with_offset=`echo $window $delay | awk '{print int($1+1.5*$2)}'`
		
# 		echo "python -W ignore produce_offline_budget_exponentialerror_table_w_delay_maxerror.py -x 3 -i ../traces/osm2/osm2_subject_${id}.txt.gz -o tables_individual_trace_maxerror/osm2/x3/d$delay/maxerror_osm2_${id}_x3.pkl -w $window_with_offset -d $delay -f ../map_matching/pickle/moscow-140114_300km.pkl -p ../map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c ../unified_extrapolator_data_sources/osm2/all/subjects_8_15/"
		
# 	done
# done
