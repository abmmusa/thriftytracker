#!/bin/bash

error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"
budget_bounds="0.125 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8" #bytes/sec
periods="1800.0 3600.0"

#
#error delay
#
for extrapolator in 0; do
    for id in `seq 16 63`; do
        for error_bound in $error_bounds; do

			#echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x $extrapolator -e $error_bound -o evaluator_output_osm2_new -i $id"

            for delay_bound in $delay_bounds; do

                echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt" 
                        
            done
        done
    done
done    


#
# budget delay
#
for extrapolator in 0; do
    for id in `seq 16 63`; do
        for budget_bound in $budget_bounds; do
			 echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x $extrapolator -b $budget_bound -o evaluator_output_osm2_new -i $id" 
			
			for delay in $delay_bounds; do
				for period in $periods; do
                    #echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 11 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_osm2_new -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/maxerror_osm2_x${extrapolator}_d${delay_bound}.pkl"
				
					#echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 12 -x $extrapolator -b $budget_bound -d $delay_bound -r $period -o evaluator_output_p${period}_osm2_new -i $id -t offline_budget_tables/duration_error_tables/osm2_x${extrapolator}.txt"

					echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 13 -x $extrapolator -b $budget_bound -d $delay -r $period -o evaluator_output_p${period}_osm2_new -i $id -t offline_extrapolator_compressor_table/data/osm2_d${delay}_x0.txt"

				done
			done
		done
    done
done

