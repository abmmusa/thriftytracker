#!/bin/bash


#const location extrapolator
for file in "msmls" "osm" "uic" "all"; do
	echo "python produce_offline_time_expected_meanerror_table.py -i expected_error_offline/$file.pkl -o data/expected_meanerror_$file.txt -p expected_meanerror_offline/$file.pkl"
done

#constant velocity extrapolator
for file in "msmls" "osm" "uic"; do
	echo "python produce_offline_time_expected_meanerror_table.py -i expected_error_offline/${file}_const_vel.pkl -o data/expected_meanerror_const_vel_$file.txt -p expected_meanerror_offline/${file}_const_vel.pkl"
done

