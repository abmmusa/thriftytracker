#!/bin/bash

periods="1800.0 3600.0"

for category in "osm2"; do
	for extrapolator in 0; do
		for period in $periods; do
			# error_budget sampler 3 
			echo "python process_evals_new.py -s 21 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/ -m delays_p${period}_${category}_new/"
		done
    done
done







