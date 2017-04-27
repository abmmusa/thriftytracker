#!/bin/bash

#error_bounds="1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000"
#error_bounds="1 5 10 25 50 100 200 500 1000 2000"
#error_bounds="2 20"
#error_bounds="75 150 250 300 350 400 450"
error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"

window=1800

# # uses constant location extrapolator
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/osm/ -o reachtime_exponentialerror_table_offline/osm_x0.pkl -w $window"
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/uic/ -o reachtime_exponentialerror_table_offline/uic_x0.pkl -w $window"
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/msmls/ -o reachtime_exponentialerror_table_offline/msmls_x0.pkl -w $window"
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/msmls2/ -o reachtime_exponentialerror_table_offline/msmls2_x0.pkl -w $window"

# # uses constant velocity extrapolator
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/osm/ -o reachtime_exponentialerror_table_offline/osm_x1.pkl -w $window"
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/uic/ -o reachtime_exponentialerror_table_offline/uic_x1.pkl -w $window"
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/msmls/ -o reachtime_exponentialerror_table_offline/msmls_x1.pkl -w $window"
# echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/msmls2/ -o reachtime_exponentialerror_table_offline/msmls2_x1.pkl -w $window"

# # MSMLS2 CL/CV extrapolators
# echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x0.pkl -w $window"
# for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
#   for split in 0 1 2 3 4; do
#     echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 0 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x0.pkl -w $window -t reachtime_exponentialerror_table_offline/msmls2_x0.pkl"
#   done;
# done;
# echo ""

# echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x1.pkl -w $window"
# for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
#   for split in 0 1 2 3 4; do
#     echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 1 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x1.pkl -w $window -t reachtime_exponentialerror_table_offline/msmls2_x1.pkl"
#   done;
# done;
# echo ""


# #osm2 CL/CV extrapolators
# echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm2_x0.pkl -w $window"
# for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do 
#     echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 0 -i ../traces/osm2/osm_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm2_x0.pkl -w $window -t reachtime_exponentialerror_table_offline/osm2_x0.pkl"
# done;
# echo ""

# echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm2_x1.pkl -w $window"
# for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do 
#     echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 1 -i ../traces/osm2/osm_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm2_x1.pkl -w $window -t reachtime_exponentialerror_table_offline/osm2_x1.pkl"
# done;
# echo ""



#
# unified extrapolators
#
# # MSMLS2
# for error_bound in $error_bounds; do
#   echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x2_e${error_bound}.pkl -w $window"
#   for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
#     for split in 0 1 2 3 4; do
#       # unified extrapolator no. 2
#       echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 2 -i ../split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x2_e${error_bound}.pkl -w $window -e $error_bound -f ../map_matching/pickle/planet-130507_msmls_bbx.pkl -p ../map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g ../map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c ../unified_extrapolator_data_sources/msmls2/all/for_split_${split}/ -t reachtime_exponentialerror_table_offline/msmls2_x2_e${error_bound}.pkl"
#     done;
#   done;
#   echo ""
# done

# MSMLS
for error_bound in $error_bounds; do
  echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls_x2_e${error_bound}.pkl -w $window"
  for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do 
    for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
      echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 2 -i ../split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls_x2_e${error_bound}.pkl -w $window -e $error_bound -f ../map_matching/pickle/planet-130507_msmls_bbx.pkl -p ../map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g ../map_matching/osmdb/planet-130507_msmls_generic_turn_probs.txt -c ../unified_extrapolator_data_sources/msmls/all/for_split_${split}/ -t reachtime_exponentialerror_table_offline/msmls_x2_e${error_bound}.pkl"
    done;
  done;
  echo ""
done


# UIC
for error_bound in $error_bounds; do
  echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/uic_x2_e${error_bound}.pkl -w $window"
  for id in 15 2 13 0; do
    for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
      echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 2 -i ../split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz -o reachtime_exponentialerror_table_offline/uic_x2_e${error_bound}.pkl -w $window -e $error_bound -f ../map_matching/pickle/planet-130507_uic_bbx.pkl -p ../map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -g ../map_matching/osmdb/planet-130507_uic_generic_turn_probs.txt -c ../unified_extrapolator_data_sources/uic/all/for_split_${split}/ -t reachtime_exponentialerror_table_offline/uic_x2_e${error_bound}.pkl"
    done;
  done;
  echo ""
done


# # OSM
# for error_bound in $error_bounds; do
#   echo -n "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm_x2_e${error_bound}.pkl -w $window"
#   for id in 14569 39026 48906 69173 69414; do
#     for split in 0 1 2 3 4; do
#       # unified extrapolator no. 2
#       echo -n ";python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 2 -i ../split_traces/osm/split_${split}/${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm_x2_e${error_bound}.pkl -w $window -e $error_bound -c ../unified_extrapolator_data_sources/osm/all/for_split_${split}/ -t reachtime_exponentialerror_table_offline/osm_x2_e${error_bound}.pkl"
#     done;
#   done;
#   echo ""
# done



# OSM2
for error_bound in $error_bounds; do
	echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm2_x2_e${error_bound}.pkl -w $window"
	for id in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do 
		echo "python -W ignore produce_offline_reachtime_exponentialerror_table.py -x 2 -i ../traces/osm2/osm2_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm2_x2_e${error_bound}.pkl -w $window -e $error_bound -f ../map_matching/pickle/moscow-140114_300km.pkl -p ../map_matching/calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt -c ../unified_extrapolator_data_sources/osm2/all/subjects_8_15/ -t reachtime_exponentialerror_table_offline/osm2_x2_e${error_bound}.pkl"
	done
done

