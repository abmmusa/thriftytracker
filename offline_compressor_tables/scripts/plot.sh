#!/bin/bash

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 4 dashed
set xlabel "Delay (seconds)"
set ylabel "Mean error (meters)"
set key above

set xrange [:128]

set output "plots/compression_error_both.pdf"
plot \
'data/osm2.txt' using 1:2 with linespoints ti "Mean of max errors", \
'data/osm2.txt' using 1:3 with linespoints ti "Mean of mean errors"

set output "plots/compression_error_meanofmax.pdf"
plot \
'data/osm2.txt' using 1:2 with linespoints ti "Mean of max errors"

EOF


cat data/osm2.txt | awk '$1>0 {print}' > /tmp/osm2.txt

gnuplot<<EOF
set terminal pdf font "Helvetica,15" lw 4 dashed
set xlabel "Window size (seconds)"
set ylabel "Mean error (meters)"
set key above

set ytics 10

set style fill solid
set boxwidth 0.5

#set xrange [5:]


set output "plots/compression_error_meanofmax_bars.pdf"
plot \
'/tmp/osm2.txt' using 2:xtic(1) with boxes ti ""

EOF

