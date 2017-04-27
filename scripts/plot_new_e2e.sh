###############
# error delay
##############

for category in "uic" "osm"; do
  for extrapolator in 0 1 2; do

# plot no of tx vs MAX allowed error for various delay of error_delay sampler and also strawman
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Max error (m)"
set ylabel "Budget (bytes/sec)"
set key above

set output "plots_new_e2e/error_delay_maxerror_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]
set yrange[0:20]
set xrange[0:1000]

plot \
'data_new_e2e/error_delay_strawman_${category}_extr0' using 1:3 with lines ti "Straw-man sample", \
'data_new_e2e/error_delay_delay0_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=0s", \
'data_new_e2e/error_delay_delay2_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=2s", \
'data_new_e2e/error_delay_delay4_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=4s", \
'data_new_e2e/error_delay_delay8_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=8s", \
'data_new_e2e/error_delay_delay16_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=16s", \
'data_new_e2e/error_delay_delay32_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=32s",\
'data_new_e2e/error_delay_delay64_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=64s",\
'data_new_e2e/error_delay_delay128_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=128s",\
'data_new_e2e/error_delay_delay256_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=256s",\
'data_new_e2e/error_delay_strawman_window_${category}_extr0' using 1:3 with lines ti "Straw-man window"

EOF

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Mean error (m)"
set ylabel "Budget (bytes/sec)"
set key above

set output "plots_new_e2e/error_delay_meanerror_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data_new_e2e/error_delay_strawman_${category}_extr0' using 2:3 with lines ti "Straw-man sample", \
'data_new_e2e/error_delay_delay0_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=0s", \
'data_new_e2e/error_delay_delay2_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=2s", \
'data_new_e2e/error_delay_delay4_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=4s", \
'data_new_e2e/error_delay_delay8_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=8s", \
'data_new_e2e/error_delay_delay16_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=16s", \
'data_new_e2e/error_delay_delay32_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=32s", \
'data_new_e2e/error_delay_delay64_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=64s", \
'data_new_e2e/error_delay_delay128_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=128s", \
'data_new_e2e/error_delay_delay256_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=256s", \
'data_new_e2e/error_delay_strawman_window_${category}_extr0' using 2:3 with lines ti "Straw-man window"

EOF

# [delay vs tx-interval for various max-error]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Delay (sec)"
set ylabel "Budget (byets/sec)"
set key above

set output "plots_new_e2e/error_delay_delay_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data_new_e2e/error_delay_error1_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=1m", \
'data_new_e2e/error_delay_error5_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=5m", \
'data_new_e2e/error_delay_error10_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=10m", \
'data_new_e2e/error_delay_error50_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=50m", \
'data_new_e2e/error_delay_error100_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=100m", \
'data_new_e2e/error_delay_error200_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=100m", \
'data_new_e2e/error_delay_error500_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=500m"

EOF

  done;
done

for category in "msmls"; do
  for extrapolator in 0 1 2; do

# plot no of tx vs MAX allowed error for various delay of error_delay sampler and also strawman
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Max error (m)"
set ylabel "Budget (bytes/sec)"
set key above

set output "plots_new_e2e/error_delay_maxerror_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data_new_e2e/error_delay_strawman_${category}_extr0' using 1:3 with lines ti "Straw-man sample", \
'data_new_e2e/error_delay_delay16_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=16s", \
'data_new_e2e/error_delay_delay32_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=32s",\
'data_new_e2e/error_delay_delay64_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=64s",\
'data_new_e2e/error_delay_delay128_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=128s",\
'data_new_e2e/error_delay_delay256_${category}_extr${extrapolator}' using 1:4 with lines ti "Delay=256s",\
'data_new_e2e/error_delay_strawman_window_${category}_extr0' using 1:3 with lines ti "Straw-man window"

EOF

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Mean error (m)"
set ylabel "Budget (bytes/sec)"
set key above

set output "plots_new_e2e/error_delay_meanerror_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]

plot \
'data_new_e2e/error_delay_strawman_${category}_extr0' using 2:3 with lines ti "Straw-man sample", \
'data_new_e2e/error_delay_delay16_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=16s", \
'data_new_e2e/error_delay_delay32_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=32s", \
'data_new_e2e/error_delay_delay64_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=64s", \
'data_new_e2e/error_delay_delay128_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=128s", \
'data_new_e2e/error_delay_delay256_${category}_extr${extrapolator}' using 3:4 with lines ti "Delay=256s", \
'data_new_e2e/error_delay_strawman_window_${category}_extr0' using 2:3 with lines ti "Straw-man window"

EOF

# [delay vs tx-interval for various max-error]
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Delay (sec)"
set ylabel "Budget (byets/sec)"
set key above

set output "plots_new_e2e/error_delay_delay_${category}_extr${extrapolator}.pdf"

#set yrange [0:50000]
set xrange[10:]

plot \
'data_new_e2e/error_delay_error1_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=1m", \
'data_new_e2e/error_delay_error5_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=5m", \
'data_new_e2e/error_delay_error10_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=10m", \
'data_new_e2e/error_delay_error50_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=50m", \
'data_new_e2e/error_delay_error100_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=100m", \
'data_new_e2e/error_delay_error200_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=100m", \
'data_new_e2e/error_delay_error500_${category}_extr${extrapolator}' using 2:4 with lines ti "Error=500m"

EOF

  done;
done

###############
# budget delay
##############

for category in "uic" "osm"; do
  for extrapolator in 0 1 3; do

# budget vs mean error
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean error (m)"
set key above

set output "plots_new_e2e/budget_delay_budget_${category}_extr${extrapolator}.pdf"

set xrange [:17]
#set yrange [:800]
#set yrange [:200]

plot \
'data_new_e2e/budget_delay_strawman_${category}_extr0' using 1:2 with lines ti "Straw-man sample", \
'data_new_e2e/budget_delay_delay0_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=0s", \
'data_new_e2e/budget_delay_delay2_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=2s", \
'data_new_e2e/budget_delay_delay4_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=4s", \
'data_new_e2e/budget_delay_delay8_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=8s", \
'data_new_e2e/budget_delay_delay16_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=16s", \
'data_new_e2e/budget_delay_delay32_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=32s", \
'data_new_e2e/budget_delay_delay64_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=64s", \
'data_new_e2e/budget_delay_delay128_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=128s", \
'data_new_e2e/budget_delay_delay256_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=256s", \
'data_new_e2e/budget_delay_strawman_window_${category}_extr0' using 1:2 with lines ti "Straw-man window"

EOF

  done;
done

for category in "msmls"; do
  for extrapolator in 0 1 3; do

# budget vs mean error
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean error (m)"
set key above

set output "plots_new_e2e/budget_delay_budget_${category}_extr${extrapolator}.pdf"

set xrange [:17]
#set yrange [:800]
set yrange [:200]


plot \
'data_new_e2e/budget_delay_strawman_${category}_extr0' using 1:2 with lines ti "Straw-man sample", \
'data_new_e2e/budget_delay_delay16_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=16s", \
'data_new_e2e/budget_delay_delay32_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=32s", \
'data_new_e2e/budget_delay_delay64_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=64s", \
'data_new_e2e/budget_delay_delay128_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=128s", \
'data_new_e2e/budget_delay_delay256_${category}_extr${extrapolator}' using 1:3 with lines ti "Delay=256s", \
'data_new_e2e/budget_delay_strawman_window_${category}_extr0' using 1:2 with lines ti "Straw-man window"

EOF

  done;
done

###############
# error budget 
##############

for category in "msmls" "uic" "osm"; do
  for extrapolator in 0 1 2; do

# budget vs avg delay for various errors 
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean delay (s)"
set key above

set output "plots_new_e2e/error_budget_budget_${category}_extr${extrapolator}.pdf"

set xrange [0:6]
set yrange [0:600]

plot \
'data_new_e2e/error_budget_budget_error1_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=1m", \
'data_new_e2e/error_budget_budget_error5_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=5m", \
'data_new_e2e/error_budget_budget_error10_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=10m", \
'data_new_e2e/error_budget_budget_error50_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=50m", \
'data_new_e2e/error_budget_budget_error100_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=100m", \
'data_new_e2e/error_budget_budget_error200_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=200m", \
'data_new_e2e/error_budget_budget_error500_${category}_extr${extrapolator}' using 1:3 with lines ti "Error=500m"

EOF

# error vs avg delay for various budget
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 3 dashed
set xlabel "Max error (m)"
set ylabel "Mean delay (s)"
set key above

set output "plots_new_e2e/error_budget_error_${category}_extr${extrapolator}.pdf"

#set xrange [0:6]
#set yrange [0:600]

plot \
'data_new_e2e/error_budget_error_budget0.1_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=0.1", \
'data_new_e2e/error_budget_error_budget0.25_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=0.25", \
'data_new_e2e/error_budget_error_budget0.5_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=0.5", \
'data_new_e2e/error_budget_error_budget0.75_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=0.75", \
'data_new_e2e/error_budget_error_budget1_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=1", \
'data_new_e2e/error_budget_error_budget2_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=2", \
'data_new_e2e/error_budget_error_budget5_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=5", \
'data_new_e2e/error_budget_error_budget8_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=8", \
'data_new_e2e/error_budget_error_budget10_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=10", \
'data_new_e2e/error_budget_error_budget15_${category}_extr${extrapolator}' using 1:3 with lines ti "Budget=15"

EOF

  done;
done
