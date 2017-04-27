

periods="1800.0 3600.0"

###############
# error delay
##############

for category in "osm2"; do
	for extrapolator in 0; do


# plot no of tx vs MAX allowed error for various delay of error_delay sampler and also strawman
#echo "plots_new/error_delay_maxerror_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Maximum error (meters)"
set ylabel "Usage (bytes/sec)"
set key above maxrows 2


set xrange [0:120]
#set yrange [0:50000]


set output "plots_osm2_test/error_delay_maxerror_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/error_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Straw man" ls 1, \
'data_osm2_test/error_delay_delay0_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=0s" ls 2, \
'data_osm2_test/error_delay_delay1_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=1s" ls 8, \
'data_osm2_test/error_delay_delay8_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8s" ls 3, \
'data_osm2_test/error_delay_delay64_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=64s" ls 6,\
'data_osm2_test/error_delay_delay128_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=128s" ls 7



EOF




gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Delay (sec)"
set ylabel "Usage (byets/sec)"
set key above maxrows 2


#set xrange [0:32]
#set yrange [0:20]

set output "plots_osm2_test/error_delay_delay_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/error_delay_error1_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=1m" ls 2, \
'data_osm2_test/error_delay_error2_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=2m" ls 3, \
'data_osm2_test/error_delay_error5_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=5m" ls 4, \
'data_osm2_test/error_delay_error10_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=10m" ls 5, \
'data_osm2_test/error_delay_error20_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=20m" ls 6, \
'data_osm2_test/error_delay_error50_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=50m" ls 7, \
'data_osm2_test/error_delay_error100_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=100m" ls 8

EOF


	done
done


###############
# budget delay
##############
for category in "osm2" ; do
	for extrapolator in 0; do
		for period in "1800.0" "3600.0" "57600.0"; do
			for id in 12 13; do

# budget vs mean error [statistical]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2


set output "plots_osm2_test/budget_delay_statistical_maxerror${id}_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/budget_delay_strawman_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay0_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay8_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay64_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=64s" ls 6, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay128_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=128s" ls 7


EOF


# budget vs mean error [statistical] (zoomed)
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2

#set xrange [:2]
#set yrange [:1000]

set xrange [:2]
set output "plots_osm2_test/budget_delay_statistical_maxerror${id}_budget_p${period}_${category}_extr${extrapolator}_zoomed.pdf"
plot \
'data_osm2_test/budget_delay_strawman_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay0_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay8_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay64_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=64s" ls 6, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay128_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=128s" ls 7


EOF


# budget vs mean error [statistical] (zoomed y)
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2


set yrange [:50]

set output "plots_osm2_test/budget_delay_statistical_maxerror${id}_budget_p${period}_${category}_extr${extrapolator}_zoomed_y.pdf"
plot \
'data_osm2_test/budget_delay_strawman_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay0_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay8_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay64_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=64s" ls 6, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay128_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=128s" ls 7

EOF



# budget conformance [statistical]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Usage (bytes/sec)"
set key above maxrows 2


#set xrange [0:3]


set output "plots_osm2_test/budget_delay_statistical_maxerror${id}_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/budget_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Straw-man" ls 1, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay0_p${period}_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=0s" ls 2, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay8_p${period}_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8s" ls 3, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay64_p${period}_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=64s" ls 6, \
'data_osm2_test/budget_delay_statistical_maxerror${id}_delay128_p${period}_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=128s" ls 7, \
x with lines ti "Ideal" ls 8

EOF

			done
		done
	done
done



##################
# error budget 3
###################
for category in "osm2"; do
	for extrapolator in 0; do
		for period in $periods; do

# budget USAGE vs avg delay for various errors (Zoomed)
#echo "plots_osm2_test/error_budget3_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

set xrange [0:8]
#set yrange [0:600]

set output "plots_osm2_test/error_budget3_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/error_budget3_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
'data_osm2_test/error_budget3_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
'data_osm2_test/error_budget3_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
'data_osm2_test/error_budget3_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
'data_osm2_test/error_budget3_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
'data_osm2_test/error_budget3_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
'data_osm2_test/error_budget3_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8


EOF




# error vs avg delay for various budget
#echo "plots_osm2_test/error_budget3_error_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Maximum error (meters)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set yrange [0:1000]
set output "plots_osm2_test/error_budget3_error_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/error_budget3_error_budget0.25_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.25", \
'data_osm2_test/error_budget3_error_budget0.5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.5", \
'data_osm2_test/error_budget3_error_budget2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=2", \
'data_osm2_test/error_budget3_error_budget4_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=4", \
'data_osm2_test/error_budget3_error_budget8_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=8"




EOF


# conformance with budget for various error
#echo "plots_osm2_test/error_budget3_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Usage (bytes/sec)"
set key above maxrows 2

#set xrange [0:6]
#set yrange [0:50000]


set output "plots_osm2_test/error_budget3_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_osm2_test/error_budget3_conformance_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_osm2_test/error_budget3_conformance_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_osm2_test/error_budget3_conformance_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_osm2_test/error_budget3_conformance_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_osm2_test/error_budget3_conformance_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
'data_osm2_test/error_budget3_conformance_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_osm2_test/error_budget3_conformance_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
x with lines ti "Ideal" ls 1


EOF

		done
	done
done

