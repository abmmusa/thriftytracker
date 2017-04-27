#!/bin/bash

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Duration (seconds)"
set ylabel "Tx cost (bytes)"
set key above

set xrange [:70]
set yrange [:90]

set output "plots/osm2_duration_vs_cost_x0.pdf"
plot \
'data/osm2_d0_x0.txt' using 2:3 with linespoints ti "Delay=0s", \
'data/osm2_d8_x0.txt' using 2:3 with linespoints ti "Delay=8s", \
'data/osm2_d16_x0.txt' using 2:3 with linespoints ti "Delay=16s", \
'data/osm2_d32_x0.txt' using 2:3 with linespoints ti "Delay=32s", \
'data/osm2_d64_x0.txt' using 2:3 with linespoints ti "Delay=64s", \
'data/osm2_d128_x0.txt' using 2:3 with linespoints ti "Delay=128s"


set output "plots/osm2_duration_vs_cost_x3.pdf"
plot \
'data/osm2_d0_x3.txt' using 2:3 with linespoints ti "Delay=0s", \
'data/osm2_d8_x3.txt' using 2:3 with linespoints ti "Delay=8s", \
'data/osm2_d16_x3.txt' using 2:3 with linespoints ti "Delay=16s", \
'data/osm2_d32_x3.txt' using 2:3 with linespoints ti "Delay=32s", \
'data/osm2_d64_x3.txt' using 2:3 with linespoints ti "Delay=64s", \
'data/osm2_d128_x3.txt' using 2:3 with linespoints ti "Delay=128s"


EOF
