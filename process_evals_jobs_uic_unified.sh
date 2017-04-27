#!/bin/bash

periods="1800.0 3600.0"

for category in "uic"; do
	for extrapolator in 2; do
	    #error_delay sampler
	    echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"   
		#error_delay straw-man (single sample)
	    echo "python process_evals_new.py -s 3 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/" 
		

		for period in $periods; do
			#error_budget sampler 3 
			echo "python process_evals_new.py -s 21 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/ -m delays_p${period}_${category}_new/"
		done
    done
done


for category in "uic"; do
	for extrapolator in 3; do
		# budget_delay straw-man (single sample)
		echo "python process_evals_new.py -s 4 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"
		
		for period in $periods; do
	        # budget_delay sampler
	        #echo "python process_evals_new.py -s 11 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"
			echo "python process_evals_new.py -s 13 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/"
	        
		done
	done
done




