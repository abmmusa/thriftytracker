
#for category in "osm" "osm2" "msmls" "uic"; do
#	for extrapolator in 0 1; do
for category in "osm"; do
	for extrapolator in 0; do


###############
# error delay
##############


# plot no of tx vs MAX allowed error for various delay of error_delay sampler and also strawman
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Max error (m)"
set ylabel "Mean Tx interval (s)"
set key above

set output "plots/error_delay_maxerror_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data/error_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Straw-man", \
'data/error_delay_delay0_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=0s", \
'data/error_delay_delay5_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=5s", \
'data/error_delay_delay10_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=10s", \
'data/error_delay_delay15_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=15s", \
'data/error_delay_delay20_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=20s", \
'data/error_delay_delay30_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=30s", \
'data/error_delay_delay60_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=60s", \
'data/error_delay_delay120_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=120s", \
'data/error_delay_delay300_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=300s"

EOF


gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Mean error (m)"
set ylabel "Mean Tx interval (s)"
set key above

set output "plots/error_delay_meanerror_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data/error_delay_strawman_${category}_extr${extrapolator}' using 2:3 with linespoints ti "Straw-man", \
'data/error_delay_delay0_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=0s", \
'data/error_delay_delay5_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=5s", \
'data/error_delay_delay10_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=10s", \
'data/error_delay_delay15_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=15s", \
'data/error_delay_delay20_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=20s", \
'data/error_delay_delay30_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=30s", \
'data/error_delay_delay60_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=60s", \
'data/error_delay_delay120_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=120s", \
'data/error_delay_delay300_${category}_extr${extrapolator}' using 3:4 with linespoints ti "Delay=300s"

EOF

# [delay vs tx-interval for various max-error]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Delay (s)"
set ylabel "Mean Tx interval (s)"
set key above

set output "plots/error_delay_delay_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data/error_delay_error2_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=2m", \
'data/error_delay_error5_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=5m", \
'data/error_delay_error10_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=10m", \
'data/error_delay_error30_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=30m", \
'data/error_delay_error50_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=50m", \
'data/error_delay_error100_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=100m", \
'data/error_delay_error200_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=200m", \
'data/error_delay_error300_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=300m", \
'data/error_delay_error500_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=500m", \
'data/error_delay_error1000_${category}_extr${extrapolator}' using 2:4 with linespoints ti "Error=1000m"

EOF





###############
# budget delay
##############
#delays="2 3 5 10 15 20 25 30 50 70 90 100 150 200 250 300 350 400"
# budget vs mean error
gnuplot<<EOF
set terminal pdf font "Helvetica,10" lw 2 dashed
set xlabel "Budget (s)"
set ylabel "Mean error (m)"
set key above

set output "plots/budget_delay_budget_${category}_extr${extrapolator}.pdf"

#set xrange [0:100]

plot \
'data/budget_delay_strawman_${category}_extr${extrapolator}' using 1:2 with linespoints ti "Straw-man", \
'data/budget_delay_delay2_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=2s", \
'data/budget_delay_delay3_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=3s", \
'data/budget_delay_delay5_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=5s", \
'data/budget_delay_delay10_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=10s", \
'data/budget_delay_delay15_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=15s", \
'data/budget_delay_delay20_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=20s", \
'data/budget_delay_delay25_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=25s", \
'data/budget_delay_delay30_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=30s", \
'data/budget_delay_delay50_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=50s", \
'data/budget_delay_delay70_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=70s", \
'data/budget_delay_delay90_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=90s", \
'data/budget_delay_delay100_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=100s", \
'data/budget_delay_delay150_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=150s", \
'data/budget_delay_delay200_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=200s", \
'data/budget_delay_delay250_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=250s", \
'data/budget_delay_delay300_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=300s", \
'data/budget_delay_delay350_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=350s", \
'data/budget_delay_delay400_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=400s"

EOF


# budget conformance
gnuplot<<EOF
set terminal pdf font "Helvetica,10" lw 2 dashed
set xlabel "Budget (s)"
set ylabel "Mean Tx interval (s)"
set key above

set output "plots/budget_delay_conformance_budget_${category}_extr${extrapolator}.pdf"

#set xrange [0:100]

plot \
'data/budget_delay_delay2_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=2s" ls 2, \
'data/budget_delay_delay3_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=3s" ls 3, \
'data/budget_delay_delay5_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=5s" ls 4, \
'data/budget_delay_delay10_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=10s" ls 5, \
'data/budget_delay_delay15_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=15s" ls 6, \
'data/budget_delay_delay20_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=20s" ls 7, \
'data/budget_delay_delay25_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=25s" ls 8, \
'data/budget_delay_delay30_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=30s" ls 9, \
'data/budget_delay_delay50_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=50s" ls 10, \
'data/budget_delay_delay70_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=70s" ls 11, \
'data/budget_delay_delay90_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=90s" ls 12, \
'data/budget_delay_delay100_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=100s" ls 13, \
'data/budget_delay_delay150_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=150s" ls 14, \
'data/budget_delay_delay200_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=200s" ls 15, \
'data/budget_delay_delay250_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=250s" ls 16, \
'data/budget_delay_delay300_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=300s" ls 17, \
'data/budget_delay_delay350_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=350s" ls 19, \
'data/budget_delay_delay400_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=400s" ls 20, \
x with lines ti "Ideal" ls 1
EOF



###############
# error budget 
##############

# budget vs avg delay for various errors 
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Budget (s)"
set ylabel "Mean delay (s)"
set key above

set output "plots/error_budget_budget_${category}_extr${extrapolator}.pdf"

set xrange [0:50]

plot \
'data/error_budget_budget_error2_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=2m", \
'data/error_budget_budget_error5_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=5m", \
'data/error_budget_budget_error10_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=10m", \
'data/error_budget_budget_error30_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=30m", \
'data/error_budget_budget_error50_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=50m", \
'data/error_budget_budget_error100_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=100m", \
'data/error_budget_budget_error200_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=200m", \
'data/error_budget_budget_error300_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=300m", \
'data/error_budget_budget_error500_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=500m", \
'data/error_budget_budget_error1000_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=1000m"

EOF


# error vs avg delay for various budget
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Max error (m)"
set ylabel "Mean delay (s)"
set key above

set output "plots/error_budget_error_${category}_extr${extrapolator}.pdf"

#set xrange [0:300]
#set yrange [0:150]

plot \
'data/error_budget_error_budget2_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=2s", \
'data/error_budget_error_budget5_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=5s", \
'data/error_budget_error_budget10_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=10s", \
'data/error_budget_error_budget15_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=15s", \
'data/error_budget_error_budget20_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=20s", \
'data/error_budget_error_budget30_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=30s", \
'data/error_budget_error_budget60_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=60s", \
'data/error_budget_error_budget120_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=120s", \
'data/error_budget_error_budget300_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Budget=300s"

EOF




# conformance with budget for various error
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Budget (s)"
set ylabel "Mean Tx interval (s)"
set key above

set output "plots/error_budget_conformance_budget_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data/error_budget_conformance_budget_error2_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=2m", \
'data/error_budget_conformance_budget_error5_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=5m", \
'data/error_budget_conformance_budget_error10_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=10m", \
'data/error_budget_conformance_budget_error30_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=30m", \
'data/error_budget_conformance_budget_error50_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=50m", \
'data/error_budget_conformance_budget_error100_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=100m", \
'data/error_budget_conformance_budget_error200_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=200m", \
'data/error_budget_conformance_budget_error300_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=300m", \
'data/error_budget_conformance_budget_error500_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=500m", \
'data/error_budget_conformance_budget_error1000_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Error=1000m"

EOF


	done
done





#plot online time_error table for each individual trips
# for file in `ls time_error_table`; do

# gnuplot<<EOF
# set terminal png 

# set xlabel "Time interval (s)"
# set ylabel "Error (m)"

# set output "plots_time_error_table/$file.png"
# plot 'time_error_table/$file' with image ti ""
# EOF

# done


#plot offile time_error table for whole dataset

for category in "osm" "msmls" "uic" "osm2"; do
gnuplot<<EOF
set terminal png 

set xlabel "Time interval (s)"
set ylabel "Error (m)"

set output "plots/time_error_table_$category.png"
plot 'data/time_error_$category.txt' with image ti ""
EOF
done



#plot expected errors from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_errors.pdf"

plot \
'data/expected_error_uic.txt' with lines ti "uic", \
'data/expected_error_osm.txt' with lines ti "osm", \
'data/expected_error_msmls.txt' with lines ti "msmls"
EOF



#plot expected errors from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_errors_const_vel_extr.pdf"

plot \
'data/expected_error_const_vel_uic.txt' with lines ti "uic", \
'data/expected_error_const_vel_osm.txt' with lines ti "osm", \
'data/expected_error_const_vel_msmls.txt' with lines ti "msmls"
EOF


#plot expected errors for REACH TIME from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_errors_for_reachtime.pdf"

plot \
'data/expected_error_for_reachtime_uic.txt' with lines ti "uic", \
'data/expected_error_for_reachtime_osm.txt' with lines ti "osm", \
'data/expected_error_for_reachtime_msmls.txt' with lines ti "msmls"
EOF

#plot expected errors for REACH TIME from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_errors_for_reachtime_const_vel.pdf"

plot \
'data/expected_error_for_reachtime_const_vel_uic.txt' with lines ti "uic", \
'data/expected_error_for_reachtime_const_vel_osm.txt' with lines ti "osm", \
'data/expected_error_for_reachtime_const_vel_msmls.txt' with lines ti "msmls"
EOF




#plot expected EXPONENTIAL errors for REACH TIME from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_exponentialerrors_for_reachtime.pdf"

plot \
'data/expected_exponentialerror_for_reachtime_uic.txt' with lines ti "uic", \
'data/expected_exponentialerror_for_reachtime_osm.txt' with lines ti "osm", \
'data/expected_exponentialerror_for_reachtime_msmls.txt' with lines ti "msmls"
EOF

#plot expected EXPONENTIAL errors for REACH TIME from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above


set output "plots/expected_exponentialerrors_for_reachtime_const_vel.pdf"

plot \
'data/expected_exponentialerror_for_reachtime_const_vel_uic.txt' with lines ti "uic", \
'data/expected_exponentialerror_for_reachtime_const_vel_osm.txt' with lines ti "osm", \
'data/expected_exponentialerror_for_reachtime_const_vel_msmls.txt' with lines ti "msmls"
EOF





#plot expected MEAN errors from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_meanerrors.pdf"

plot \
'data/expected_meanerror_uic.txt' with lines ti "uic", \
'data/expected_meanerror_osm.txt' with lines ti "osm", \
'data/expected_meanerror_msmls.txt' with lines ti "msmls"
EOF




#plot expected MEAN errors from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Time interval(s)"
set ylabel "Error (m)"
set key above

set output "plots/expected_meanerrors_const_vel_extr.pdf"

plot \
'data/expected_meanerror_const_vel_uic.txt' with lines ti "uic", \
'data/expected_meanerror_const_vel_osm.txt' with lines ti "osm", \
'data/expected_meanerror_const_vel_msmls.txt' with lines ti "msmls"
EOF




#plot expected times from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Expected time (s)"
set key above

set output "plots/expected_times.pdf"
set xtic rotate by -60

plot \
'data/expected_time_uic.txt' with lines ti "uic", \
'data/expected_time_osm.txt' with lines ti "osm", \
'data/expected_time_msmls.txt' with lines ti "msmls"
EOF


#plot expected times from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Expected time (s)"
set key above

set output "plots/expected_times_const_vel_extr.pdf"
set xtic rotate by -60

plot \
'data/expected_time_const_vel_uic.txt' with lines ti "uic", \
'data/expected_time_const_vel_osm.txt' with lines ti "osm", \
'data/expected_time_const_vel_msmls.txt' with lines ti "msmls"
EOF


#plot expected REACH times from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Expected reach time (s)"
set key above

set output "plots/expected_reachtimes.pdf"
set xtic rotate by -60

plot \
'data/expected_reachtime_uic.txt' with lines ti "uic", \
'data/expected_reachtime_osm.txt' with lines ti "osm", \
'data/expected_reachtime_msmls.txt' with lines ti "msmls"
EOF


#plot expected REACH times from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Expected reach time (s)"
set key above

set output "plots/expected_reachtimes_const_vel_extr.pdf"
set xtic rotate by -60

plot \
'data/expected_reachtime_const_vel_uic.txt' with lines ti "uic", \
'data/expected_reachtime_const_vel_osm.txt' with lines ti "osm", \
'data/expected_reachtime_const_vel_msmls.txt' with lines ti "msmls"
EOF



#plot expected REACH times for Exponential error buckets from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Expected reach time (s)"
set key above

set xtic rotate by -60


set output "plots/expected_reachtimes_for_exponentialerror.pdf"

plot \
'data/expected_reachtime_for_exponentialerror_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_msmls.txt' with linespoints ti "msmls"


set logscale y 2
set output "plots/expected_reachtimes_for_exponentialerror_logscale.pdf"

plot \
'data/expected_reachtime_for_exponentialerror_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_msmls.txt' with linespoints ti "msmls"


EOF



#plot expected BUDGET intervals for Exponential error buckets from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Expected budget interval (s)"
set key above

set xtic rotate by -60


set output "plots/expected_budget_for_exponentialerror.pdf"

plot \
'data/expected_budget_for_exponentialerror_uic_x0.txt' with linespoints ti "uic", \
'data/expected_budget_for_exponentialerror_osm_x0.txt' with linespoints ti "osm", \
'data/expected_budget_for_exponentialerror_msmls_x0.txt' with linespoints ti "msmls"


set logscale y 2
set output "plots/expected_budget_for_exponentialerror_logscale.pdf"

plot \
'data/expected_budget_for_exponentialerror_uic_x0.txt' with linespoints ti "uic", \
'data/expected_budget_for_exponentialerror_osm_x0.txt' with linespoints ti "osm", \
'data/expected_budget_for_exponentialerror_msmls_x0.txt' with linespoints ti "msmls"


EOF


#plot expected exponentialerror for budget intervals from offline budget_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Budget interval (s)"
set ylabel "Expected error (m)"
set key above

set xtic rotate by -60

set yrange [0:]

set output "plots/expected_exponentialerror_for_budget.pdf"

plot \
'data/expected_exponentialerror_for_budget_uic_x0.txt' with lines ti "uic", \
'data/expected_exponentialerror_for_budget_osm_x0.txt' with lines ti "osm", \
'data/expected_exponentialerror_for_budget_msmls_x0.txt' with lines ti "msmls", \
'data/expected_exponentialerror_for_budget_msmls2_x0.txt' with lines ti "msmls2"

EOF

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Budget interval (s)"
set ylabel "Expected error (m)"
set key above

set xtic rotate by -60

#set yrange [0:]

set output "plots/expected_exponentialerror_for_budget_with_delays_osm.pdf"

plot \
'data/expected_exponentialerror_for_budget_osm_x0.txt' using 1:2 with lines ti "delay=0s", \
'data/expected_exponentialerror_for_budget_osm_x0_d8.txt' using 1:2 with lines ti "delay=8s", \
'data/expected_exponentialerror_for_budget_osm_x0_d32.txt' using 1:2 with lines ti "delay=32s", \
'data/expected_exponentialerror_for_budget_osm_x0_d128.txt' using 1:2 with lines ti "delay=128s"

EOF




#plot expected REACH times for Exponential error buckets from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Expected reach time (s)"
set key above
set xtic rotate by -60

set output "plots/expected_reachtimes_for_exponentialerror_const_vel_extr.pdf"

plot \
'data/expected_reachtime_for_exponentialerror_const_vel_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_const_vel_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_const_vel_msmls.txt' with linespoints ti "msmls"

set logscale y 2
set output "plots/expected_reachtimes_for_exponentialerror_const_vel_extr_logscale.pdf"
plot \
'data/expected_reachtime_for_exponentialerror_const_vel_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_const_vel_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_const_vel_msmls.txt' with linespoints ti "msmls"


EOF




#plot HUMP REMOVED expected REACH times for Exponential error buckets from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Expected reach time (s)"
set key above
set xtic rotate by -60


set output "plots/expected_reachtimes_for_exponentialerror_wo_hump.pdf"

plot \
'data/expected_reachtime_for_exponentialerror_wo_hump_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_wo_hump_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_wo_hump_msmls.txt' with linespoints ti "msmls"

set logscale y 2
set output "plots/expected_reachtimes_for_exponentialerror_wo_hump_logscale.pdf"
plot \
'data/expected_reachtime_for_exponentialerror_wo_hump_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_wo_hump_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_wo_hump_msmls.txt' with linespoints ti "msmls"


EOF



#plot HUMP REMOVED expected BUDGET intervals for Exponential error buckets from offline time_error table [constant location extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Expected budget interval (s)"
set key above
set xtic rotate by -60


set output "plots/expected_budget_for_exponentialerror_wo_hump.pdf"

plot \
'data/expected_budget_for_exponentialerror_wo_hump_uic_x0.txt' with linespoints ti "uic", \
'data/expected_budget_for_exponentialerror_wo_hump_osm_x0.txt' with linespoints ti "osm", \
'data/expected_budget_for_exponentialerror_wo_hump_msmls_x0.txt' with linespoints ti "msmls"

set logscale y 2
set output "plots/expected_budget_for_exponentialerror_wo_hump_logscale.pdf"
plot \
'data/expected_budget_for_exponentialerror_wo_hump_uic_x0.txt' with linespoints ti "uic", \
'data/expected_budget_for_exponentialerror_wo_hump_osm_x0.txt' with linespoints ti "osm", \
'data/expected_budget_for_exponentialerror_wo_hump_msmls_x0.txt' with linespoints ti "msmls"


EOF


#plot HUMP_REMOVED expected REACH times for Exponential error buckets from offline time_error table [constant velocity extrapolator]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Expected reach time (s)"
set key above
set xtic rotate by -60

set output "plots/expected_reachtimes_for_exponentialerror_const_vel_extr_wo_hump.pdf"

plot \
'data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_msmls.txt' with linespoints ti "msmls"

set logscale y 2
set output "plots/expected_reachtimes_for_exponentialerror_const_vel_extr_wo_hump_logscale.pdf"

plot \
'data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_uic.txt' with linespoints ti "uic", \
'data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_osm.txt' with linespoints ti "osm", \
'data/expected_reachtime_for_exponentialerror_wo_hump_const_vel_msmls.txt' with linespoints ti "msmls"

EOF


# comparison between const location extr and const velocity extr of expected reachtimes for exponential error 
for category in "osm" "msmls" "uic"; do
gnuplot <<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error Bucket"
set ylabel "Expected reach time (s)"
set key above

set output "plots/extrapolator_comparison_expected_reachtime_for_errorbucket_$category.pdf"
set xtic rotate by -60
#set logscale x 2

plot \
'data/expected_reachtime_for_exponentialerror_$category.txt' with linespoints ti "Const location extrapolator", \
'data/expected_reachtime_for_exponentialerror_const_vel_$category.txt' with linespoints ti "Const velocity extrapolator"

EOF
done



# comparison of time/expected-time and error/expected-error
for category in "osm" "msmls" "uic"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Time (s)"
set key above

set output "plots/expected_errors_times_$category.pdf"
set xtic rotate by -60
#set logscale x 2

plot \
'data/expected_time_$category.txt' with lines ti "Expected time for error", \
'data/expected_error_$category.txt' using 2:1 with lines ti "Expected error for time"
EOF
done

# comparison of REACHtime/expected-REACHtime and error/expected-error
for category in "osm" "msmls" "uic" "osm2"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Time (s)"
set key above

set output "plots/expected_errors_reachtimes_$category.pdf"
set xtic rotate by -60
#set logscale x 2

plot \
'data/expected_reachtime_$category.txt' with lines ti "Expected reachtime for error", \
'data/expected_error_for_reachtime_$category.txt' using 2:1 with lines ti "Expected error for reachtime"
EOF
done



# distribution of errors for various times
for time in 1 2 5 10 30 60 120 180 300 600 900 1200 1500 1700; do
	for category in "osm" "uic"; do

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Count"
set key above

set xrange [50:]
set xtic rotate by -60

# const location extrapolator
set output "plots_error_distribution/error_distribution_${category}_${time}.pdf"
plot 'data/error_${category}_${time}' with linespoints ti ""

# const velocity extrapolator
set output "plots_error_distribution/error_distribution_const_vel_${category}_${time}.pdf"
plot 'data/error_const_vel_${category}_${time}' with linespoints ti ""

EOF

	done
done

for time in 10 30 60 120 180 300 600 900 1200 1500 1700; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error (m)"
set ylabel "Count"
set key above

set xrange [100:]
set xtic rotate by -60

set output "plots_error_distribution/error_distribution_msmls_${time}.pdf"

plot 'data/error_msmls_${time}' with linespoints ti ""
EOF

done




# distribution of Exponential errors for various times 
for time in 1 2 5 10 30 60 120 180 300 600 900 1200 1500 1700; do
	for category in "osm" "uic"; do

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Count"
set key above

#set xrange [50:]
set xtic rotate by -60

# const location extrapolator
set output "plots_exponentialerror_distribution/error_distribution_${category}_${time}.pdf"
plot 'data/exponentialerror_${category}_${time}' with linespoints ti ""

# const velocity extrapolator
set output "plots_error_distribution/error_distribution_const_vel_${category}_${time}.pdf"
plot 'data/exponentialerror_const_vel_${category}_${time}' with linespoints ti ""

EOF

	done
done

for time in 10 30 60 120 180 300 600 900 1200 1500 1700; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Error bucket"
set ylabel "Count"
set key above

#set xrange [100:]
set xtic rotate by -60

set output "plots_exponentialerror_distribution/error_distribution_msmls_${time}.pdf"

plot 'data/exponentialerror_msmls_${time}' with linespoints ti ""
EOF

done


# distribution of reacthime for various buckets
for bucket in 1 2 5 7 10 12 15 18 20 22 24 25 27 28 30 31 32 33; do
	for category in "osm" "uic" "msmls"; do

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Reach time (s)"
set ylabel "Count"
set key above

#set xrange [50:]
set xtic rotate by -60

# const location extrapolator
set output "plots_reachtime_distribution/reachtime_distribution_${category}_${bucket}.pdf"
plot 'data/reachtime_${category}_${bucket}' with lines ti ""

# const velocity extrapolator
set output "plots_reachtime_distribution/reachtime_distribution_const_vel_${category}_${bucket}.pdf"
plot 'data/reachtime_const_vel_${category}_${bucket}' with lines ti ""

EOF

	done
done


# comparision between const location and const velocity extrapolator for reachtime distribution for various error buckets
for bucket in 1 2 5 7 10 12 15 18 20 22 24 25 27 28 30 31 32 33; do
	for category in "osm" "uic" "msmls"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Reach time (s)"
set ylabel "Count"
set key above

set output "plots_reachtime_distribution/extr_comparison_reachtime_distribution_${category}_${bucket}.pdf"
set xtic rotate by -60
#set logscale x 2

plot \
'data/reachtime_${category}_${bucket}' with lines ti "Const location extrapolator", \
'data/reachtime_const_vel_${category}_${bucket}' with lines ti "Const velocity extrapolator"

EOF
	done
done


#pairwise distance cdf
for category in "osm" "uic" "msmls"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Pairwise Distance (m)"
set ylabel "Cumulative Distribution"
set key above


set output "plots/cdf_pairwise_distance_${category}.pdf"
set xrange [:100]

plot 'data/cdf_pairwise_time_distance_$category.txt' using 2:1 with lines ti ""
EOF
done

#stationary duration cdfs
for category in "osm" "uic" "msmls"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Stationary Duration (s)"
set ylabel "Cumulative Distribution"
set key above

set output "plots/cdf_stationary_duration_${category}.pdf"
set xrange [:20]

plot 'data/stationary_durations_$category' using 2:1 with lines ti ""
EOF
done


# gnuplot<<EOF
# set term png size 50000,600 font "/Library/Fonts/Arial.ttf" 15

# set xdata time
# set timefmt "%s"

# set yrange [0:100]

# set xlabel "Time"
# set ylabel "Error (m)"

# set grid

# set ytics 5

# set output "plots/pairwise_distance.png"
# plot 'data/pairwise_distance.txt' using 1:2 with lines ti ""
# EOF


# CDF of trip durations
for category in "osm" "msmls" "uic"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4
set xlabel "Trip duration(s)"
set ylabel "Cumulative Distribution"
set key above

set xtic rotate by -60

set xrange [:10000]
#set logscale x

set output "plots/cdf_trip_durations_$category.pdf"

plot 'data/cdf_trip_durations_$category' using 2:1 with lines ti ""

EOF

done



#data usage
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4
set xlabel "Sample count in the payload"
set ylabel "Bytes"
set key above

set xtic rotate by -60

#set logscale x

set grid
set output "plots/data_usage.pdf"

plot 'data/data_usage' using 1:2 with lines ti ""

EOF

#data usage [Log scale]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4
set xlabel "Sample count in the payload"
set ylabel "Bytes"
set key above

set xtic rotate by -60

set grid
set logscale x 2

set output "plots/data_usage_log.pdf"

plot 'data/data_usage' using 1:2 with lines ti ""

EOF



#expected mean error vs budget in bytes/sec
for category in "osm" "uic" "osm2"; do
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Budget (Bytes/sec)"
set ylabel "Expected mean error (m)"
set key above

#set xtic rotate by -60

set yrange [:1000]
set xrange [:20]
#set logscale x

set output "plots/expected_meanerror_bytes_sec_$category.pdf"

plot\
'data/expected_meanerror_bytes_sec_d4_$category.txt' using 2:3 with lines ti "Delay=4s", \
'data/expected_meanerror_bytes_sec_d9_$category.txt' using 2:3 with lines ti "Delay=9s", \
'data/expected_meanerror_bytes_sec_d15_$category.txt' using 2:3 with lines ti "Delay=15s", \
'data/expected_meanerror_bytes_sec_d40_$category.txt' using 2:3 with lines ti "Delay=40s", \
'data/expected_meanerror_bytes_sec_d120_$category.txt' using 2:3 with lines ti "Delay=120s"


set output "plots/expected_meanerror_bytes_sec_const_vel_$category.pdf"
set yrange [0:10]

plot\
'data/expected_meanerror_bytes_sec_const_vel_d4_$category.txt' using 2:3 with lines ti "Delay=4s", \
'data/expected_meanerror_bytes_sec_const_vel_d9_$category.txt' using 2:3 with lines ti "Delay=9s", \
'data/expected_meanerror_bytes_sec_const_vel_d15_$category.txt' using 2:3 with lines ti "Delay=15s", \
'data/expected_meanerror_bytes_sec_const_vel_d40_$category.txt' using 2:3 with lines ti "Delay=40s", \
'data/expected_meanerror_bytes_sec_const_vel_d120_$category.txt' using 2:3 with lines ti "Delay=120s"

EOF



done

