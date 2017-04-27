#!/bin/bash

#error_bounds="1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000"
error_bounds="1 5 10 25 50 100 200 500 1000 2000"
window=1800

# uses constant location extrapolator
echo "python produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/osm/ -o reachtime_exponentialerror_table_offline/osm_x0.pkl -w $window"
echo "python produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/uic/ -o reachtime_exponentialerror_table_offline/uic_x0.pkl -w $window"
echo "python produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/msmls/ -o reachtime_exponentialerror_table_offline/msmls_x0.pkl -w $window"
echo "python produce_offline_reachtime_exponentialerror_table.py -x 0 -i traces/msmls2/ -o reachtime_exponentialerror_table_offline/msmls2_x0.pkl -w $window"

# uses constant velocity extrapolator
echo "python produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/osm/ -o reachtime_exponentialerror_table_offline/osm_x1.pkl -w $window"
echo "python produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/uic/ -o reachtime_exponentialerror_table_offline/uic_x1.pkl -w $window"
echo "python produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/msmls/ -o reachtime_exponentialerror_table_offline/msmls_x1.pkl -w $window"
echo "python produce_offline_reachtime_exponentialerror_table.py -x 1 -i traces/msmls2/ -o reachtime_exponentialerror_table_offline/msmls2_x1.pkl -w $window"

# MSMLS2 CL/CV extrapolators
echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x0.pkl -w $window"
for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
  for split in 0 1 2 3 4; do
    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 0 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x0.pkl -w $window -t reachtime_exponentialerror_table_offline/msmls2_x0.pkl"
  done;
done;
echo ""

echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x1.pkl -w $window"
for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
  for split in 0 1 2 3 4; do
    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 1 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x1.pkl -w $window -t reachtime_exponentialerror_table_offline/msmls2_x1.pkl"
  done;
done;
echo ""

# unified extrapolators
#
# MSMLS2
for error_bound in $error_bounds; do
  echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x2_e${error_bound}.pkl -w $window"
  for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
    for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
      echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 2 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x2_e${error_bound}.pkl -w $window -e $error_bound -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls2/for_split_${split}/all/ -t reachtime_exponentialerror_table_offline/msmls2_x2_e${error_bound}.pkl"
    done;
  done;
  echo ""
done

echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls2_x3.pkl -w $window"
for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do # 3 6 7 8; do
  for split in 0 1 2 3 4; do
    # unified extrapolator no. 3
    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 3 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls2_x3.pkl -w $window -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls2/for_split_${split}/all/ -t reachtime_exponentialerror_table_offline/msmls2_x3.pkl"
  done;
done;
echo ""

  #echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls_x4_e${error_bound}.pkl -w $window"
  #for id in 0 1 2 4 5 9 10 11 12 13 14 15 16 3 6 7 8; do
  #  for split in 0 1 2 3 4; do
  #    # unified extrapolator no. 4
  #    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 4 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls_x4_e${error_bound}.pkl -w $window -e $error_bound -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/median/ -t reachtime_exponentialerror_table_offline/msmls_x4_e${error_bound}.pkl"
  #  done;
  #done;
  #echo ""
  #
  #echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/msmls_x5_e${error_bound}.pkl -w $window"
  #for id in 0 1 2 4 5 9 10 11 12 13 14 15 16 3 6 7 8; do
  #  for split in 0 1 2 3 4; do
  #    # unified extrapolator no. 5
  #    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 5 -i split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz -o reachtime_exponentialerror_table_offline/msmls_x5_e${error_bound}.pkl -w $window -e $error_bound -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/mean/ -t reachtime_exponentialerror_table_offline/msmls_x5_e${error_bound}.pkl"
  #  done;
  #done;
  #echo ""

# UIC
for error_bound in $error_bounds; do
  echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/uic_x2_e${error_bound}.pkl -w $window"
  for id in 15 2 13 0; do
    for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
      echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 2 -i split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz -o reachtime_exponentialerror_table_offline/uic_x2_e${error_bound}.pkl -w $window -e $error_bound -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/ -t reachtime_exponentialerror_table_offline/uic_x2_e${error_bound}.pkl"
    done;
  done;
  echo ""
done

echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/uic_x3.pkl -w $window"
for id in 15 2 13 0; do
  for split in 0 1 2 3 4; do
    # unified extrapolator no. 3
    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 3 -i split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz -o reachtime_exponentialerror_table_offline/uic_x3.pkl -w $window -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/ -t reachtime_exponentialerror_table_offline/uic_x3.pkl"
  done;
done;
echo ""

  #echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/uic_x4_e${error_bound}.pkl -w $window"
  #for id in 15 2 13 0; do
  #  for split in 0 1 2 3 4; do
  #    # unified extrapolator no. 4
  #    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 4 -i split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz -o reachtime_exponentialerror_table_offline/uic_x4_e${error_bound}.pkl -w $window -e $error_bound -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/median/ -t reachtime_exponentialerror_table_offline/uic_x4_e${error_bound}.pkl"
  #  done;
  #done;
  #echo ""
  #
  #echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/uic_x5_e${error_bound}.pkl -w $window"
  #for id in 15 2 13 0; do
  #  for split in 0 1 2 3 4; do
  #    # unified extrapolator no. 5
  #    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 5 -i split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz -o reachtime_exponentialerror_table_offline/uic_x5_e${error_bound}.pkl -w $window -e $error_bound -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/mean/ -t reachtime_exponentialerror_table_offline/uic_x5_e${error_bound}.pkl"
  #  done;
  #done;
  #echo ""

# OSM
for error_bound in $error_bounds; do
  echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm_x2_e${error_bound}.pkl -w $window"
  for id in 14569 39026 48906 69173 69414; do
    for split in 0 1 2 3 4; do
      # unified extrapolator no. 2
      echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 2 -i split_traces/osm/split_${split}/${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm_x2_e${error_bound}.pkl -w $window -e $error_bound -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/ -t reachtime_exponentialerror_table_offline/osm_x2_e${error_bound}.pkl"
    done;
  done;
  echo ""
done

echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm_x3.pkl -w $window"
for id in 14569 39026 48906 69173 69414; do
  for split in 0 1 2 3 4; do
    # unified extrapolator no. 3
    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 3 -i split_traces/osm/split_${split}/${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm_x3.pkl -w $window -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/ -t reachtime_exponentialerror_table_offline/osm_x3.pkl"
  done;
done;
echo ""

  #echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm_x4_e${error_bound}.pkl -w $window"
  #for id in 14569 39026 48906 69173 69414; do
  #  for split in 0 1 2 3 4; do
  #    # unified extrapolator no. 4
  #    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 4 -i split_traces/osm/split_${split}/${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm_x4_e${error_bound}.pkl -w $window -e $error_bound -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/median/ -t reachtime_exponentialerror_table_offline/osm_x4_e${error_bound}.pkl"
  #  done;
  #done;
  #echo ""
  #
  #echo -n "python produce_offline_reachtime_exponentialerror_table.py -i None -o reachtime_exponentialerror_table_offline/osm_x5_e${error_bound}.pkl -w $window"
  #for id in 14569 39026 48906 69173 69414; do
  #  for split in 0 1 2 3 4; do
  #    # unified extrapolator no. 5
  #    echo -n ";python produce_offline_reachtime_exponentialerror_table.py -x 5 -i split_traces/osm/split_${split}/${id}.txt.gz -o reachtime_exponentialerror_table_offline/osm_x5_e${error_bound}.pkl -w $window -e $error_bound -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/mean/ -t reachtime_exponentialerror_table_offline/osm_x5_e${error_bound}.pkl"
  #  done;
  #done;
  #echo ""
