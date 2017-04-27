#!/bin/bash

periods="1800.0 3600.0"

####################
# error delay
####################
for category in "msmls"; do
	echo "data straw-man,const-loc straw-man,unified delay=0,const-loc Delay=0 delay=8,const-loc Delay=8 delay=16,const-loc Delay=16 delay=32,const-loc Delay=32 delay=64,const-loc Delay=64 delay=128,const-loc Delay=128 delay=256,const-loc Delay=256" > data_new/error_delay_${category}_end2end
	for maxerror in 1 2 5 10 20 50 100; do
		values=""
		for extrapolator in 0 2; do
			val=`cat data_new/error_delay_strawman_${category}_extr$extrapolator | awk '$1==e {print $3}' e=$maxerror`
			values=$values" "$val
		done

		for delay in 0 8 16 32 64 128; do
			for extrapolator in 0 2; do
				val=`cat data_new/error_delay_delay${delay}_${category}_extr$extrapolator | awk '$1==e {print $4}' e=$maxerror`
				values=$values" "$val
			done
		done

		echo $maxerror $values
	done  >> data_new/error_delay_${category}_end2end

	cat data_new/error_delay_${category}_end2end | \
		awk 'NR==1 {print $0} NR>1 {printf "%d ", $1;for(i=2; i<=NF; i++) {printf "%.2f ", ($i/$2)*100}; printf "\n"}' > data_new/error_delay_percentage_${category}_end2end
	
	cat data_new/error_delay_percentage_${category}_end2end | awk 'NR==1 {print $1, $5, $7, $9, $11, $13, $15} NR>1 {print $1, $2-$5, $2-$7, $2-$9, $2-$11, $2-$13, $2-$15}' > data_new/error_delay_percentage_reduction_${category}_end2end


done



####################
# budget delay
####################
for category in "msmls"; do
	for period in $periods; do
		echo "data straw-man,const-loc straw-man,unified delay=0,const-loc Delay=0 delay=8,const-loc Delay=8 delay=16,const-loc Delay=16 delay=32,const-loc Delay=32 delay=64,const-loc Delay=64 delay=128,const-loc Delay=128" > data_new/budget_delay_p${period}_${category}_end2end

		for budget in 0.25 0.5 1 2 4 8; do # this is budget specified
			values=""
			for extrapolator in 0 3; do
				val=`cat data_new/budget_delay_strawman_${category}_extr$extrapolator | awk '$1==b {print $2}' b=$budget`
				values=$values" "$val
			done
			
			for delay in 0 8 16 32 64 128; do
				for extrapolator in 0 3; do
					val=`cat data_new/budget_delay_statistical_maxerror_delay${delay}_p${period}_${category}_extr$extrapolator | awk '$1==b {print $3}' b=$budget`
					values=$values" "$val
				done
			done

			echo $budget $values #| awk '{printf "%.02f %f %f %f %f %f %f %f %f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}'
		done  >> data_new/budget_delay_p${period}_${category}_end2end

    # produce the percentage numbers compared to the straw-man
		cat data_new/budget_delay_p${period}_${category}_end2end | \
			awk 'NR==1 {print $0} NR>1 {printf "%0.2f ", $1; for(i=2; i<=NF; i++) {printf "%.2f ", ($i/$2)*100}; printf "\n"}' > data_new/budget_delay_percentage_p${period}_${category}_end2end


		cat data_new/budget_delay_percentage_p${period}_${category}_end2end | awk 'NR==1 {print $1, $5, $7, $9, $11, $13, $15} NR>1 {print $1, $2-$5, $2-$7, $2-$9, $2-$11, $2-$13, $2-$15}' > data_new/budget_delay_percentage_reduction_p${period}_${category}_end2end

	done
done




####################
# error budget
####################
# for max error
for category in "msmls"; do
	for period in $periods; do

		echo "data budget=0.25,const-loc Budget=0.25 budget=0.5,const-loc Budget=0.5 budget=1,const-loc Budget=1 budget=2,const-loc Budget=2 budget=4,const-loc Budget=4 budget=8,const-loc Budget=8" > data_new/error_budget_error_${category}_end2end
		for maxerror in 1 2 5 10 20 50 100; do
			values=""
			for budget in 0.25 0.5 1 2 4 8; do
				for extrapolator in 0 2; do
					val=`cat data_new/error_budget3_budget_error${maxerror}_p${period}_${category}_extr$extrapolator | awk '$1==b {printf "%.2f", $3}' b=$budget`
					values=$values" "$val
				done
			done

			echo $maxerror $values
		done >> data_new/error_budget_error_p${period}_${category}_end2end

	done
done


# for budget
for category in "msmls"; do
	echo "data error=1,const-loc Error=1 error=2,const-loc Error=2 error=5,const-loc Error=5 error=10,const-loc Error=10 error=20,const-loc Error=20 error=50,const-loc Error=50 error=100,const-loc Error=100" > data_new/error_budget_budget_${category}_end2end
	for budget in 0.25 0.5 1 2 4 8; do # this is budget specified
		values=""
		for maxerror in 1 2 5 10 20 50 100; do
			for extrapolator in 0 2; do
				val=`cat data_new/error_budget3_error_budget${budget}_p3600.0_${category}_extr$extrapolator | awk '$1==e {printf "%.2f", $3}' e=$maxerror`
				values=$values" "$val
			done
		done

		echo $budget $values
	done  >> data_new/error_budget_budget_${category}_end2end
done


