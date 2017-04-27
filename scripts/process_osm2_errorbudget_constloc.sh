#!/bin/bash



# ########################
# # error-delay sampler
# #######################

error_bounds="1 2 5 10 20 50 100 200 500"
delay_bounds="0 1 8 16 32 64 128"
budget_bounds="0.25 0.5 0.75 1 1.5 2 3 4 5 6 7 8" #bytes/sec
periods="1800.0 3600.0"



########################
# Error budget sampler 3
########################

echo "processing error-budget..."

for category in "osm2"; do
	for extrapolator in 0; do
		for period in $periods; do
		    # budget vs avg delay for various errors 
			for budget in $budget_bounds; do
				for error in $error_bounds; do
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_new/error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator}

				done
			done
		done

		# error vs avg delay for various budget
		for error in $error_bounds; do
			for budget in $budget_bounds; do
				for period in $periods; do
					# max error
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget | awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==200 || $1==500 {print}' > data_new/error_budget3_error_budget${budget}_p${period}_${category}_extr${extrapolator}
					# mean error
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $7, $4, $9/$10, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$3==b {print}' b=$budget | awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==200 || $1==500 {print}' > data_new/error_budget3_meanerror_budget${budget}_p${period}_${category}_extr${extrapolator}
				done
			done
		done

		# conformance with budget for various error
		for budget in $budget_bounds; do
			for error in $error_bounds; do
				for period in $periods; do
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_new/error_budget3_conformance_alldata_budget_error${error}_p${period}_${category}_extr${extrapolator}

					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}'> data_new/error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator}


				done
			done
		done

		# put together given and used budget along with mean delays for various errors
		for error in $error_bounds; do
			for period in $periods; do
				gawk 'ARGIND==1 {delay[$1$2]=$3;next} {print $1,$2,delay[$1$2],$3}' data_new/error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator} data_new/error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator} \
					> data_new/error_budget3_budgetusage_error${error}_p${period}_${category}_extr${extrapolator} 
			done
		done
		
	done
done


