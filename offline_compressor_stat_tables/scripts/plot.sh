#!/bin/bash

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Mean of max errors (meters)"
set ylabel "Tx cost (bytes)"
set key above

set xrange [:25]

set output "plots/compression_error_vs_usage.pdf"
plot \
'data/osm2_d8.txt' using 2:5 with linespoints ti "Delay=8s", \
'data/osm2_d16.txt' using 2:5 with linespoints ti "Delay=16s", \
'data/osm2_d32.txt' using 2:5 with linespoints ti "Delay=32s", \
'data/osm2_d64.txt' using 2:5 with linespoints ti "Delay=64s", \
'data/osm2_d128.txt' using 2:5 with linespoints ti "Delay=128s"


set xrange [:200]
set yrange [:200]

set xlabel "Error bound (meters)"
set ylabel "Tx cost (bytes)"

set output "plots/compression_givenerror_vs_usage.pdf"
plot \
'data/osm2_d8.txt' using 1:5 with linespoints ti "Delay=8s", \
'data/osm2_d16.txt' using 1:5 with linespoints ti "Delay=16s", \
'data/osm2_d32.txt' using 1:5 with linespoints ti "Delay=32s", \
'data/osm2_d64.txt' using 1:5 with linespoints ti "Delay=64s", \
'data/osm2_d128.txt' using 1:5 with linespoints ti "Delay=128s"


EOF



