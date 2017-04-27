#!/bin/bash


#
# w/o delays
#
# budget_bounds="0.1640625 2.625 5.25"
# trace_files="69414.txt.gz 14569.txt.gz"

# for budget in $budget_bounds; do
# 	for trace in $trace_files; do

# 	echo "gunzip -c traces/osm/$trace | python -W ignore evaluator_new.py -s 10 -x 0 -b $budget -d 0 -o evaluator_output_osm_new -i 69414 -t offline_budget_tables/expected_exponentialerror_for_budget_offline/osm_x0.pkl > data_debug/data_funexp_id${trace}_p7200_b${budget}"

# 	done
# done

# #
# # with delays
# #
# budget_bounds="0.1640625 2.625 5.25"
# trace_files="69414.txt.gz 14569.txt.gz"
# delays="8 128"

# for budget in $budget_bounds; do
# 	for trace in $trace_files; do
# 		for delay in $delays; do 

# 			echo "gunzip -c traces/osm/$trace | python -W ignore evaluator_new.py -s 10 -x 0 -b $budget -d $delay -o evaluator_output_osm_new -i 69414 -t offline_budget_tables/expected_exponentialerror_for_budget_offline/osm_x0.pkl > data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}"

# 		done
# 	done
# done



### SIMULATION

#
# with delays
#
budget_bounds="0.1640625 2.625 5.25"
trace_files="trace.txt.gz"
delays="0 8 32"

for budget in $budget_bounds; do
	for trace in $trace_files; do
		for delay in $delays; do 
			id=`echo $trace | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
			
			echo "gunzip -c traces/simulation/$trace | python -W ignore evaluator_new.py -s 10 -x 0 -b $budget -d $delay -o evaluator_output_simulation_new -i $id -t offline_budget_tables/expected_exponentialerror_for_budget_offline/simulation_x0_d${delay}.pkl > data_debug/data_simulation_id${id}_b${budget}_d${delay}"

		done
	done
done

