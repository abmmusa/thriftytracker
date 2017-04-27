#!/bin/bash

#periods="3600.0 14400.0 57600.0 230400.0"
#periods="3600.0 57600.0"
periods="600.0 1800.0 3600.0 57600.0"

# for category in "msmls" "uic" "osm2"; do
# 	for extrapolator in 0 1 2; do
# 	    # error_delay sampler
# 	    #echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"   
# 	    # error_delay straw-man (single sample)
# 	    #echo "python process_evals_new.py -s 3 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"   

# 		for period in $periods; do
# 	        # error_budget sampler
# 	        # echo "python process_evals_new.py -s 0 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/ -m delays_${category}_new/"
# 	        # error_budget sampler 2
# 			#echo "python process_evals_new.py -s 20 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/ -m delays_p${period}_${category}_new/"
# 			# error_budget sampler 3 
# 			echo "python process_evals_new.py -s 21 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/ -m delays_p${period}_${category}_new/"
# 		done
#     done
# done


#for category in "msmls" "uic" "osm2"; do
#	for extrapolator in 0 1 3; do
#periods="57600.0"
periods="1800.0 3600.0"

for category in "osm2"; do
	for extrapolator in 0; do
		for period in $periods; do
	        # budget_delay sampler
			echo "python process_evals_new.py -s 12 -x $extrapolator -i evaluator_output_p${period}_${category}_new/ -o processed_evals_output_p${period}_${category}_new/"
	        # budget_delay straw-man (single sample)
			#echo "python process_evals_new.py -s 4 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"
		done
	done
done


# #
# # related works
# #
# for category in "osm2"; do
# 	for extrapolator in 1 5; do
# 	    echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${category}_new/ -o processed_evals_output_${category}_new/"
# 	done
# done





