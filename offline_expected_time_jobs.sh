#!/bin/bash

# ADD -o option to plot image diagram of offline time_error tabls 

#const location extrapolator
for file in "msmls" "osm" "uic"; do
	echo "python produce_offline_error_expected_time_table.py -i time_error_table_offline/$file.pkl -o data/expected_time_$file.txt -p expected_time_offline/$file.pkl"
done

#constant velocity extrapolator
for file in "msmls" "osm" "uic"; do
	echo -e "python produce_offline_error_expected_time_table.py -i time_error_table_offline/${file}_const_vel.pkl -o data/expected_time_const_vel_$file.txt -p expected_time_offline/${file}_const_vel.pkl"
done

