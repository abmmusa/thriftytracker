#!/bin/bash

#order mean_error, delay, mean_usage

error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"
#delay_bounds="0 8 16 32 64"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"
budget_bounds="0.125 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8" #bytes/sec
periods="1800.0 3600.0"


rm data_new/error_delay_3d 
for period in $periods; do
	rm data_new/budget_delay_p${period}_3d data_new/error_budget_p${period}_3d
done

for delay in $delay_bounds; do
	cat data_new/3d_error_delay_delay${delay}_osm2_extr0 | awk '{print $3,$2,$4}' >> data_new/error_delay_3d
	echo >> data_new/error_delay_3d
done

for delay in $delay_bounds; do
	for period in $periods; do
		cat data_new/3d_budget_delay_statistical_maxerror_delay${delay}_p${period}_osm2_extr0 | awk '{print $3, $2, $4}' >> data_new/budget_delay_p${period}_3d
		echo >> data_new/budget_delay_p${period}_3d
	done
done

for budget in $budget_bounds; do
	for period in $periods; do
		cat data_new/3d_error_budget3_meanerror_budget${budget}_p${period}_osm2_extr0 | awk '{print $2, $5, $4}' >> data_new/error_budget_p${period}_3d
		echo >> data_new/error_budget_p${period}_3d
	done
done