#!/bin/bash



# ########################
# # error-delay sampler
# #######################


#error_bounds="1 5 50 100 500"
#error_bounds="1 2 5 10 25 50 100 200 400"
error_bounds="1 2 5 10 20 50 100 500"
delay_bounds="0 1 8 16 32 64 128 256"

echo "processing error-dealy..."
#for category in "osm" "uic" "msmls" "msmls2"; do
#	for extrapolator in 0 1 2; do
for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 2; do 
		echo $category $extrapolator
        # straw-man single sample [max-error vs budget(bytes/sec) plot]
		cat processed_evals_output_${category}_new/processed_eval_s3_x$extrapolator.txt | awk '$10!=0 {print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | \
			awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}' > data_new/error_delay_strawman_$category"_extr"$extrapolator
		
        # [max-error vs budget(bytes/sec)]
		for delay in $delay_bounds; do
			cat processed_evals_output_${category}_new/processed_eval_s1_x$extrapolator.txt | awk '$10!=0 {print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay |\
				awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}' > data_new/"error_delay_delay"$delay"_"$category"_extr"$extrapolator
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

#budget_bounds="0.1640625 0.328125 1.3125 2.625 5.25 10.5" #bytes/sec
#budget_bounds="0.1 0.25 0.5 0.75 1 2 3.5 5 8" #bytes/sec
budget_bounds="0.125 0.25 0.5 1 2 4 8" #bytes/sec
delay_bounds="0 8 16 32 64"

echo "processing budget-dealy..."
#for category in "msmls" "msmls2" "uic" "osm" "osm2"; do
#	for extrapolator in 0 1 3; do
for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 3; do

		#budget_delay sampler [mean-error vs budget plot] [statistical]
		for delay in $delay_bounds; do
			# mean error
			cat processed_evals_output_${category}_new/processed_eval_s11_x$extrapolator.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
				| awk '$1==0.125 || $1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_new/"budget_delay_statistical_maxerror_delay"$delay"_"$category"_extr"$extrapolator
			# max error
			cat processed_evals_output_${category}_new/processed_eval_s11_x$extrapolator.txt | awk '{print $4, $5, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay \
				| awk '$1==0.125 || $1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_new/"budget_delay_statistical_maxerror_maxerror_delay"$delay"_"$category"_extr"$extrapolator

		done

        #straw-man single sample
		# mean error
		cat processed_evals_output_${category}_new/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | \
			awk '$1==0.125 || $1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_new/budget_delay_strawman_$category"_extr"$extrapolator
		#max error
		cat processed_evals_output_${category}_new/processed_eval_s4_x$extrapolator.txt | awk '{print $4, $11, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n | \
			awk '$1==0.125 || $1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_new/budget_delay_strawman_maxerror_$category"_extr"$extrapolator


	done
done


# spacial processing for the window straw-man to mathch delay of regular samplers to the budget of straw-man sampler
# delay_bounds="0 2 4 8 16 32 64 128 256"
# for category in "osm" "uic" "msmls"; do
# 	for extrapolator in 0; do
# 		for delay in $delay_bounds; do
# 			budget_bound=`echo $delay | awk '{print 84.0/$1}'`
		
# 			data=`cat processed_evals_output_${category}_new/processed_eval_s6_x$extrapolator.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | grep $budget_bound`
# 			echo $budget_bound $data
		

# 		#sort -n > data_new/budget_delay_strawman_window_$category"_extr"$extrapolator
# 		done
# 	done
# done



########################
# error budget sampler
########################

# #error_bounds="1 5 10 25 50 100 200 500"
# #budget_bounds="0.1 0.25 0.5 0.75 1 2 3.5 5 8" #bytes/sec

# error_bounds="1 2 5 10 25 50 100 200 400"
# budget_bounds="0.1 0.25 0.5 1 2 4 8" #bytes/sec

# #for category in "osm" "osm2" "uic" "msmls" "msmls2"; do
# #	for extrapolator in 0 1 2; do
# for category in "osm2"; do
# 	for extrapolator in 0 1 2; do

# 		# budget vs avg delay for various errors 
# 		for budget in $budget_bounds; do
# 			for error in $error_bounds; do
# 				cat processed_evals_output_${category}_new/processed_eval_s0_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
# 					> data_new/"error_budget_budget_error"$error"_"$category"_extr"$extrapolator
# 			done
# 		done

# 		# error vs avg delay for various budget
# 		for error in $error_bounds; do
# 			for budget in $budget_bounds; do
# 				cat processed_evals_output_${category}_new/processed_eval_s0_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget \
# 					> data_new/"error_budget_error_budget"$budget"_"$category"_extr"$extrapolator
# 			done
# 		done

# 		# conformance with budget for various error
# 		for budget in $budget_bounds; do
# 			for error in $error_bounds; do
# 				cat processed_evals_output_${category}_new/processed_eval_s0_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
# 					> data_new/"error_budget_conformance_budget_error"$error"_"$category"_extr"$extrapolator

# 			done
# 		done

# 		# put together given and used budget along with mean delays for various errors
# 		for error in $error_bounds; do
# 			gawk 'ARGIND==1 {delay[$1$2]=$3;next} {print $1,$2,delay[$1$2],$3}' data_new/error_budget_budget_error${error}_osm2_extr0 data_new/error_budget_conformance_budget_error${error}_osm2_extr0 \
# 				> data_new/error_budget_budgetusage_error${error}_osm2_extr0 
# 		done


# 	done
# done



# ########################
# # Error budget sampler 2
# ########################

# #error_bounds="1 2 5 10 25 50 100 200 400"
# error_bounds="1 2 5 10 20 50 100 500"
# budget_bounds="0.125 0.25 0.5 1 2 4 8" #bytes/sec
# #periods="3600.0 14400.0 57600.0 230400.0"
# periods="3600.0 57600.0"

# echo "processing error-budget..."

# #for category in "osm" "osm2" "uic" "msmls" "msmls2"; do
# #	for extrapolator in 0 1 2; do
# for category in "osm2" "uic" "msmls"; do
# 	for extrapolator in 0 1 2; do
# 		for period in $periods; do
# 		    # budget vs avg delay for various errors 
# 			for budget in $budget_bounds; do
# 				for error in $error_bounds; do
# 					cat processed_evals_output_p${period}_${category}_new/processed_eval_s20_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
# 						| awk '$1==0.125 || $1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_new/error_budget2_budget_error${error}_p${period}_${category}_extr${extrapolator}
# 				done
# 			done
# 		done

# 		# error vs avg delay for various budget
# 		for error in $error_bounds; do
# 			for budget in $budget_bounds; do
# 				for period in $periods; do
# 					# max error
# 					cat processed_evals_output_p${period}_${category}_new/processed_eval_s20_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget \
# 						| awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}' > data_new/error_budget2_error_budget${budget}_p${period}_${category}_extr${extrapolator}
# 					# mean error
# 					cat processed_evals_output_p${period}_${category}_new/processed_eval_s20_x$extrapolator.txt | awk '{print $3, $7, $4, $9/$10, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$3==b {print}' b=$budget \
# 						| awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}'	> data_new/error_budget2_meanerror_budget${budget}_p${period}_${category}_extr${extrapolator}
# 				done
# 			done
# 		done

# 		# conformance with budget for various error
# 		for budget in $budget_bounds; do
# 			for error in $error_bounds; do
# 				for period in $periods; do
# 					cat processed_evals_output_p${period}_${category}_new/processed_eval_s20_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
# 						| awk '$1==0.125 || $1==0.25 || $1==0.5 || $1==1 || $1==2 || $1==4 || $1==8 {print}' > data_new/error_budget2_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator}
# 				done
# 			done
# 		done

# 		# put together given and used budget along with mean delays for various errors
# 		for error in $error_bounds; do
# 			for period in $periods; do
# 				gawk 'ARGIND==1 {delay[$1$2]=$3;next} {print $1,$2,delay[$1$2],$3}' data_new/error_budget2_budget_error${error}_p${period}_${category}_extr${extrapolator} data_new/error_budget2_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator} \
# 					> data_new/error_budget2_budgetusage_error${error}_p${period}_${category}_extr${extrapolator} 
# 			done
# 		done
		
# 	done
# done



########################
# Error budget sampler 3
########################

#error_bounds="1 2 5 10 25 50 100 200 400"
error_bounds="1 2 5 10 20 50 100 500"
budget_bounds="0.125 0.25 0.5 1 2 4 8" #bytes/sec
#periods="3600.0 14400.0 57600.0 230400.0"
periods="600.0 1800.0 3600.0 57600.0"

echo "processing error-budget..."

#for category in "osm" "osm2" "uic" "msmls" "msmls2"; do
#	for extrapolator in 0 1 2; do
for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 2; do
		for period in $periods; do
		    # budget vs avg delay for various errors 
			for budget in $budget_bounds; do
				for error in $error_bounds; do
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
						| awk '$1==0.125 || $1==0.25 || $1==0.5 ||  $1==0.75 || $1==1 ||  $1==1.25 || $1==1.5 || $1==1.75 || $1==2 || $1==2.5 || $1==3.5 || $1==4 || $1==6 || $1==8 {print}' > data_new/error_budget3_budget_error${error}_p${period}_${category}_extr${extrapolator}

				done
			done
		done

		# error vs avg delay for various budget
		for error in $error_bounds; do
			for budget in $budget_bounds; do
				for period in $periods; do
					# max error
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget \
						| awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}' > data_new/error_budget3_error_budget${budget}_p${period}_${category}_extr${extrapolator}
					# mean error
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $3, $7, $4, $9/$10, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$3==b {print}' b=$budget \
						| awk '$1==1 || $1==2 || $1==5 || $1==10 || $1==20 || $1==50 || $1==100 || $1==500 {print}'	> data_new/error_budget3_meanerror_budget${budget}_p${period}_${category}_extr${extrapolator}
				done
			done
		done

		# conformance with budget for various error
		for budget in $budget_bounds; do
			for error in $error_bounds; do
				for period in $periods; do
					cat processed_evals_output_p${period}_${category}_new/processed_eval_s21_x$extrapolator.txt | awk '{print $4, $3, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error \
						| awk '$1==0.125 || $1==0.25 || $1==0.5 ||  $1==0.75 || $1==1 ||  $1==1.25 || $1==1.5 || $1==1.75 || $1==2 || $1==2.5 || $1==3.5 || $1==4 || $1==6 || $1==8 {print}' > data_new/error_budget3_conformance_budget_error${error}_p${period}_${category}_extr${extrapolator}
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


