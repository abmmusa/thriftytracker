#!/bin/bash


periods="1800.0 3600.0"

for category in "osm2"; do
	for extrapolator in 0 2; do
	    # error_delay sampler
	    echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${category}_test/ -o processed_evals_output_${category}_test/"   
	    # error_delay straw-man 
	    echo "python process_evals_new.py -s 3 -x $extrapolator -i evaluator_output_${category}_test/ -o processed_evals_output_${category}_test/"   

		for period in $periods; do
			# error_budget 
			echo "python process_evals_new.py -s 21 -x $extrapolator -i evaluator_output_p${period}_${category}_test/ -o processed_evals_output_p${period}_${category}_test/ -m delays_p${period}_${category}_test/"
		done
    done
done





# budget-delay
for category in "osm2"; do
	for extrapolator in 0 3; do		
		for period in $periods; do
	        # budget_delay sampler
			echo "python process_evals_new.py -s 13 -x $extrapolator -i evaluator_output_p${period}_${category}_test/ -o processed_evals_output_p${period}_${category}_test/"
		done
	done
done


# budget delay straw-man
for category in "osm2"; do
	for extrapolator in 0; do		
		echo "python process_evals_new.py -s 4 -x $extrapolator -i evaluator_output_${category}_test/ -o processed_evals_output_${category}_test/"
	done
done



