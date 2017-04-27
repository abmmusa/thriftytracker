#!/bin/bash


error_bounds="2 5 10 30 50 100 200 300 500 1000"
delay_bounds="0 5 10 15 20 30 60 120 300"

expected_error_table[0]=""
expected_error_table[1]="_const_vel"

#for category in "osm" "uic" "msmls"; do
for category in "osm"; do
	for extrapolator in 0 1; do
		trace_dir="traces/$category"
		#trace_files=`ls $trace_dir`
		trace_files="14569.txt.gz"

		for file in $trace_files; do
			id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
			
			# straw-man
			for error_bound in $error_bounds; do
				echo "gunzip -c $trace_dir/$file | python evaluator.py -s 3 -x $extrapolator -e $error_bound -o evaluator_output_$category -i $id" 
			done

			# error-delay
			for error_bound in $error_bounds; do
				for delay_bound in $delay_bounds; do
					echo "gunzip -c $trace_dir/$file | python evaluator.py -s 1 -x $extrapolator -e $error_bound -d $delay_bound -o evaluator_output_$category -i $id -t expected_error_offline/${category}${expected_error_table[$extrapolator]}.pkl" 
				done
			done

		done
	done
done


