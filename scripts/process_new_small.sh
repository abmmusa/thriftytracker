#!/bin/bash


########################
# budget delay sampler
########################

budget_bounds="0.328125 0.65625 1.3125 2.625 10.5" #bytes/sec
delay_bounds="0 8 32 64 128 256"

delay_bounds_window_strawman="8 32 64 128 256"


for category in "osm"; do
	for extrapolator in 0; do

	    # #budget_delay samplers
		# for delay in $delay_bounds; do
		# 	cat processed_evals_output_${category}_new_small/processed_eval_s2_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
		# 		> data_new_small/"budget_delay_2_delay"$delay"_"$category"_extr"$extrapolator
		# done


	    # #budget_delay strawman
		# for delay in $delay_bounds; do
		# 	cat processed_evals_output_${category}_new_small/processed_eval_s8_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
		# 		> data_new_small/"budget_delay_8_delay"$delay"_"$category"_extr"$extrapolator
		# done



        #straw-man single sample
		#cat processed_evals_output_${category}_new_small/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new_small/budget_delay_strawman_$category"_extr"$extrapolator
		
		# #straw-man full window (compressed)
		# cat processed_evals_output_${category}_new_small/processed_eval_s6_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new_small/budget_delay_strawman_window_$category"_extr"$extrapolator

		# budget-delay sampler [statistical]
		for delay in $delay_bounds; do
			cat processed_evals_output_${category}_new_small/processed_eval_s10_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
				> data_new_small/"budget_delay_10_delay"$delay"_"$category"_extr"$extrapolator
		done

		# for delay in $delay_bounds; do
		# 	cat processed_evals_output_${category}_new_small/processed_eval_s12_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
		# 		> data_new_small/"budget_delay_12_delay"$delay"_"$category"_extr"$extrapolator
		# done

	

	done
done



########################
# error budget sampler
########################

# error_bounds="1 5 10 25 50 100 200 500 1000 2000"
# budget_bounds="0.1 0.25 0.5 0.75 1 2 5 8 10 15" #bytes/sec

# #for category in "osm" "msmls" "uic"; do
# #	for extrapolator in 0 1; do

# for category in "osm" "msmls" "uic" "msmls2"; do
# 	for extrapolator in 0; do
# 		# budget vs avg delay for various errors 
# 		for budget in $budget_bounds; do
# 			for error in $error_bounds; do
# 				cat processed_evals_output_${category}_new_small/processed_eval_s0_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
# 					> data_new_small/"error_budget_budget_error"$error"_"$category"_extr"$extrapolator
# 			done
# 		done

# 		# error vs avg delay for various budget
# 		for error in $error_bounds; do
# 			for budget in $budget_bounds; do
# 				cat processed_evals_output_${category}_new_small/processed_eval_s0_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget \
# 					> data_new_small/"error_budget_error_budget"$budget"_"$category"_extr"$extrapolator
# 			done
# 		done

# 		# conformance with budget for various error
# 		for budget in $budget_bounds; do
# 			for error in $error_bounds; do
# 				cat processed_evals_output_${category}_new_small/processed_eval_s0_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
# 					> data_new_small/"error_budget_conformance_budget_error"$error"_"$category"_extr"$extrapolator

# 			done
# 		done

# 	done
# done


