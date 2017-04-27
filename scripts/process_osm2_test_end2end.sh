#!/bin/bash


####################
# budget delay
####################
periods="1800.0 3600.0"

for category in "osm2"; do
	for period in $periods; do
		for id in 12 13; do

			echo "data straw-man,const-loc straw-man,unified delay=0,const-loc Delay=0 delay=8,const-loc Delay=8 delay=64,const-loc Delay=64 delay=128,const-loc Delay=128" > data_osm2_test/budget_delay_${id}_p${period}_${category}_end2end
			for budget in 0.25 0.5 2 4 8; do # this is budget specified
				values=""
				for extrapolator in 0 3; do
					val=`cat data_new/budget_delay_strawman_${category}_extr$extrapolator | awk '$1==b {print $2}' b=$budget`
					values=$values" "$val
				done
				
				for delay in 0 8 64 128; do
					for extrapolator in 0 3; do
						val=`cat data_osm2_test/budget_delay_statistical_maxerror${id}_delay${delay}_p${period}_${category}_extr$extrapolator | awk '$1==b {print $3}' b=$budget`
						values=$values" "$val
					done
				done

				echo $budget $values #| awk '{printf "%.02f %f %f %f %f %f %f %f %f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}'
			done  >> data_osm2_test/budget_delay_${id}_p${period}_${category}_end2end

        # produce the percentage numbers compared to the straw-man
			cat data_osm2_test/budget_delay_${id}_p${period}_${category}_end2end | \
				awk 'NR==1 {print $0} NR>1 {printf "%0.2f ", $1; for(i=2; i<=NF; i++) {printf "%.2f ", ($i/$2)*100}; printf "\n"}' > data_osm2_test/budget_delay_percentage_${id}_p${period}_${category}_end2end
			

			cat data_osm2_test/budget_delay_percentage_${id}_p${period}_${category}_end2end | awk 'NR==1 {print $1, $5, $7, $9, $11, $13, $15} NR>1 {print $1, $2-$5, $2-$7, $2-$9, $2-$11, $2-$13, $2-$15}' > data_osm2_test/budget_delay_percentage_reduction_${id}_p${period}_${category}_end2end

		done
	done
done

