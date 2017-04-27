#!/bin/bash

#for category in "osm" "uic" "msmls"; do
#	for extrapolator in 0 1; do
for category in "osm"; do
	for extrapolator in 0; do
		# error_delay sampler
		echo "python process_evals.py -s 1 -x $extrapolator -i evaluator_output_$category/ -o processed_evals_output_$category/"   
		# error_delay straw-man
		echo "python process_evals.py -s 3 -x $extrapolator -i evaluator_output_$category/ -o processed_evals_output_$category/"   

		# budget_delay sampler
		#echo "python process_evals.py -s 2 -x $extrapolator -i evaluator_output_$category/ -o processed_evals_output_$category/"
		# budget_delay straw-man
		#echo "python process_evals.py -s 4 -x $extrapolator -i evaluator_output_$category/ -o processed_evals_output_$category/"
		
		# error_budget sampler
		# echo "python process_evals.py -s 0 -x $extrapolator -i evaluator_output_$category/ -o processed_evals_output_$category/ -m delays_$category/"
	done
done

