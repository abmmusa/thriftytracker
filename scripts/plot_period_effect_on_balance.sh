#!/bin/bash


budget_bounds="0.25 0.5 1 2" #bytes/sec
delay_bounds="0 8 16 32"
periods="900.0 1800.0 3600.0 7200.0 14400.0 57600.0 230400.0"

### NOTE: uncomment if data doesn't exist

# for category in "osm2"; do
# 	for extrapolator in 0; do
# 		for id in 16; do
# 			for budget in $budget_bounds; do
# 				for delay in $delay_bounds; do
# 					for period in $periods; do

# 						cat period_effect_on_balance/balance_b${budget}_d${delay}_p${period}_${category}_extr${extrapolator}_i${id}.txt | awk '{print NR, $1, $2}' | awk '{print $1/3600, $2, $3}' > /tmp/balance_b${budget}_d${delay}_p${period}_${category}_extr${extrapolator}_i${id}.txt


# 					done
# 				done
# 			done
# 		done
# 	done
# done


budget_bounds="0.25 0.5 1 2" #bytes/sec
delay_bounds="0 8 16 32"		

for category in "osm2"; do
	for extrapolator in 0; do
		for id in 16; do
			for budget in $budget_bounds; do
				for delay in $delay_bounds; do

gnuplot<<EOF
#set terminal pdf font "Helvetica,12" lw 2 dashed
set terminal postscript eps color enhanced "Helvetica" 35 lw 2 dashed size 7,4
set xlabel "Time (hours)"
set ylabel "{Balance (bytes)}" 
set key above vertical maxrows 2 samplen -1

#set size ratio 0.4
#set size nosquare

set xrange [0:10]
#set yrange [0:600]

#set xtics 50000


set output "plots_period_effect/balance_period_effect_b${budget}_d${delay}_${category}_extr${extrapolator}_i${id}.eps"
plot \
'/tmp/balance_b${budget}_d${delay}_p900.0_${category}_extr${extrapolator}_i${id}.txt' using 1:2 with lines ti "Period=15 minutes", \
'/tmp/balance_b${budget}_d${delay}_p1800.0_${category}_extr${extrapolator}_i${id}.txt' using 1:2 with lines ti "Period=30 minutes", \
'/tmp/balance_b${budget}_d${delay}_p3600.0_${category}_extr${extrapolator}_i${id}.txt' using 1:2 with lines ti "Period=1 hour", \
'/tmp/balance_b${budget}_d${delay}_p7200.0_${category}_extr${extrapolator}_i${id}.txt' using 1:2 with lines ti "Period=2 hours", \
'/tmp/balance_b${budget}_d${delay}_p14400.0_${category}_extr${extrapolator}_i${id}.txt' using 1:2 with lines ti "Period=4 hours"

set ylabel "{/Symbol b}" rotate by -0
#set ylabel "Factor"

set output "plots_period_effect/factor_period_effect_b${budget}_d${delay}_${category}_extr${extrapolator}_i${id}.eps"
plot \
'/tmp/balance_b${budget}_d${delay}_p900.0_${category}_extr${extrapolator}_i${id}.txt' using 1:3 with lines ti "{/Symbol P}=15 minutes", \
'/tmp/balance_b${budget}_d${delay}_p1800.0_${category}_extr${extrapolator}_i${id}.txt' using 1:3 with lines ti "{/Symbol P}=30 minutes", \
'/tmp/balance_b${budget}_d${delay}_p3600.0_${category}_extr${extrapolator}_i${id}.txt' using 1:3 with lines ti "{/Symbol P}=1 hour", \
'/tmp/balance_b${budget}_d${delay}_p7200.0_${category}_extr${extrapolator}_i${id}.txt' using 1:3 with lines ti "{/Symbol P}=2 hours", \
'/tmp/balance_b${budget}_d${delay}_p14400.0_${category}_extr${extrapolator}_i${id}.txt' using 1:3 with lines ti "{/Symbol P}=4 hours"


EOF


epstopdf plots_period_effect/factor_period_effect_b${budget}_d${delay}_osm2_extr${extrapolator}_i${id}.eps

				done
			done
		done
	done
done




#epstopdf plots_period_effect/factor_period_effect_b0.25_d16_osm2_extr0_i${id}.eps

# eps_files=`ls plots_period_effect/*.eps | sed 's/plots_period_effect\///g; s/.eps//g'`

# for file in $eps_files; do
#     epstopdf plots_period_effect/${file}.eps 
# done




