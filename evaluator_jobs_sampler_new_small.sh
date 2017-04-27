#!/bin/bash


budget_bounds="0.328125 0.65625 1.3125 2.625 10.5" #bytes/sec
delay_bounds="0 8 32 64 128 256"
delay_bounds_window_strawman="8 32 64 128 256"

#################
#budget delay
#################


expected_error_table[0]=""
expected_error_table[1]="_const_vel"


for category in "osm"; do
	for extrapolator in 0; do
		trace_dir="traces_small/$category"
		trace_files=`ls $trace_dir`
		
		for file in $trace_files; do
			id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
	
			# for budget_bound in $budget_bounds; do
			# 	for delay_bound in $delay_bounds; do
			# 		echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 8 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_${category}_new_small -i $id"

			# 	done
			# done


            # #budget-delay
			# for budget_bound in $budget_bounds; do
			# 	for delay_bound in $delay_bounds; do
			# 		echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 2 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_${category}_new_small -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/${category}${expected_error_table[$extrapolator]}.pkl" 
			# 	done
			# done

			#budget-delay statistical
			for budget_bound in $budget_bounds; do
				for delay_bound in $delay_bounds; do
					echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 10 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_${category}_new_small -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/${category}${expected_error_table[$extrapolator]}.pkl" 
				done
			done



            #straw-man single sample
		   	# for budget_bound in $budget_bounds; do 
		   	# 	echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 4 -x $extrapolator -b $budget_bound -o evaluator_output_${category}_new_small -i $id" 
		   	# done

		   	# #straw-man full window (compressed)
		   	# for budget_bound in $budget_bounds; do
		   	# 	for delay in $delay_bounds_window_strawman; do
		   	# 		budget_bound=`echo $delay | awk '{print 84.0/$1}'`
		   	# 		echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 6 -x $extrapolator -b $budget_bound -o evaluator_output_${category}_new_small -i $id" 
		   	# done



			# #budget-delay 2
			# factors="0.5 1.0 2.0 4.0"
			# for factor in $factors; do
			# 	for budget_bound in $budget_bounds; do
			# 		for delay_bound in $delay_bounds; do
			# 			echo "gunzip -c $trace_dir/$file | python -W ignore evaluator_new.py -s 12 -x $extrapolator -b $budget_bound -d $delay_bound -a $factor -o evaluator_output_${category}_new_small -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/${category}${expected_error_table[$extrapolator]}.pkl" 
			# 		done
			# 	done
			# done

 

		done

	done
done
