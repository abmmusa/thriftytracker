#!/bin/bash


#const location extrapolator
for file in "msmls" "osm" "uic"; do
	echo "python produce_offline_time_expected_error_table.py -i time_error_table_offline/$file.pkl -o data/time_error_$file.txt"
done

#constant velocity extrapolator
for file in "msmls" "osm" "uic"; do
	echo -e "python produce_offline_time_expected_error_table.py -i time_error_table_offline/${file}_const_vel.pkl -o data/time_error_const_vel_$file.txt"
done

