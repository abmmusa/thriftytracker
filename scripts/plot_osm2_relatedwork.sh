


###############
# error delay
##############

for category in "osm2"; do
	for extrapolator in 1 5; do


# plot no of tx vs MAX allowed error for various delay of error_delay sampler and also strawman
#echo "plots_new/error_delay_maxerror_${category}_extr${extrapolator}.pdf"
gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Max error (meters)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 2


set xrange [0:120]
set yrange [0:10]


set output "plots_new/error_delay_maxerror_${category}_relatedwork.pdf"
plot \
'data_new/error_delay_delay0_${category}_extr5' using 1:4 with linespoint ti "Jensen" ,\
'data_new/error_delay_delay0_${category}_extr1' using 1:4 with linespoint ti "Wolfson" ,\
'data_new/error_delay_delay0_${category}_extr2' using 1:4 with linespoint ti "Unified, Delay=0s" ,\
'data_new/error_delay_delay8_${category}_extr2' using 1:4 with linespoint ti "Unified, Delay=8s" ,\
'data_new/error_delay_delay16_${category}_extr2' using 1:4 with linespoint ti "Unified, Delay=16s" ,\
'data_new/error_delay_delay32_${category}_extr2' using 1:4 with linespoint ti "Unified, Delay=32s" ,\
'data_new/error_delay_delay64_${category}_extr2' using 1:4 with linespoint ti "Unified, Delay=64s" ,\
'data_new/error_delay_delay128_${category}_extr2' using 1:4 with linespoint ti "Unified, Delay=128s" 

EOF




# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Delay (sec)"
# set ylabel "Data usage (byets/sec)"
# set key above maxrows 2


# set xrange [0:32]
# #set yrange [0:20]

# set output "plots_new/error_delay_delay_${category}_relatedwork.pdf"
# plot \
# 'data_new/error_delay_error1_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=1m" ls 2, \
# 'data_new/error_delay_error2_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=2m" ls 3, \
# 'data_new/error_delay_error5_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=5m" ls 4, \
# 'data_new/error_delay_error10_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=10m" ls 5, \
# 'data_new/error_delay_error20_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=20m" ls 6, \
# 'data_new/error_delay_error50_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=50m" ls 7, \
# 'data_new/error_delay_error100_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=100m" ls 8, \
# 'data_new/error_delay_error500_${category}_extr${extrapolator}' using 2:4 with linespoint ti "Error=500m" ls 9
#EOF


	done
done









