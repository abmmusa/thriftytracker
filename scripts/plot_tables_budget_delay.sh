
# cat data/expected_exponentialerror_for_budget_osm_x0.txt | awk '{print 84.0/($1+1), $2}' > /tmp/expected_exponentialerror_for_budget_osm_x0.txt

# for delay in 0 8 32 128; do
# 	cat data/expected_exponentialerror_for_budget_osm_x0_d$delay.txt | awk '{print 84.0/($1+1), $2}' d=$delay > /tmp/expected_exponentialerror_for_budget_osm_x0_d$delay.txt
# done

#categories="osm uic msmls msmls2 msmls_interpolated osm2"
categories="osm2"

for category in $categories; do
	for extrapolator in 0 1 3; do

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Data usage (bytes/sec)"
set ylabel "Expected error (meters)"
set key above

set xrange [0:8]
set yrange [:1000]

#set xtic rotate by -60

#set logscale y


# set output "plots/expected_exponentialerror_for_budget_bytes_sec_with_delays_${category}_x${extrapolator}.pdf"
# plot \
# 'data/expected_exponentialerror_for_budget_bytessec_${category}_x${extrapolator}_d0.txt' using 1:2  with lines ti "delay=0s", \
# 'data/expected_exponentialerror_for_budget_bytessec_${category}_x${extrapolator}_d16.txt' using 1:2 with lines ti "delay=16s", \
# 'data/expected_exponentialerror_for_budget_bytessec_${category}_x${extrapolator}_d32.txt' using 1:2 with lines ti "delay=32s"


set output "plots/expected_exponentialerror_for_budget_bytes_sec_with_delays_maxerror_${category}_x${extrapolator}.pdf"
plot \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d0.txt' using 1:2  with lines ti "delay=0s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d8.txt' using 1:2  with lines ti "delay=8s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d16.txt' using 1:2 with lines ti "delay=16s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d32.txt' using 1:2 with lines ti "delay=32s"


set output "plots/budget_table_all_${category}_x${extrapolator}.pdf"
plot \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d0.txt' using 1:2  with lines ti "delay=0s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d8.txt' using 1:2  with lines ti "delay=8s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d16.txt' using 1:2 with lines ti "delay=16s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d32.txt' using 1:2 with lines ti "delay=32s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d64.txt' using 1:2 with lines ti "delay=64s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_${category}_x${extrapolator}_d128.txt' using 1:2 with lines ti "delay=128s"



EOF




gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Data usage (bytes/sec)"
set ylabel "Expected error (meters)"
set key above

set xtic rotate by -60

#set yrange [0:]

# set output "plots/expected_exponentialerror_for_budget_with_delays_${category}_x${extrapolator}.pdf"
# plot \
# 'data/expected_exponentialerror_for_budget_${category}_x${extrapolator}_d0.txt' using 1:2 with lines ti "delay=0s", \
# 'data/expected_exponentialerror_for_budget_${category}_x${extrapolator}_d8.txt' using 1:2 with lines ti "delay=8s", \
# 'data/expected_exponentialerror_for_budget_${category}_x${extrapolator}_d32.txt' using 1:2 with lines ti "delay=32s"


set output "plots/expected_exponentialerror_for_budget_with_delays_maxerror_${category}_x${extrapolator}.pdf"
plot \
'data/expected_exponentialerror_for_budget_maxerror_${category}_x${extrapolator}_d0.txt' using 1:2 with lines ti "delay=0s", \
'data/expected_exponentialerror_for_budget_maxerror_${category}_x${extrapolator}_d16.txt' using 1:2 with lines ti "delay=16s", \
'data/expected_exponentialerror_for_budget_maxerror_${category}_x${extrapolator}_d32.txt' using 1:2 with lines ti "delay=32s"


EOF





	done
done



gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Budget (bytes/s)"
set ylabel "Expected error (m)"
set key above

set xrange [0:8]
set yrange [:1000]

#set xtic rotate by -60

#set logscale y

set output "plots/expected_exponentialerror_for_budget_bytes_sec_with_delays_osm2_x0_x3.pdf"

set style line 1 lt 2 lw 2 pt 1 lc rgb "red"
set style line 2 lt 4 lw 2 pt 1 lc rgb "red"
set style line 3 lt 2 lw 2 pt 1 lc rgb "green"
set style line 4 lt 4 lw 2 pt 1 lc rgb "green"
set style line 5 lt 2 lw 2 pt 1 lc rgb "blue"
set style line 6 lt 4 lw 2 pt 1 lc rgb "blue"


plot \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_osm2_x0_d0.txt' using 1:2  with lines lw 1 ti "CL delay=0s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_osm2_x0_d8.txt' using 1:2 with lines lw 1ti "CL delay=8s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_osm2_x0_d32.txt' using 1:2 with lines lw 1 ti "CL delay=32s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_osm2_x3_d0.txt' using 1:2  with lines lw 3 ti "UN delay=0s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_osm2_x3_d8.txt' using 1:2 with lines lw 3 ti"UN delay=8s", \
'data/expected_exponentialerror_for_budget_bytessec_maxerror_osm2_x3_d32.txt' using 1:2 with lines lw 3 ti "UN delay=32s"


EOF
