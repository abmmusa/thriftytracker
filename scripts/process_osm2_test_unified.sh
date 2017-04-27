#!/bin/bash

# ########################
# # budget delay sampler
# ########################

delay_bounds="0 8 16 32 64 128"
periods="1800.0 3600.0"

echo "processing budget-dealy..."

for category in "osm2"; do
	for extrapolator in 3; do
		for delay in $delay_bounds; do
			for period in $periods; do
				for id in 12 13; do

			        # mean error
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s${id}_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay | awk '$1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_osm2_test/"budget_delay_statistical_maxerror"${id}"_delay"$delay"_p"${period}"_"$category"_extr"$extrapolator

			        # max error
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s${id}_x$extrapolator.txt | awk '{print $4, $5, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay | awk '$1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_osm2_test/"budget_delay_statistical_maxerror_maxerror"${id}"_delay"$delay"_p"${period}"_"$category"_extr"$extrapolator
			
				done
			done
		done
	done
done

