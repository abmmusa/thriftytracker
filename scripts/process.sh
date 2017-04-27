#!/bin/bash


delay_bounds="0 5 10 15 20 30 60 120 300"
error_bounds="2 5 10 30 50 100 200 300 500 1000"

for category in "osm" "msmls" "uic"; do
	for extrapolator in 0 1; do
	    # ########################
	    # # error-delay sampler
	    # #######################

        # straw-man location change for comparing with error_delay sampler [max-error vs Tx-interval plot]
		cat processed_evals_output_$category/processed_eval_s3_x$extrapolator.txt | awk '{print $3,  $7, $10/$9}' | sed 's/d//; s/e//; s/b//' | sort -n > data/error_delay_strawman_$category"_extr"$extrapolator

        # error_delay sampler [max-error vs Tx-interval plot]
		for delay in $delay_bounds; do
			cat processed_evals_output_$category/processed_eval_s1_x$extrapolator.txt | awk '{print $3, $5, $7, $10/$9}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
				> data/"error_delay_delay"$delay"_"$category"_extr"$extrapolator
		done

	    # [delay vs Tx-Interval plot]
		for max_error in $error_bounds; do
			cat processed_evals_output_$category/processed_eval_s1_x$extrapolator.txt | awk '{print $3, $5, $7, $10/$9}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$1==e {print}' e=$max_error \
				> data/"error_delay_error"$max_error"_"$category"_extr"$extrapolator
		done
		



	    # ########################
	    # # budget delay sampler
  	    # ########################
        # straw-man time change for comparing with budget_delay sampler [mean-error vs budget plot]
		# cat processed_evals_output_$category/processed_eval_s4_x$extrapolator.txt | awk '{print $4,  $7}' | sed 's/d//; s/e//; s/b//' | sort -n > data/budget_delay_strawman_$category"_extr"$extrapolator

		# budget_bounds="15 20 30 60 90 120 200 300 450 600"
		# delay_bounds_budget="2 3 5 10 15 20 25 30 50 70 90 100 150 200 250 300 350 400"

	    # #budget_delay sampler [mean-error vs budget plot]
		# for delay in $delay_bounds_budget; do
		# 	cat processed_evals_output_$category/processed_eval_s2_x$extrapolator.txt | awk '{print $4, $5, $7, $10/$9}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
		# 		> data/"budget_delay_delay"$delay"_"$category"_extr"$extrapolator
		# done
	

	    ########################
	    # error budget sampler
  	    ########################
		# error_bounds="2 5 10 30 50 100 200 300 500 1000"
		# budget_bounds="2 5 10 15 20 30 60 120 300" #tx every budget_bound seconds


		# # budget vs avg delay for various errors 
		# for budget in $budget_bounds; do
		# 	for error in $error_bounds; do
		# 		cat processed_evals_output_$category/processed_eval_s0_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
		# 			> data/"error_budget_budget_error"$error"_"$category"_extr"$extrapolator
		# 	done
		# done

		# # error vs avg delay for various budget
		# for error in $error_bounds; do
		# 	for budget in $budget_bounds; do
		# 		cat processed_evals_output_$category/processed_eval_s0_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget \
		# 			> data/"error_budget_error_budget"$budget"_"$category"_extr"$extrapolator
		# 	done
		# done

		# # conformance with budget for various error
		# for budget in $budget_bounds; do
		# 	for error in $error_bounds; do
		# 		cat processed_evals_output_$category/processed_eval_s0_x$extrapolator.txt | awk '{print $4,$3,$10/$9}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
		# 			> data/"error_budget_conformance_budget_error"$error"_"$category"_extr"$extrapolator

		# 	done
		# done

	done
done


