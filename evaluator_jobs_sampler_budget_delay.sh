#!/bin/bash


budget_bounds="5 10 15 20 30 60 90 120 200 300 450 600"
delay_bounds_budget[5]="2 3"
delay_bounds_budget[10]="2 3 5"
delay_bounds_budget[15]="2 3 5 10"
delay_bounds_budget[20]="2 3 5 10 15"
delay_bounds_budget[30]="2 5 10 15 20 25"
delay_bounds_budget[60]="2 5 10 20 30 50"
delay_bounds_budget[90]="2 5 10 20 30 50 70"
delay_bounds_budget[120]="2 5 10 20 30 50 70 90 100"
delay_bounds_budget[300]="2 5 10 50 100 150 200 250"
delay_bounds_budget[450]="2 5 10 50 100 150 200 250 350"
delay_bounds_budget[600]="2 5 10 50 100 200 300 350 400"

expected_error_table[0]=""
expected_error_table[1]="_const_vel"


#for category in "osm" "uic" "msmls"; do
#	for extrapolator in 0 1; do
for category in "osm"; do
	for extrapolator in 0; do
		trace_dir="traces/$category"
		#trace_files=`ls $trace_dir`
		trace_files="14569.txt.gz"

        # straw-man 
		for file in $trace_files; do
			id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
	
			for budget_bound in $budget_bounds; do
				echo "gunzip -c $trace_dir/$file | python evaluator.py -s 4 -x $extrapolator -b $budget_bound -o evaluator_output_$category -i $id" 
			done
		done

        # budget-delay bound sampler
		for file in $trace_files; do
			id=`echo $file | awk -F_ '{print $NF}' | sed "s/.txt.gz//"`
			
			for budget_bound in $budget_bounds; do
				delay_bounds=${delay_bounds_budget[$budget_bound]}
		
				for delay_bound in $delay_bounds; do
					echo "gunzip -c $trace_dir/$file | python evaluator.py -s 2 -x $extrapolator -b $budget_bound -d $delay_bound -o evaluator_output_$category -i $id -t expected_meanerror_offline/${category}${expected_error_table[$extrapolator]}.pkl" 
				done
			done
		done

	done
done

