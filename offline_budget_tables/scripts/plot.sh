#!/bin/bash

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Mean of max errors (meters)"
set ylabel "Duration (seconds)"
set key above

#set xrange [:25]

set output "plots/osm2_duration_vs_error.pdf"

plot \
'duration_error_tables/osm2_x0.txt' using 2:1 with linespoints ti "CL", \
'duration_error_tables/osm2_x3.txt' using 2:1 with linespoints ti "UN"

EOF