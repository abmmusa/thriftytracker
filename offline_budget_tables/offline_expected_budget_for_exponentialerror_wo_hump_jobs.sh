#!/bin/bash

for file in `ls expected_budget_for_exponentialerror_offline/*.pkl`; do
  file_no_prefix=${file##*/}
  echo "python produce_offline_exponentialerror_expected_budget_table_wo_hump.py -i expected_budget_for_exponentialerror_offline/$file_no_prefix -o data/expected_budget_for_exponentialerror_wo_hump_${file_no_prefix%.pkl}.txt -p expected_budget_for_exponentialerror_offline_wo_hump/$file_no_prefix"
done

#const location extrapolator
#for file in "msmls" "osm" "uic"; do
#	echo "python produce_offline_exponentialerror_expected_reachtime_table_wo_hump.py -i expected_reachtime_for_exponentialerror_offline/$file.pkl -o data/expected_reachtime_for_exponentialerror_wo_hump_$file.txt -p expected_reachtime_for_exponentialerror_offline_wo_hump/$file.pkl"
#done

#constant velocity extrapolator
#for file in "msmls" "osm" "uic"; do
#	echo "python produce_offline_exponentialerror_expected_reachtime_table_wo_hump.py -i expected_reachtime_for_exponentialerror_offline/${file}_const_vel.pkl -o data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_$file.txt -p expected_reachtime_for_exponentialerror_offline_wo_hump/${file}_const_vel.pkl"
#done
