#!/bin/bash


gawk 'ARGIND==1 {error[$1]=$2; next} {print error[$1], $2}' data/buckets.txt data/expected_reachtime_for_exponentialerror_wo_hump_osm2_x0.txt > /tmp/expected_reachtime_for_exponentialerror_wo_hump_osm2_x0.txt
gawk 'ARGIND==1 {error[$1]=$2; next} {print error[$1], $2}' data/buckets.txt data/expected_reachtime_for_exponentialerror_wo_hump_osm2_x1.txt > /tmp/expected_reachtime_for_exponentialerror_wo_hump_osm2_x1.txt
gawk 'ARGIND==1 {error[$1]=$2; next} {print error[$1], $2}' data/buckets.txt data/expected_reachtime_for_exponentialerror_wo_hump_osm2_x2_e500.txt > /tmp/expected_reachtime_for_exponentialerror_wo_hump_osm2_x2_e500.txt


gawk 'ARGIND==1 {error[$1]=$2; next} {print error[$1], $2}' data/buckets.txt data/expected_reachtime_for_exponentialerror_osm2_x0.txt > /tmp/expected_reachtime_for_exponentialerror_osm2_x0.txt
gawk 'ARGIND==1 {error[$1]=$2; next} {print error[$1], $2}' data/buckets.txt data/expected_reachtime_for_exponentialerror_osm2_x1.txt > /tmp/expected_reachtime_for_exponentialerror_osm2_x1.txt
gawk 'ARGIND==1 {error[$1]=$2; next} {print error[$1], $2}' data/buckets.txt data/expected_reachtime_for_exponentialerror_osm2_x2_e500.txt > /tmp/expected_reachtime_for_exponentialerror_osm2_x2_e500.txt

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Max error (meters)"
set ylabel "Expected reach time (sec)"
set key above


set xrange [:1000]

set output "plots/expected_reachtimes_for_exponentialerror_osm2_wo_hump.pdf"
plot \
'/tmp/expected_reachtime_for_exponentialerror_wo_hump_osm2_x0.txt' u 1:2 with linespoints ti "CL", \
'/tmp/expected_reachtime_for_exponentialerror_wo_hump_osm2_x1.txt' u 1:2 with linespoints ti "CV", \
'/tmp/expected_reachtime_for_exponentialerror_wo_hump_osm2_x2_e500.txt' u 1:2 with linespoints ti "UN"


#set xrange [:20000]
set output "plots/expected_reachtimes_for_exponentialerror_osm2.pdf"
plot \
'/tmp/expected_reachtime_for_exponentialerror_osm2_x0.txt' u 1:2 with linespoints ti "CL", \
'/tmp/expected_reachtime_for_exponentialerror_osm2_x1.txt' u 1:2 with linespoints ti "CV", \
'/tmp/expected_reachtime_for_exponentialerror_osm2_x2_e500.txt' u 1:2 with linespoints ti "UN"




EOF




gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1
set xlabel "Max error (meters)"
set ylabel "Expected reach time (sec)"
set key above


#set xrange [:10000]

set output "plots/expected_reachtimes_for_exponentialerror_buckets_osm2_wo_hump.pdf"
plot \
'data/expected_reachtime_for_exponentialerror_wo_hump_osm2_x0.txt' u 1:2 with linespoints ti "CL", \
'data/expected_reachtime_for_exponentialerror_wo_hump_osm2_x1.txt' u 1:2 with linespoints ti "CV", \
'data/expected_reachtime_for_exponentialerror_wo_hump_osm2_x2_e500.txt' u 1:2 with linespoints ti "UN"


#set xrange [:20000]
set output "plots/expected_reachtimes_for_exponentialerror_buckets_osm2.pdf"
plot \
'data/expected_reachtime_for_exponentialerror_osm2_x0.txt' u 1:2 with linespoints ti "CL", \
'data/expected_reachtime_for_exponentialerror_osm2_x1.txt' u 1:2 with linespoints ti "CV", \
'data/expected_reachtime_for_exponentialerror_osm2_x2_e500.txt' u 1:2 with linespoints ti "UN"




EOF

