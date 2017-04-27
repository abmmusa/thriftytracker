#!/bin/bash

error_bounds="1 2 5 10 20 50 100"
delay_bounds="0 8 64 128"
budget_bounds="0.25 0.5 2 4 8" #bytes/sec
periods="1800.0 3600.0"

# #
# #error delay
# #
# for extrapolator in 0; do
#     for id in `seq 16 63`; do
#         for error_bound in $error_bounds; do

# 			echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 3 -x $extrapolator -e $error_bound -o evaluator_output_osm2_test -i $id"

#             for delay_bound in $delay_bounds; do

#                 echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_osm2_test -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt" 
                        
#             done
#         done
#     done
# done    


# #
# # budget delay
# #
# for id in `seq 16 63`; do
# 	for budget_bound in $budget_bounds; do
# 		echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 4 -x 0 -b $budget_bound -o evaluator_output_osm2_test -i $id" 

# 		for delay in $delay_bounds; do
# 			for period in $periods; do
				
# 				#echo $id, $budget_bound, $delay, $period
				
# 				# only extrapolator table
# 				#echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 12 -x 0 -b $budget_bound -d $delay -r $period -o evaluator_output_p${period}_osm2_test -i $id -t offline_budget_tables/duration_error_tables/osm2_x0.txt"

# 				# extrapolator and compressor table
# 				echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 13 -x 0 -b $budget_bound -d $delay -r $period -o evaluator_output_p${period}_osm2_test -i $id -t offline_extrapolator_compressor_table/data/osm2_d${delay}_x0.txt"

# 			done
# 		done
# 	done
# done



#
#error budget
#
for extrapolator in 0; do
    for id in `seq 16 63`; do
        for error_bound in $error_bounds; do
            for budget_bound in $budget_bounds; do
                for period in $periods; do
					
					echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 21 -x $extrapolator -e $error_bound -b $budget_bound -r $period -o evaluator_output_p${period}_osm2_test -m delays_p${period}_osm2_test -i $id -t offline_error_tables/error_duration_tables/osm2_x${extrapolator}.txt -u data_osm2_test/error_delay_error${error_bound}_osm2_extr${extrapolator}" 
                                        
                done
            done
        done
    done
done 