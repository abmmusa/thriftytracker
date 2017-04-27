#!/bin/bash

# for file in `ls budget_exponentialerror_table_offline/*.pkl`; do
#   file_no_prefix=${file##*/}
#   echo "python produce_offline_budget_expected_exponentialerror_table.py -i budget_exponentialerror_table_offline/$file_no_prefix -o ../data/expected_exponentialerror_for_budget_${file_no_prefix%.pkl}.txt -p expected_exponentialerror_for_budget_offline/$file_no_prefix"
# done


# ## MEAN error tables
# #categories="osm uic msmls msmls2"
# categories="simulation"
# extrapolators="0"
# delays="0 8 32"


# for category in $categories; do
# 	for extrapolator in $extrapolators; do
# 		for delay in $delays; do
# 			echo "python produce_offline_budget_expected_exponentialerror_table.py -i budget_exponentialerror_table_offline/${category}_x${extrapolator}_d${delay}.pkl -o ../data/expected_exponentialerror_for_budget_${category}_x${extrapolator}_d${delay}.txt -b ../data/expected_exponentialerror_for_budget_bytessec_${category}_x${extrapolator}_d${delay}.txt -p expected_exponentialerror_for_budget_offline/${category}_x${extrapolator}_d${delay}.pkl -q expected_exponentialerror_for_budget_offline/bytessec_${category}_x${extrapolator}_d${delay}.pkl -d $delay"
# 		done
# 	done
# done   



## MAX error tables

#categories="osm2 uic msmls"
#categories="osm2"
categories="uic msmls"
#extrapolators="0 1 3"
extrapolators="3"
#delays="0 8 32"
#delays="16 64"
#delays="1 2 4 24 40 48 56 80 96 112 128"
delay_bounds="0 8 16 32 64"

for category in $categories; do
	for extrapolator in $extrapolators; do
		for delay in $delay_bounds; do
			echo "python produce_offline_budget_expected_exponentialerror_table.py -i budget_exponentialerror_table_offline/maxerror_${category}_x${extrapolator}_d${delay}.pkl -o ../data/expected_exponentialerror_for_budget_maxerror_${category}_x${extrapolator}_d${delay}.txt -b ../data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d${delay}.txt -p expected_exponentialerror_for_budget_offline/maxerror_${category}_x${extrapolator}_d${delay}.pkl -q expected_exponentialerror_for_budget_offline/bytessec_maxerror_${category}_x${extrapolator}_d${delay}.pkl -d $delay"
		done
	done
done   

