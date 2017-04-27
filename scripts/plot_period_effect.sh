#!/bin/bash



for error in 1 10 100 500; do
	for budget in 0.5 1.0 2.0 4.0 8.0; do
		for period in 600.0 1800.0 3600.0 14400.0 57600.0 230400.0; do
			#cat period_effect/delays_p${period}_osm2_new/delays_s20_x0_e${error}_b${budget}_d30_i16.txt | awk '$1>0 {print}' > /tmp/delays_s20_x0_e${error}_b${budget}_p${period}_d30_i16.txt
			cat period_effect/delays_p${period}_osm2_new/delays_s21_x0_e${error}_b${budget}_d30_i16.txt | awk '$1>0 {print}' | awk '{print NR, $1}' | awk '{print $1/3600, $2}' > /tmp/delays_s21_x0_e${error}_b${budget}_p${period}_d30_i16.txt
		done

		
		gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Time (hours)"
set ylabel "Delay (sec)"
set key above maxrows 2

set xrange [0:52]
#set yrange [0:600]

#set xtics 50000

# set output "plots_new/error_budget2_period_effect_e${error}_b${budget}_osm2_extr0.pdf"
# plot \
# '/tmp/delays_s20_x0_e${error}_b${budget}_p3600.0_d30_i16.txt' using 1 with lines ti "period=3600s", \
# '/tmp/delays_s20_x0_e${error}_b${budget}_p14400.0_d30_i16.txt' using 1 with lines ti "period=14400s", \
# '/tmp/delays_s20_x0_e${error}_b${budget}_p57600.0_d30_i16.txt' using 1 with lines ti "period=57600s", \
# '/tmp/delays_s20_x0_e${error}_b${budget}_p230400.0_d30_i16.txt' using 1 with lines ti "period=230400s"



set output "plots_new/error_budget3_period_effect_e${error}_b${budget}_osm2_extr0.pdf"
plot \
'/tmp/delays_s21_x0_e${error}_b${budget}_p3600.0_d30_i16.txt' using 1:2 with lines ti "period=1 hour", \
'/tmp/delays_s21_x0_e${error}_b${budget}_p14400.0_d30_i16.txt' using 1:2 with lines ti "period=4 hours", \
'/tmp/delays_s21_x0_e${error}_b${budget}_p57600.0_d30_i16.txt' using 1:2 with lines ti "period=16 hours",\
'/tmp/delays_s21_x0_e${error}_b${budget}_p230400.0_d30_i16.txt' using 1:2 with lines ti "period=64 hours"




EOF
	done
done


