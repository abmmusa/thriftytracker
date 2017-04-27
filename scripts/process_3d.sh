#!/bin/bash


error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"
#delay_bounds="0 8 16 32 64 128"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"
budget_bounds="0.125 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8" #bytes/sec
periods="1800.0 3600.0"


# ########################
# # error-delay sampler
# #######################

for category in "osm2"; do
	for extrapolator in 0; do 
		for delay in $delay_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay > data_new/"3d_error_delay_delay"$delay"_"$category"_extr"$extrapolator

		done

		# needed for tables in error budgets
		for max_error in $error_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$1==e {print}' e=$max_error > data_new/"3d_error_delay_error"$max_error"_"$category"_extr"$extrapolator
		done

		#straw-man
		cat processed_evals_output_${category}_new/processed_eval_s3_x$extrapolator.txt | awk '$10!=0 {print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new/3d_error_delay_strawman_$category"_extr"$extrapolator

	done
done




# ########################
# # budget delay sampler
# ########################

for category in "osm2"; do
	for extrapolator in 0; do
		for delay in $delay_bounds; do
			for period in $periods; do	
				cat processed_evals_output_p${period}_${category}_new/processed_eval_s13_x$extrapolator.txt | awk '$10!=0 || $10!=inf {print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay > data_new/3d_budget_delay_statistical_maxerror_delay${delay}_p${period}_${category}_extr${extrapolator}
			done
		done

		#strawman
		cat processed_evals_output_${category}_new/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new/3d_budget_delay_strawman_$category"_extr"$extrapolator
		
	done
done


########################
# Error budget sampler 3
########################
for category in "osm2"; do
	for extrapolator in 0; do
		for period in $periods; do	
			for budget in $budget_bounds; do
				for error in $error_bounds; do	
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_new/3d_error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator}
				done
			done
		done
	done
done




for category in "osm2"; do
	for extrapolator in 0; do
		for error in $error_bounds; do
			for budget in $budget_bounds; do
				for period in $periods; do
					#cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_new/3d_error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator}

					# max error
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget > data_new/3d_error_budget3_error_budget${budget}_p${period}_${category}_extr${extrapolator}
					
					# mean error
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $7, $4, $9/$10, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$3==b {print}' b=$budget	> data_new/3d_error_budget3_meanerror_budget${budget}_p${period}_${category}_extr${extrapolator}

					# conformance
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_new/3d_error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator}


				done
			done
		done

		# put together given and used budget along with mean delays for various errors
		for error in $error_bounds; do
			for period in $periods; do
				gawk 'ARGIND==1 {delay[$1$2]=$3;next} {print $1,$2,delay[$1$2],$3}' data_new/3d_error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator} data_new/3d_error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator} \
					> data_new/3d_error_budget3_budgetusage_error${error}_p${period}_${category}_extr${extrapolator} 
			done
		done


	done
done


