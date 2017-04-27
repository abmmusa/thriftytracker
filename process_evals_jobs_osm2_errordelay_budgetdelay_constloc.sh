#!/bin/bash

periods="1800.0 3600.0"

for category in "osm2"; do
	for extrapolator in 0; do
	    #error_delay sampler
	    echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"   
		#error_delay straw-man (single sample)
	    echo "python process_evals_new.py -s 3 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"   
    done
done


for category in "osm2"; do
	for extrapolator in 0; do
		for period in $periods; do
			echo "python process_evals_new.py -s 13 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/"
		done

	    # budget_delay straw-man (single sample)
	    echo "python process_evals_new.py -s 4 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"
	done
done




