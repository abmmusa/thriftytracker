#!/bin/bash

# ADD -o option to plot image diagram of offline time_error tabls 

#const location extrapolator
for file in "msmls" "osm" "uic" "all"; do
	echo "python produce_offline_time_expected_error_table.py -i time_error_table_offline/$file.pkl -e data/expected_error_$file.txt -p expected_error_offline/$file.pkl"
done

#constant velocity extrapolator
for file in "msmls" "osm" "uic" "all"; do
	echo -e "python produce_offline_time_expected_error_table.py -i time_error_table_offline/${file}_const_vel.pkl -e data/expected_error_const_vel_$file.txt -p expected_error_offline/${file}_const_vel.pkl"
done

