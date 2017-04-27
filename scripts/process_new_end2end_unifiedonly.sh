#!/bin/bash

periods="1800.0 3600.0"

####################
# error delay
####################

for category in "uic" "msmls"; do
	echo "data straw-man,const-loc Delay=0 Delay=8 Delay=16 Delay=32 Delay=64 Delay=128" > data_new/error_delay_${category}_end2end_unifiedonly
	for maxerror in 1 2 5 10 20 50 100; do
		values=""
		for extrapolator in 0; do
			val=`cat data_new/error_delay_strawman_${category}_extr${extrapolator} | awk '$1==e {print $3}' e=$maxerror`
			values=$values" "$val
		done

		for delay in 0 8 16 32 64 128; do
			for extrapolator in 2; do
				val=`cat data_new/error_delay_delay${delay}_${category}_extr${extrapolator} | awk '$1==e {print $4}' e=$maxerror`
				values=$values" "$val
			done
		done

		echo $maxerror $values
	done  >> data_new/error_delay_${category}_end2end_unifiedonly

	cat data_new/error_delay_${category}_end2end_unifiedonly | \
		awk 'NR==1 {print $0} NR>1 {printf "%d ", $1;for(i=2; i<=NF; i++) {printf "%.2f ", ($i/$2)*100}; printf "\n"}' > data_new/error_delay_percentage_${category}_end2end_unifiedonly
	
	cat data_new/error_delay_percentage_${category}_end2end_unifiedonly | awk 'NR==1 {print $0} NR>1 {print $1, $2, $2-$3, $2-$4, $2-$5, $2-$6, $2-$7, $2-$8}' > data_new/error_delay_percentage_reduction_${category}_end2end_unifiedonly


done



####################
# budget delay
####################
for category in "uic" "msmls"; do
	for period in $periods; do

		echo "data straw-man,const-loc Delay=0 Delay=8 Delay=16 Delay=32 Delay=64 Delay=128" > data_new/budget_delay_p${period}_${category}_end2end_unifiedonly

		for budget in 0.25 0.5 1 2 4 8; do # this is budget specified
			values=""
			for extrapolator in 0; do
				val=`cat data_new/budget_delay_strawman_${category}_extr${extrapolator} | awk '$1==b {print $2}' b=$budget`
				values=$values" "$val
			done
	
			for delay in 0 8 16 32 64 128; do
				for extrapolator in 3; do
					val=`cat data_new/budget_delay_statistical_maxerror_delay${delay}_p${period}_${category}_extr${extrapolator} | awk '$1==b {print $3}' b=$budget`
					values=$values" "$val
				done
			done

			echo $budget $values #| awk '{printf "%.02f %f %f %f %f %f %f %f %f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}'
		done  >> data_new/budget_delay_p${period}_${category}_end2end_unifiedonly

        # produce the percentage numbers compared to the straw-man
		cat data_new/budget_delay_p${period}_${category}_end2end_unifiedonly | \
			awk 'NR==1 {print $0} NR>1 {printf "%0.2f ", $1; for(i=2; i<=NF; i++) {printf "%.2f ", ($i/$2)*100}; printf "\n"}' > data_new/budget_delay_percentage_p${period}_${category}_end2end_unifiedonly

		cat data_new/budget_delay_percentage_p${period}_${category}_end2end_unifiedonly | awk 'NR==1 {print $0} NR>1 {print $1, $2, $2-$3, $2-$4, $2-$5, $2-$6, $2-$7, $2-$8}' > data_new/budget_delay_percentage_reduction_p${period}_${category}_end2end_unifiedonly
	done
done




