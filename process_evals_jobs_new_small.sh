#!/bin/bash

for category in "osm"; do
	for extrapolator in 0; do
		# error_delay sampler
		#echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"   
		# error_delay straw-man (single sample)
		#echo "python process_evals_new.py -s 3 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"   
		# error_delay straw-man (full window)
		#echo "python process_evals_new.py -s 5 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"   


		# budget_delay sampler 1
		#echo "python process_evals_new.py -s 2 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"

		# budget delay strawman
		#echo "python process_evals_new.py -s 8 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"
		
		
		# budget_delay sampler 2
		#echo "python process_evals_new.py -s 12 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"

		# budget_delay sampler statistical
		echo "python process_evals_new.py -s 10 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"


		# budget_delay straw-man (single sample)
		#echo "python process_evals_new.py -s 4 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"
		# budget delay straw-man (full window)
		#echo "python process_evals_new.py -s 6 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/"

		# error_budget sampler
		#echo "python process_evals_new.py -s 0 -x $extrapolator -i evaluator_output_${category}_new_small/ -o processed_evals_output_${category}_new_small/ -m delays_${category}_new_small/"
	done
done

