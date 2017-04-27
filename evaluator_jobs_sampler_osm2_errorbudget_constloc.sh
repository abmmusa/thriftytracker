#!/bin/bash

error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"
budget_bounds="0.125 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8" #bytes/sec
periods="1800.0 3600.0"


#
#error budget
#
for extrapolator in 0; do
    for id in `seq 16 63`; do
        for error_bound in $error_bounds; do
            for budget_bound in $budget_bounds; do
                for period in $periods; do
					
                    #echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 21 -x $extrapolator -e $error_bound -b $budget_bound -r $period -o evaluator_output_p${period}_osm2_new -m delays_p${period}_osm2_new -i $id -t offline_error_tables/expected_reachtime_for_exponentialerror_offline_wo_hump/osm2_x${extrapolator}.pkl -u data_new/error_delay_error${error_bound}_osm2_extr${extrapolator}" 

					echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 21 -x $extrapolator -e $error_bound -b $budget_bound -r $period -o evaluator_output_p${period}_osm2_new -m delays_p${period}_osm2_new -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt -u data_new/error_delay_error${error_bound}_osm2_extr${extrapolator}" 
                                        
                done
            done
        done
    done
done    