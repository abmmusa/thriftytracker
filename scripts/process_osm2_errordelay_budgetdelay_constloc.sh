#!/bin/bash



# ########################
# # error-delay sampler
# #######################

error_bounds="1 2 5 10 20 50 100 200 500"
delay_bounds="0 1 8 16 32 64 128"
budget_bounds="0.25 0.5 0.75 1 1.5 2 3 4 5 6 7 8" #bytes/sec
periods="1800.0 3600.0"


echo "processing error-dealy..."

for category in "osm2"; do
	for extrapolator in 0; do 
        # straw-man single sample [max-error vs budget(bytes/sec) plot]
		cat processed_evals_output_${category}_new/processed_eval_s3_x$extrapolator.txt | awk '$10!=0 {print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==200 || $1==500 {print}' > data_new/error_delay_strawman_$category"_extr"$extrapolator
		
        # [max-error vs budget(bytes/sec)]
		for delay in $delay_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay |\
				awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==200 || $1==500 {print}' > data_new/"error_delay_delay"$delay"_"$category"_extr"$extrapolator
		done

	    # [delay vs budget(bytes/sec) plot]
		for max_error in $error_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$1==e {print}' e=$max_error \
				> data_new/"error_delay_error"$max_error"_"$category"_extr"$extrapolator
		done
		
	done
done





# ########################
# # budget delay sampler
# ########################

echo "processing budget-dealy..."

for category in "osm2"; do
	for extrapolator in 0; do
		for delay in $delay_bounds; do
			for period in $periods; do
			    # mean error
				cat processed_evals_output_p${period}_${category}_new/processed_eval_s13_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_new/budget_delay_statistical_maxerror_delay${delay}_p${period}_${category}_extr${extrapolator}
			    # max error
				cat processed_evals_output_p${period}_${category}_new/processed_eval_s13_x$extrapolator.txt | awk '{print $4, $5, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_new/budget_delay_statistical_maxerror_maxerror_delay${delay}_p${period}_${category}_extr${extrapolator}



			done
		done

        #straw-man single sample
		# mean error
		cat processed_evals_output_${category}_new/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_new/budget_delay_strawman_$category"_extr"$extrapolator
		#max error
		cat processed_evals_output_${category}_new/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | awk '$1==0.25 || $1==0.5 || $1==0.75 || $1==1 || $1==1.5 || $1==2 || $1==3 || $1==4 || $1==5 || $1==6 || $1==7 || $1==8 {print}' > data_new/budget_delay_strawman_maxerror_$category"_extr"$extrapolator


	done
done


