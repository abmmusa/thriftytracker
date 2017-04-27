#!/bin/bash



# ########################
# # error-delay sampler
# #######################


#error_bounds="1 5 50 100 500"
#error_bounds="1 2 5 10 25 50 100 200 400"
#error_bounds="1 2 5 10 20 50 100 500"
#delay_bounds="0 1 8 16 32 64 128 256"
#delay_bounds="0 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384"
error_bounds="1 2 5 10 20 50 75 100 150 200 250 300 350 400 450 500"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"

echo "processing error-dealy..."
#for category in "osm" "uic" "msmls" "msmls2"; do
#	for extrapolator in 0 1 2; do
for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 2; do 
		echo $category $extrapolator
        # straw-man single sample [max-error vs budget(bytes/sec) plot]
		cat processed_evals_output_${category}_new/processed_eval_s3_x$extrapolator.txt | awk '$10!=0 {print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | \
			awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}' > data_new/error_delay_table_strawman_$category"_extr"$extrapolator
		
        # [max-error vs budget(bytes/sec)]
		for delay in $delay_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay |\
				awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}' > data_new/"error_delay_table_delay"$delay"_"$category"_extr"$extrapolator
		done

	    # [delay vs budget(bytes/sec) plot]
		for max_error in $error_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$1==e {print}' e=$max_error \
				> data_new/"error_delay_table_error"$max_error"_"$category"_extr"$extrapolator
		done
		
	done
done

