
###############
# budget delay
##############
for category in "osm"; do
	for extrapolator in 0; do



gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean error (meters)"
set key above

set output "plots_new_small/budget_delay_2_8_budget_${category}_extr${extrapolator}.pdf"

#set xrange [:6]
#set yrange [:1000]


plot \
'data_new_small/budget_delay_8_delay0_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=0s (S)", \
'data_new_small/budget_delay_2_delay0_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=0s", \
'data_new_small/budget_delay_8_delay32_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s (S)", \
'data_new_small/budget_delay_2_delay32_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s", \
'data_new_small/budget_delay_8_delay128_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s (S)", \
'data_new_small/budget_delay_2_delay128_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s"

EOF

# budget vs mean error
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget (bytes/sec)"
set ylabel "Mean error (m)"
set key above

set output "plots_new_small/budget_delay_2_budget_${category}_extr${extrapolator}.pdf"

#set xrange [:6]
#set yrange [:1000]


plot \
'data_new_small/budget_delay_strawman_${category}_extr${extrapolator}' using 1:2 with linespoints ti "Straw man", \
'data_new_small/budget_delay_2_delay0_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=0s", \
'data_new_small/budget_delay_2_delay8_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=8s", \
'data_new_small/budget_delay_2_delay32_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s", \
'data_new_small/budget_delay_2_delay128_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=128s", \
'data_new_small/budget_delay_2_delay256_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=256s"

set output "plots_new_small/budget_delay_10_budget_${category}_extr${extrapolator}.pdf"

#set xrange [:15]
set yrange [:20]


plot \
'data_new_small/budget_delay_strawman_${category}_extr${extrapolator}' using 1:2 with linespoints ti "Straw-man sample", \
'data_new_small/budget_delay_10_delay0_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=0s", \
'data_new_small/budget_delay_10_delay8_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=8s", \
'data_new_small/budget_delay_10_delay32_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s", \
'data_new_small/budget_delay_10_delay64_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=64s", \
'data_new_small/budget_delay_10_delay128_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=128s", \
'data_new_small/budget_delay_10_delay256_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=256s"


# set output "plots_new_small/budget_delay_12_budget_${category}_extr${extrapolator}.pdf"

# #set xrange [:6]
# set yrange [:1000]


# plot \
# 'data_new_small/budget_delay_strawman_${category}_extr${extrapolator}' using 1:2 with linespoints ti "Straw-man sample", \
# 'data_new_small/budget_delay_12_delay0_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=0s", \
# 'data_new_small/budget_delay_12_delay8_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=8s", \
# 'data_new_small/budget_delay_12_delay32_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=32s", \
# 'data_new_small/budget_delay_12_delay64_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=64s", \
# 'data_new_small/budget_delay_12_delay128_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=128s", \
# 'data_new_small/budget_delay_12_delay256_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Delay=256s", \
# 'data_new_small/budget_delay_strawman_window_${category}_extr${extrapolator}' using 1:2 with linespoints ti "Straw-man window"


EOF


# budget conformance
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Data usage (bytes/sec)"
set key above

set output "plots_new_small/budget_delay_2_conformance_budget_${category}_extr${extrapolator}.pdf"

#set xrange [0:6]

plot \
'data_new_small/budget_delay_2_delay0_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=0s" ls 2, \
'data_new_small/budget_delay_2_delay8_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=8s" ls 3, \
'data_new_small/budget_delay_2_delay32_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=32s" ls 4, \
'data_new_small/budget_delay_2_delay128_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=128s" ls 5, \
'data_new_small/budget_delay_2_delay256_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=256s" ls 6, \
'data_new_small/budget_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Straw man" ls 7, \
x with lines ti "Ideal" ls 1


set output "plots_new_small/budget_delay_10_conformance_budget_${category}_extr${extrapolator}.pdf"

#set xrange [0:15]

plot \
'data_new_small/budget_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Straw-man sample" ls 2, \
'data_new_small/budget_delay_10_delay0_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=0s" ls 3, \
'data_new_small/budget_delay_10_delay8_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=8s" ls 6, \
'data_new_small/budget_delay_10_delay32_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=32s" ls 8, \
'data_new_small/budget_delay_10_delay64_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=64s" ls 9, \
'data_new_small/budget_delay_10_delay128_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=128s" ls 10, \
'data_new_small/budget_delay_10_delay256_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=256s" ls 11, \
x with lines ti "Ideal" ls 1


# set output "plots_new_small/budget_delay_12_conformance_budget_${category}_extr${extrapolator}.pdf"

# #set xrange [0:15]

# plot \
# 'data_new_small/budget_delay_strawman_${category}_extr${extrapolator}' using 1:3 with linespoints ti "Straw-man sample" ls 2, \
# 'data_new_small/budget_delay_12_delay0_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=0s" ls 3, \
# 'data_new_small/budget_delay_12_delay8_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=8s" ls 6, \
# 'data_new_small/budget_delay_12_delay32_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=32s" ls 8, \
# 'data_new_small/budget_delay_12_delay64_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=64s" ls 9, \
# 'data_new_small/budget_delay_12_delay128_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=128s" ls 10, \
# 'data_new_small/budget_delay_12_delay256_${category}_extr${extrapolator}' using 1:4 with linespoints ti "Delay=256s" ls 11
# x with lines ti "Ideal" ls 1

EOF


	done
done
