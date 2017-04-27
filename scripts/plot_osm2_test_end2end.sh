#!/bin/bash



#############################
# budget delay end-to-end
#############################
echo "budget delay plots..."

periods="1800.0 3600.0"

for category in "osm2"; do
	for period in $periods; do
		for id in 12 13; do

# linegraph and bargraph

cat data_osm2_test/budget_delay_${id}_p${period}_${category}_end2end | awk 'NR>1 {print}' > /tmp/budget_delay_${id}_p${period}_${category}_end2end

# linegraph and bars
	gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Mean error (meters)"
set y2label "% of straw-man mean error"

set ytics 200 nomirror
set y2tics 10

set key above maxrows 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border noborder
#set boxwidth 0.9
set auto x

set output "plots_osm2_test_end2end/budget_delay_line_barchart_${id}_${period}_${category}_end2end.pdf"

#set xrange [0:250]

plot \
'data_osm2_test/budget_delay_percentage_${id}_p${period}_${category}_end2end' using 5:xtic(1) axes x1y2 title col, \
        '' using 7:xtic(1) axes x1y2 title col, \
        '' using 9:xtic(1) axes x1y2 title col, \
        '' using 11:xtic(1) axes x1y2 title col, \
'/tmp/budget_delay_${id}_p${period}_${category}_end2end' using 2 axes x1y1 with linespoints ls 10 lw 3 ti "straw-man", \

EOF


		done
	done
done




