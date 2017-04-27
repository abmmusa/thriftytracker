#!/bin/bash


#error_bounds="1 5 10 25 50 100 200 500"
#budget_bounds="0.1 0.25 0.5 0.75 1 2 3.5 5 8" #bytes/sec

#error_bounds="1 2 5 10 25 50 100 200 400"
#budget_bounds="0.1 0.25 0.5 1 2 4 8" #bytes/sec

#error_bounds="1 5 10 25 50 100 200 500"
error_bounds="1 2 5 10 20 50 100 500"
budget_bounds="0.125 0.25 0.5 1 2 4 8" #bytes/sec


periods="600.0 1800.0 3600.0 14400.0 57600.0 230400.0"
#periods="3600.0 57600.0"


###############
# osm2
###############
for extrapolator in 0; do
	for id in 16; do
		for error_bound in $error_bounds; do
			for budget_bound in $budget_bounds; do
				for period in $periods; do
					
					#echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 20 -x $extrapolator -e $error_bound -b $budget_bound -r $period -o period_effect/evaluator_output_p${period}_osm2_new -m period_effect/delays_p${period}_osm2_new -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/osm2_x${extrapolator}.pkl" 

					echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 21 -x $extrapolator -e $error_bound -b $budget_bound -r $period -o period_effect/evaluator_output_p${period}_osm2_new -m period_effect/delays_p${period}_osm2_new -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/osm2_x${extrapolator}.pkl -u data_new/error_delay_table_error${error_bound}_osm2_extr${extrapolator}" 
				done
			done
		done
	done
done	

