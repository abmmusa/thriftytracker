#!/bin/bash

########################################################################################
# IMPORTANT: Enable PRINT_PERIOD_VALUES flag in the sampler_new.py to get these values #
########################################################################################


budget_bounds="0.25 0.5 1 2" #bytes/sec
delay_bounds="0 8 16 32"

periods="900.0 1800.0 3600.0 7200.0 14400.0 57600.0 230400.0"

for category in "osm2"; do
	for extrapolator in 0; do
		for id in 16; do
			for budget_bound in $budget_bounds; do
 				for delay_bound in $delay_bounds; do
					for period in $periods; do
						echo "gunzip -c traces/osm2/osm2_subject_${id}.txt.gz | python -W ignore evaluator_new.py -s 13 -x $extrapolator -b $budget_bound -d $delay_bound -r $period -o evaluator_output_periodeffect_on_balance_p${period}_${category}_new -i $id -t offline_extrapolator_compressor_table/data/osm2_d${delay_bound}_x${extrapolator}.txt > period_effect_on_balance/balance_b${budget_bound}_d${delay_bound}_p${period}_${category}_extr${extrapolator}_i${id}.txt"
						
					done
				done
			done

		done
	done
done

