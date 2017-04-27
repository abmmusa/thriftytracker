#!/bin/bash


error_bounds="1 2 5 10 20 50 100"
delay_bounds="0 8 64 128"
delay_bounds_error_delay="0 1 8 64 128"
budget_bounds="0.25 0.5 2 4 8" #bytes/sec
periods="1800.0 3600.0"


# ########################
# # error-delay sampler
# #######################

echo "processing error-dealy..."

for category in "osm2"; do
	for extrapolator in 0; do 
        # straw-man single sample [max-error vs budget(bytes/sec) plot]
		cat processed_evals_output_${category}_test/processed_eval_s3_x$extrapolator.txt | awk '$10!=0 {print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 {print}' > data_osm2_test/error_delay_strawman_$category"_extr"$extrapolator
		
        # [max-error vs budget(bytes/sec)]
		for delay in $delay_bounds_error_delay; do
			cat processed_evals_output_${category}_test/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay |\
				awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 {print}' > data_osm2_test/"error_delay_delay"$delay"_"$category"_extr"$extrapolator
		done

	    # [delay vs budget(bytes/sec) plot]
		for max_error in $error_bounds; do
			cat processed_evals_output_${category}_test/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$1==e {print}' e=$max_error \
				> data_osm2_test/"error_delay_error"$max_error"_"$category"_extr"$extrapolator
		done
		
	done
done



# ########################
# # budget delay sampler
# ########################

echo "processing budget-dealy..."

for category in "osm2"; do
	for extrapolator in 0; do
        #straw-man single sample
		# mean error
		cat processed_evals_output_${category}_test/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_osm2_test/budget_delay_strawman_$category"_extr"$extrapolator
		
        #max error
		cat processed_evals_output_${category}_test/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_osm2_test/budget_delay_strawman_maxerror_$category"_extr"$extrapolator

		
		for delay in $delay_bounds; do
			for period in $periods; do
				for id in 12 13; do
			        # mean error
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s${id}_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_osm2_test/"budget_delay_statistical_maxerror"${id}"_delay"$delay"_p"${period}"_"$category"_extr"$extrapolator

			        # max error
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s${id}_x$extrapolator.txt | awk '{print $4, $5, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_osm2_test/"budget_delay_statistical_maxerror"${id}"_maxerror_delay"$delay"_p"${period}"_"$category"_extr"$extrapolator
				done
			done
		done
	done
done



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
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_osm2_test/error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator}

				done
			done
		done

		# error vs avg delay for various budget
		for error in $error_bounds; do
			for budget in $budget_bounds; do
				for period in $periods; do
					# max error
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget | awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 {print}' > data_osm2_test/error_budget3_error_budget${budget}_p${period}_${category}_extr${extrapolator}
					# mean error
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $7, $4, $9/$10, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$3==b {print}' b=$budget | awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 {print}' > data_osm2_test/error_budget3_meanerror_budget${budget}_p${period}_${category}_extr${extrapolator}
				done
			done
		done

		# conformance with budget for various error
		for budget in $budget_bounds; do
			for error in $error_bounds; do
				for period in $periods; do
					cat processed_evals_output_p${period}_${category}_test/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_osm2_test/error_budget3_conformance_alldata_budget_error${error}_p${period}_${category}_extr${extrapolator}

					cat processed_evals_output_p${period}_${category}_test/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}'> data_osm2_test/error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator}


				done
			done
		done

		# put together given and used budget along with mean delays for various errors
		for error in $error_bounds; do
			for period in $periods; do
				gawk 'ARGIND==1 {delay[$1$2]=$3;next} {print $1,$2,delay[$1$2],$3}' data_osm2_test/error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator} data_osm2_test/error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator} \
					> data_osm2_test/error_budget3_budgetusage_error${error}_p${period}_${category}_extr${extrapolator} 
			done
		done
		
	done
done

