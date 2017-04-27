#!/bin/bash

error_bounds="1 2 5 10 20 50 100 500"
delay_bounds="0 8 16 32 64 128"

#
#error delay with CV
#

for extrapolator in 1; do
    for id in `seq 16 63`; do
        for error_bound in $error_bounds; do
            for delay_bound in $delay_bounds; do

                echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt" 
                        
            done
        done
    done
done    



#
#error delay with map based
#

for extrapolator in 5; do
    for id in `seq 16 63`; do
        for error_bound in $error_bounds; do
            for delay_bound in $delay_bounds; do

                echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt -f map_matching/pickle/moscow-140114_300km.pkl" 
                        
            done
        done
    done
done    
