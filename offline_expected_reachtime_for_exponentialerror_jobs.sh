#!/bin/bash

for file in `ls reachtime_exponentialerror_table_offline/*.pkl`; do
  file_no_prefix=${file##*/}
  echo "python produce_offline_exponentialerror_expected_reachtime_table.py -i reachtime_exponentialerror_table_offline/$file_no_prefix -o data/expected_reachtime_for_exponentialerror_${file_no_prefix%.pkl}.txt -p expected_reachtime_for_exponentialerror_offline/$file_no_prefix"
done

#const location extrapolator
#for file in "msmls" "osm" "uic"; do
#	echo "python produce_offline_exponentialerror_expected_reachtime_table.py -i reachtime_exponentialerror_table_offline/$file.pkl -o data/expected_reachtime_for_exponentialerror_$file.txt -p expected_reachtime_for_exponentialerror_offline/$file.pkl"
#done

#constant velocity extrapolator
#for file in "msmls" "osm" "uic"; do
#	echo -e "python produce_offline_exponentialerror_expected_reachtime_table.py -i reachtime_exponentialerror_table_offline/${file}_const_vel.pkl -o data/expected_reachtime_for_exponentialerror_const_vel_$file.txt -p expected_reachtime_for_exponentialerror_offline/${file}_const_vel.pkl"
#done
