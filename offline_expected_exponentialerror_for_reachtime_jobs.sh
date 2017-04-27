#!/bin/bash


#const location extrapolator
for file in "msmls" "osm" "uic"; do
	echo "python produce_offline_reachtime_expected_exponentialerror_table.py -i reachtime_exponentialerror_table_offline/$file.pkl -o data/reachtime_exponentialerror_$file.txt -e data/expected_exponentialerror_for_reachtime_$file.txt -p expected_exponentialerror_for_reachtime_offline/$file.pkl"
done

#constant velocity extrapolator
for file in "msmls" "osm" "uic"; do
	echo -e "python produce_offline_reachtime_expected_exponentialerror_table.py -i reachtime_exponentialerror_table_offline/${file}_const_vel.pkl -o data/reachtime_exponentialerror_const_vel_$file.txt -e data/expected_exponentialerror_for_reachtime_const_vel_$file.txt -p expected_exponentialerror_for_reachtime_offline/${file}_const_vel.pkl"
done

