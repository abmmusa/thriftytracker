


###############
# error delay
##############

for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 2; do


# plot no of tx vs MAX allowed error for various delay of error_delay sampler and also strawman
#echo "plots_new/error_delay_maxerror_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Max error (meters)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 2


set xrange [0:120]
#set yrange [0:50000]


set output "plots_new/error_delay_maxerror_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Straw man", \
'data_new/error_delay_delay0_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=0s", \
'data_new/error_delay_delay1_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=1s", \
'data_new/error_delay_delay8_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8s", \
'data_new/error_delay_delay32_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=32s",\
'data_new/error_delay_delay128_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=128s",\
'data_new/error_delay_delay256_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=256s"


set logscale y
set output "plots_new/error_delay_table_maxerror_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_delay_table_strawman_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Straw man", \
'data_new/error_delay_table_delay0_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=0s", \
'data_new/error_delay_table_delay1_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=1s", \
'data_new/error_delay_table_delay8_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8s", \
'data_new/error_delay_table_delay32_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=32s",\
'data_new/error_delay_table_delay128_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=128s",\
'data_new/error_delay_table_delay256_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=256s",\
'data_new/error_delay_table_delay512_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=512s",\
'data_new/error_delay_table_delay1024_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=1024s",\
'data_new/error_delay_table_delay2048_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=2048s",\
'data_new/error_delay_table_delay4096_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=4096s",\
'data_new/error_delay_table_delay8192_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8192s"

EOF

#echo "plots_new/error_delay_meanerror_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Mean error (meters)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 2

set xrange [0:120]
#set yrange [0:50000]


set output "plots_new/error_delay_meanerror_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_delay_strawman_${category}_extr${extrapolator}' using 2:3 with linespoint ti "Straw man", \
'data_new/error_delay_delay0_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=0s", \
'data_new/error_delay_delay1_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=1s", \
'data_new/error_delay_delay8_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=8s", \
'data_new/error_delay_delay32_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=32s", \
'data_new/error_delay_delay128_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=128s", \
'data_new/error_delay_delay256_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=256s"

set output "plots_new/error_delay_table_meanerror_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_delay_table_strawman_${category}_extr${extrapolator}' using 2:3 with linespoint ti "Straw man", \
'data_new/error_delay_table_delay0_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=0s", \
'data_new/error_delay_table_delay1_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=1s", \
'data_new/error_delay_table_delay8_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=8s", \
'data_new/error_delay_table_delay32_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=32s", \
'data_new/error_delay_table_delay128_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=128s", \
'data_new/error_delay_table_delay256_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=256s", \
'data_new/error_delay_table_delay512_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=512s", \
'data_new/error_delay_table_delay1024_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=1024s", \
'data_new/error_delay_table_delay2048_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=2048s", \
'data_new/error_delay_table_delay4096_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=4096s", \
'data_new/error_delay_table_delay8192_${category}_extr${extrapolator}' using 3:4 with linespoint ti "Delay=8192s"




EOF

# [delay vs tx-interval for various max-error]
#echo "plots_new/error_delay_delay_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Delay (sec)"
set ylabel "Data usage (byets/sec)"
set key above maxrows 2


set xrange [0:32]
#set yrange [0:20]

set output "plots_new/error_delay_delay_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_delay_error1_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=1m" ls 2, \
'data_new/error_delay_error2_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=2m" ls 3, \
'data_new/error_delay_error5_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=5m" ls 4, \
'data_new/error_delay_error10_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=10m" ls 5, \
'data_new/error_delay_error20_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=20m" ls 6, \
'data_new/error_delay_error50_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=50m" ls 7, \
'data_new/error_delay_error100_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=100m" ls 8, \
'data_new/error_delay_error500_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=500m" ls 9

set xrange [0:8200]
set logscale y
set output "plots_new/error_delay_table_delay_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_delay_table_error1_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=1m" ls 2, \
'data_new/error_delay_table_error2_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=2m" ls 3, \
'data_new/error_delay_table_error5_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=5m" ls 4, \
'data_new/error_delay_table_error10_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=10m" ls 5, \
'data_new/error_delay_table_error20_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=20m" ls 6, \
'data_new/error_delay_table_error50_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=50m" ls 7, \
'data_new/error_delay_table_error100_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=100m" ls 8, \
'data_new/error_delay_table_error500_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=500m" ls 9


EOF


	done
done




###############
# budget delay
##############
for category in "osm2" "uic" "msmls"; do
#for category in "osm" "osm2" "msmls" "msmls2" "uic" "msmls2_interpolated" "msmls_interpolated"; do
	for extrapolator in 0 1 3; do



# budget vs mean error [statistical]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2


set output "plots_new/budget_delay_statistical_maxerror_budget_${category}_extr${extrapolator}.pdf"
plot \
'data_new/budget_delay_strawman_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_new/budget_delay_statistical_maxerror_delay0_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_new/budget_delay_statistical_maxerror_delay8_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_new/budget_delay_statistical_maxerror_delay32_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=32s" ls 4

set ylabel "Max error (meters)"
set output "plots_new/budget_delay_statistical_maxerror_maxerror_budget_${category}_extr${extrapolator}.pdf"
plot \
'data_new/budget_delay_strawman_maxerror_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_new/budget_delay_statistical_maxerror_maxerror_delay0_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_new/budget_delay_statistical_maxerror_maxerror_delay8_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_new/budget_delay_statistical_maxerror_maxerror_delay32_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=32s" ls 4

EOF


# budget vs mean error [statistical]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2

#set xrange [:2]
#set yrange [:1000]

set xrange [:2]
set output "plots_new/budget_delay_statistical_maxerror_budget_${category}_extr${extrapolator}_zoomed.pdf"
plot \
'data_new/budget_delay_strawman_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_new/budget_delay_statistical_maxerror_delay0_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_new/budget_delay_statistical_maxerror_delay8_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_new/budget_delay_statistical_maxerror_delay32_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=32s" ls 4

EOF


# budget vs mean error [statistical]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2


set yrange [:500]

set output "plots_new/budget_delay_statistical_maxerror_budget_${category}_extr${extrapolator}_zoomed_y.pdf"
plot \
'data_new/budget_delay_strawman_${category}_extr${extrapolator}' using 3:2 with linespoint ti "Straw-man", \
'data_new/budget_delay_statistical_maxerror_delay0_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=0s" ls 2, \
'data_new/budget_delay_statistical_maxerror_delay8_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=8s" ls 3, \
'data_new/budget_delay_statistical_maxerror_delay32_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Delay=32s" ls 4

EOF



# budget conformance [statistical]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 2


#set xrange [0:3]


set output "plots_new/budget_delay_statistical_maxerror_conformance_budget_${category}_extr${extrapolator}.pdf"
plot \
'data_new/budget_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Straw-man" ls 1, \
'data_new/budget_delay_statistical_maxerror_delay0_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=0s" ls 2, \
'data_new/budget_delay_statistical_maxerror_delay8_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8s" ls 3, \
'data_new/budget_delay_statistical_maxerror_delay32_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=32s" ls 4, \
x with lines ti "Ideal" ls 5

EOF



# budget vs mean error reduction compared to strawman
# for delay in 0 8 32; do
# 	gawk 'ARGIND==1 {error[$1]=$3; next} error[$1] {print $1, error[$1], $2, (1-error[$1]/$2)*100}' data_new/budget_delay_statistical_delay${delay}_${category}_extr${extrapolator} data_new/budget_delay_strawman_${category}_extr${extrapolator} > /tmp/budget_delay_error_reduction_delay${delay}_${category}_extr${extrapolator}
# done
# gnuplot<<EOF
# set terminal pdf font "Helvetica,10" lw 2 dashed
# set xlabel "Budget (bytes/sec)"
# set ylabel "Error reduction (%)"
# set key above

# set output "plots_new/budget_delay_statistical_error_reduction_budget_${category}_extr${extrapolator}.pdf"

# set xrange [:10.5]
# #set yrange [:1000]


# plot '/tmp/budget_delay_error_reduction_delay0_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=0s", \
# '/tmp/budget_delay_error_reduction_delay8_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=8s", \
# '/tmp/budget_delay_error_reduction_delay32_${category}_extr${extrapolator}' using 1:4 with linespoint ti "Delay=32s"

# EOF



	done
done


###############
# error budget 
##############


# for category in "osm" "osm2" "uic" "msmls" "msmls2"; do
# 	for extrapolator in 0 1 2; do

# # budget vs avg delay for various errors 
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:6]
# #set yrange [0:600]

# set output "plots_new/error_budget_budget_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget_budget_error1_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget_budget_error2_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget_budget_error5_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget_budget_error10_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget_budget_error50_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 6, \
# 'data_new/error_budget_budget_error100_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 7, \
# 'data_new/error_budget_budget_error500_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 8



# EOF


# # budget vs avg delay for various errors (Zoomed)
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:6]
# set yrange [0:600]

# set output "plots_new/error_budget_budget_zoomed_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget_budget_error1_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget_budget_error2_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget_budget_error5_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget_budget_error10_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget_budget_error50_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 6, \
# 'data_new/error_budget_budget_error100_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 7, \
# 'data_new/error_budget_budget_error500_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 8


# EOF




# # budget USAGE vs avg delay for various errors 
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Usage (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:6]
# #set yrange [0:600]

# set output "plots_new/error_budget_budgetusage_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget_budgetusage_error1_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget_budgetusage_error3_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget_budgetusage_error5_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget_budgetusage_error10_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget_budgetusage_error50_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 6, \
# 'data_new/error_budget_budgetusage_error100_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 7, \
# 'data_new/error_budget_budgetusage_error500_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 8

# EOF


# # budget USAGE vs avg delay for various errors (Zoomed)
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Usage (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:6]
# set yrange [0:600]

# set output "plots_new/error_budget_budgetusage_zoomed_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget_budgetusage_error1_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget_budgetusage_error2_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget_budgetusage_error5_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget_budgetusage_error10_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget_budgetusage_error50_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 6, \
# 'data_new/error_budget_budgetusage_error100_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 7, \
# 'data_new/error_budget_budgetusage_error500_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 8

# EOF




# # error vs avg delay for various budget
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Max error (meters)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:250]
# #set yrange [0:600]

# set output "plots_new/error_budget_error_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget_error_budget0.125_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.125", \
# 'data_new/error_budget_error_budget0.25_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.25", \
# 'data_new/error_budget_error_budget0.5_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.5", \
# 'data_new/error_budget_error_budget1_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=1", \
# 'data_new/error_budget_error_budget2_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=2", \
# 'data_new/error_budget_error_budget4_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=4", \
# 'data_new/error_budget_error_budget8_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=8"


# EOF




# # conformance with budget for various error
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget specified (bytes/sec)"
# set ylabel "Data usage (bytes/sec)"
# set key above maxrows 2

# #set xrange [0:6]
# #set yrange [0:50000]


# set output "plots_new/error_budget_conformance_budget_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget_conformance_budget_error1_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget_conformance_budget_error2_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget_conformance_budget_error5_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget_conformance_budget_error10_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget_conformance_budget_error50_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 6, \
# 'data_new/error_budget_conformance_budget_error100_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 7, \
# 'data_new/error_budget_conformance_budget_error500_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 8, \
# x with lines ti "Ideal" ls 1

# EOF
# 	done
# done

############################################################################################

##################
# error budget 2
###################

periods="3600.0 57600.0"

for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 2; do
		for period in $periods; do

# budget vs avg delay for various errors 
#echo "plots_new/error_budget2_budget_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set xrange [0:6]
#set yrange [0:600]

set output "plots_new/error_budget2_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget2_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget2_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget2_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget2_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget2_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget2_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget2_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget2_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9


EOF


# budget vs avg delay for various errors (Zoomed)
#echo "plots_new/error_budget2_budget_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set xrange [0:6]
set yrange [0:600]

set output "plots_new/error_budget2_budget_zoomed_p${period}_${category}_extr${extrapolator}.pdf"

plot \
'data_new/error_budget2_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget2_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget2_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget2_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget2_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 6, \
'data_new/error_budget2_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget2_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget2_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9


EOF




# budget USAGE vs avg delay for various errors 
#echo "plots_new/error_budget2_budgetusage_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

set xrange [0:8]
#set yrange [0:600]

set output "plots_new/error_budget2_budgetusage_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget2_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget2_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget2_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget2_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget2_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget2_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget2_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget2_budgetusage_error500_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 9


EOF


# budget USAGE vs avg delay for various errors (Zoomed)
#echo "plots_new/error_budget2_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

set xrange [0:8]
set yrange [0:600]

set output "plots_new/error_budget2_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget2_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget2_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget2_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget2_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget2_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget2_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget2_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget2_budgetusage_error500_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 9


EOF




# error vs avg delay for various budget
#echo "plots_new/error_budget2_error_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Max error (meters)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set xrange [0:250]
#set yrange [0:600]

set output "plots_new/error_budget2_error_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget2_error_budget0.125_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.125", \
'data_new/error_budget2_error_budget0.25_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.25", \
'data_new/error_budget2_error_budget0.5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.5", \
'data_new/error_budget2_error_budget1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=1", \
'data_new/error_budget2_error_budget2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=2", \
'data_new/error_budget2_error_budget4_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=4", \
'data_new/error_budget2_error_budget8_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=8"

set yrange [0:40000]
set xlabel "Mean error (meters)"
set output "plots_new/error_budget2_meanerror_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget2_meanerror_budget0.125_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=0.125", \
'data_new/error_budget2_meanerror_budget0.25_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=0.25", \
'data_new/error_budget2_meanerror_budget0.5_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=0.5", \
'data_new/error_budget2_meanerror_budget1_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=1", \
'data_new/error_budget2_meanerror_budget2_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=2", \
'data_new/error_budget2_meanerror_budget4_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=4", \
'data_new/error_budget2_meanerror_budget8_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=8"

EOF




# conformance with budget for various error
#echo "plots_new/error_budget2_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 2

#set xrange [0:6]
#set yrange [0:50000]


set output "plots_new/error_budget2_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget2_conformance_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget2_conformance_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget2_conformance_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget2_conformance_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget2_conformance_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget2_conformance_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget2_conformance_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget2_conformance_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9, \
x with lines ti "Ideal" ls 1


EOF

		done
	done
done




############################################################################################

# ##################
# # error budget 2
# ###################

# periods="3600.0 57600.0"

# for category in "osm2" "uic" "msmls"; do
# 	for extrapolator in 0 1 2; do
# 		for period in $periods; do

# # budget vs avg delay for various errors 
# #echo "plots_new/error_budget2_budget_p${period}_${category}_extr${extrapolator}.pdf"
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:6]
# #set yrange [0:600]

# set output "plots_new/error_budget2_budget_p${period}_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget2_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget2_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget2_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget2_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget2_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
# 'data_new/error_budget2_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
# 'data_new/error_budget2_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
# 'data_new/error_budget2_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9


# EOF


# # budget vs avg delay for various errors (Zoomed)
# #echo "plots_new/error_budget2_budget_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:6]
# set yrange [0:600]

# set output "plots_new/error_budget2_budget_zoomed_p${period}_${category}_extr${extrapolator}.pdf"

# plot \
# 'data_new/error_budget2_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget2_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget2_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget2_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget2_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 6, \
# 'data_new/error_budget2_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
# 'data_new/error_budget2_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
# 'data_new/error_budget2_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9


# EOF




# # budget USAGE vs avg delay for various errors 
# #echo "plots_new/error_budget2_budgetusage_p${period}_${category}_extr${extrapolator}.pdf"
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Usage (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# set xrange [0:8]
# #set yrange [0:600]

# set output "plots_new/error_budget2_budgetusage_p${period}_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget2_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget2_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget2_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget2_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget2_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
# 'data_new/error_budget2_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
# 'data_new/error_budget2_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8, \
# 'data_new/error_budget2_budgetusage_error500_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 9


# EOF


# # budget USAGE vs avg delay for various errors (Zoomed)
# #echo "plots_new/error_budget2_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Usage (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# set xrange [0:8]
# set yrange [0:600]

# set output "plots_new/error_budget2_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget2_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget2_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget2_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget2_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget2_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
# 'data_new/error_budget2_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
# 'data_new/error_budget2_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8, \
# 'data_new/error_budget2_budgetusage_error500_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 9


# EOF




# # error vs avg delay for various budget
# #echo "plots_new/error_budget2_error_p${period}_${category}_extr${extrapolator}.pdf"
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Max error (meters)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# #set xrange [0:250]
# #set yrange [0:600]

# set output "plots_new/error_budget2_error_p${period}_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget2_error_budget0.125_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.125", \
# 'data_new/error_budget2_error_budget0.25_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.25", \
# 'data_new/error_budget2_error_budget0.5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.5", \
# 'data_new/error_budget2_error_budget1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=1", \
# 'data_new/error_budget2_error_budget2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=2", \
# 'data_new/error_budget2_error_budget4_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=4", \
# 'data_new/error_budget2_error_budget8_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=8"

# set yrange [0:40000]
# set xlabel "Mean error (meters)"
# set output "plots_new/error_budget2_meanerror_p${period}_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget2_meanerror_budget0.125_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=0.125", \
# 'data_new/error_budget2_meanerror_budget0.25_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=0.25", \
# 'data_new/error_budget2_meanerror_budget0.5_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=0.5", \
# 'data_new/error_budget2_meanerror_budget1_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=1", \
# 'data_new/error_budget2_meanerror_budget2_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=2", \
# 'data_new/error_budget2_meanerror_budget4_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=4", \
# 'data_new/error_budget2_meanerror_budget8_p${period}_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Budget=8"

# EOF




# # conformance with budget for various error
# #echo "plots_new/error_budget2_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget specified (bytes/sec)"
# set ylabel "Data usage (bytes/sec)"
# set key above maxrows 2

# #set xrange [0:6]
# #set yrange [0:50000]


# set output "plots_new/error_budget2_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
# plot \
# 'data_new/error_budget2_conformance_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_budget2_conformance_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_budget2_conformance_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_budget2_conformance_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_budget2_conformance_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
# 'data_new/error_budget2_conformance_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
# 'data_new/error_budget2_conformance_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
# 'data_new/error_budget2_conformance_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9, \
# x with lines ti "Ideal" ls 1


# EOF

# 		done
# 	done
# done






############################################################################################

##################
# error budget 3
###################

periods="600.0 1800.0 3600.0 57600.0"

for category in "osm2" "uic" "msmls"; do
	for extrapolator in 0 1 2; do
		for period in $periods; do

# budget vs avg delay for various errors 
#echo "plots_new/error_budget3_budget_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set xrange [0:6]
#set yrange [0:600]

set output "plots_new/error_budget3_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget3_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget3_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget3_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget3_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget3_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget3_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget3_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9


EOF


# budget vs avg delay for various errors (Zoomed)
#echo "plots_new/error_budget3_budget_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set xrange [0:6]
set yrange [0:600]

set output "plots_new/error_budget3_budget_zoomed_p${period}_${category}_extr${extrapolator}.pdf"

plot \
'data_new/error_budget3_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget3_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget3_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget3_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget3_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 6, \
'data_new/error_budget3_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget3_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget3_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9


EOF




# budget USAGE vs avg delay for various errors 
#echo "plots_new/error_budget3_budgetusage_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

set xrange [0:8]
#set yrange [0:600]

set output "plots_new/error_budget3_budgetusage_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget3_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget3_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget3_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget3_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget3_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget3_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget3_budgetusage_error500_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 9


EOF


# budget USAGE vs avg delay for various errors (Zoomed)
#echo "plots_new/error_budget3_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Usage (bytes/sec)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

set xrange [0:8]
set yrange [0:600]

set output "plots_new/error_budget3_budgetusage_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_budgetusage_error1_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget3_budgetusage_error2_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget3_budgetusage_error5_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget3_budgetusage_error10_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget3_budgetusage_error20_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget3_budgetusage_error50_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget3_budgetusage_error100_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget3_budgetusage_error500_p${period}_${category}_extr${extrapolator}' using 4:3 with linespoint ti "Error=500m" ls 9


EOF



# error vs avg delay for various budget
#echo "plots_new/error_budget3_error_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Max error (meters)"
set ylabel "Mean delay (sec)"
set key above maxrows 2

#set xrange [0:250]
#set yrange [0:600]

set output "plots_new/error_budget3_error_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_error_budget0.125_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.125", \
'data_new/error_budget3_error_budget0.25_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.25", \
'data_new/error_budget3_error_budget0.5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.5", \
'data_new/error_budget3_error_budget1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=1", \
'data_new/error_budget3_error_budget2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=2", \
'data_new/error_budget3_error_budget4_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=4", \
'data_new/error_budget3_error_budget8_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=8"

set xlabel "Mean error (meters)"
set output "plots_new/error_budget3_meanerror_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_meanerror_budget0.125_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=0.125", \
'data_new/error_budget3_meanerror_budget0.25_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=0.25", \
'data_new/error_budget3_meanerror_budget0.5_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=0.5", \
'data_new/error_budget3_meanerror_budget1_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=1", \
'data_new/error_budget3_meanerror_budget2_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=2", \
'data_new/error_budget3_meanerror_budget4_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=4", \
'data_new/error_budget3_meanerror_budget8_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=8"


set yrange [0:1000]
set output "plots_new/error_budget3_error_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_error_budget0.125_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.125", \
'data_new/error_budget3_error_budget0.25_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.25", \
'data_new/error_budget3_error_budget0.5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=0.5", \
'data_new/error_budget3_error_budget1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=1", \
'data_new/error_budget3_error_budget2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=2", \
'data_new/error_budget3_error_budget4_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=4", \
'data_new/error_budget3_error_budget8_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Budget=8"

set yrange [0:1000]
set xlabel "Mean error (meters)"
set output "plots_new/error_budget3_meanerror_zoomed_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_meanerror_budget0.125_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=0.125", \
'data_new/error_budget3_meanerror_budget0.25_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=0.25", \
'data_new/error_budget3_meanerror_budget0.5_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=0.5", \
'data_new/error_budget3_meanerror_budget1_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=1", \
'data_new/error_budget3_meanerror_budget2_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=2", \
'data_new/error_budget3_meanerror_budget4_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=4", \
'data_new/error_budget3_meanerror_budget8_p${period}_${category}_extr${extrapolator}' using 2:5 with linespoint ti "Budget=8"


EOF




# conformance with budget for various error
#echo "plots_new/error_budget3_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 2

#set xrange [0:6]
#set yrange [0:50000]


set output "plots_new/error_budget3_conformance_budget_p${period}_${category}_extr${extrapolator}.pdf"
plot \
'data_new/error_budget3_conformance_budget_error1_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=1m" ls 2, \
'data_new/error_budget3_conformance_budget_error2_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=2m" ls 3, \
'data_new/error_budget3_conformance_budget_error5_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=5m" ls 4, \
'data_new/error_budget3_conformance_budget_error10_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=10m" ls 5, \
'data_new/error_budget3_conformance_budget_error20_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=20m" ls 6, \
'data_new/error_budget3_conformance_budget_error50_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=50m" ls 7, \
'data_new/error_budget3_conformance_budget_error100_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=100m" ls 8, \
'data_new/error_budget3_conformance_budget_error500_p${period}_${category}_extr${extrapolator}' using 1:3 with linespoint ti "Error=500m" ls 9, \
x with lines ti "Ideal" ls 1


EOF

		done
	done
done







############################################################################################

#
# plots specific for paper
#

# #############
# # Budget delay
# ##############
# gnuplot<<EOF
# set terminal pdf font "Helvetica,10" lw 2 dashed
# set xlabel "Budget (bytes/sec)"
# set ylabel "Mean error (meters)"
# set key above

# set output "plots_new/budget_delay_budget_osm_extr0_zoomed.pdf"

# set yrange [0:20]



# plot \
# 'data_new/budget_delay_strawman_osm_extr0' using 1:2 with linespoint ti "Straw man S", \
# 'data_new/budget_delay_delay0_osm_extr0' using 1:3 with linespoint ti "Delay=0s", \
# 'data_new/budget_delay_delay8_osm_extr0' using 1:3 with linespoint ti "Delay=8s", \
# 'data_new/budget_delay_delay32_osm_extr0' using 1:3 with linespoint ti "Delay=32s", \
# 'data_new/budget_delay_delay128_osm_extr0' using 1:3 with linespoint ti "Delay=128s", \
# 'data_new/budget_delay_delay256_osm_extr0' using 1:3 with linespoint ti "Delay=256s", \
# 'data_new/budget_delay_strawman_window_osm_extr0' using 1:2 with linespoint ti "Straw man W"

# EOF



