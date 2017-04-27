#!/bin/bash

periods="1800.0 3600.0"

###########################
# error delay end-to-end
###########################
echo "error delay plots..."

####
### Plotting osm2 separately here as uic and msmls do not have data for related work
####

for category in "osm2"; do

cat data_new/error_delay_${category}_end2end | awk 'NR>1 {print}' > /tmp/error_delay_${category}_end2end

# linegraph and bars
	gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Maximum error (meters)"
set ylabel "Usage (bytes/sec)"
set y2label "% of straw-man usage"

set ytics 10 nomirror
set y2tics 30

set key above maxrows 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
#set boxwidth 0.9
set auto x


set style line 1 lc rgb "#ffffd9"
set style line 2 lc rgb "#edf8b1"
set style line 3 lc rgb "#c7e9b4"
set style line 4 lc rgb "#7fcdbb"
set style line 5 lc rgb "#41b6c4"
set style line 6 lc rgb "#1d91c0"
set style line 7 lc rgb "#225ea8"
set style line 8 lc rgb "#0c2c84"

set style line 20 lc rgb "#ff0000"

set output "plots_new_end2end/error_delay_maxerror_line_barchart_${category}_end2end.pdf"

#set xrange [0:250]

plot \
'data_new/error_delay_percentage_${category}_end2end' using 4:xtic(1) axes x1y2 title col ls 1, \
        '' using 5:xtic(1) axes x1y2 title col ls 2, \
        '' using 7:xtic(1) axes x1y2 title col ls 3, \
        '' using 9:xtic(1) axes x1y2 title col ls 4, \
        '' using 11:xtic(1) axes x1y2 title col ls 5, \
        '' using 13:xtic(1) axes x1y2 title col ls 6, \
        '' using 15:xtic(1) axes x1y2 title col ls 7, \
        '' using 17:xtic(1) axes x1y2 title col ls 8,\
'/tmp/error_delay_${category}_end2end' using 2 axes x1y1 with linespoints ls 20 lw 3 ti "straw-man", \


EOF




done



# for category in "uic" "msmls"; do

# #
# #bargraphs together
# #

# #absolute
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Maximum error (meters)"
# set ylabel "Usage (bytes/sec)"
# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# #set xrange [0:250]


# set output "plots_new_end2end/error_delay_maxerror_barchart_${category}_end2end.pdf"

# plot \
# 'data_new/error_delay_${category}_end2end' using 2:xtic(1) title col, \
#         '' using 5:xtic(1) title col, \
#         '' using 7:xtic(1) title col,\
#         '' using 11:xtic(1) title col,\
#         '' using 13:xtic(1) title col,\
#         '' using 15:xtic(1) title col




# EOF

# #percentage
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Maximum error (meters)"
# set ylabel "% of straw-man usage"
# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# set output "plots_new_end2end/error_delay_maxerror_barchart_percentage_${category}_end2end.pdf"

# #set xrange [0:250]

# plot \
# 'data_new/error_delay_percentage_${category}_end2end' using 2:xtic(1) title col, \
#         '' using 5:xtic(1) title col, \
#         '' using 7:xtic(1) title col, \
#         '' using 11:xtic(1) title col, \
#         '' using 13:xtic(1) title col, \
#         '' using 15:xtic(1) title col


# EOF

# cat data_new/error_delay_${category}_end2end | awk 'NR>1 {print}' > /tmp/error_delay_${category}_end2end

# # linegraph and bars
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Maximum error (meters)"
# set ylabel "Usage (bytes/sec)"
# set y2label "% of straw-man usage"

# set ytics 10
# set y2tics 10

# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# set output "plots_new_end2end/error_delay_maxerror_line_barchart_${category}_end2end.pdf"

# #set xrange [0:250]

# plot \
# 'data_new/error_delay_percentage_${category}_end2end' using 5:xtic(1) axes x1y2 title col, \
#         '' using 7:xtic(1) axes x1y2 title col, \
#         '' using 9:xtic(1) axes x1y2 title col, \
#         '' using 11:xtic(1) axes x1y2 title col, \
#         '' using 13:xtic(1) axes x1y2 title col, \
#         '' using 15:xtic(1) axes x1y2 title col,\
# '/tmp/error_delay_${category}_end2end' using 2 axes x1y1 with linespoints ls 10 lw 3 ti "straw-man", \

# EOF



# #
# # bargraphs seperated
# #
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Max error (meters)"
# set ylabel "Data usage (bytes/sec)"
# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# set output "plots_new_end2end/error_delay_maxerror_barchart_separated_${category}_end2end.pdf"

# #set xrange [0:250]

# plot newhistogram "", \
# 'data_new/error_delay_${category}_end2end' using 2:xtic(1) title col, \
#         '' using 3:xtic(1) title col, \
#         newhistogram "", '' using 4:xtic(1) title col, \
#         '' using 5:xtic(1) title col, \
#         newhistogram "", '' using 6:xtic(1) title col, \
#         '' using 7:xtic(1) title col


# EOF

# done








#############################
# budget delay end-to-end
#############################
echo "budget delay plots..."

for category in "osm2"; do
#for category in "osm2" "uic" "msmls"; do
	for period in $periods; do
# # budget vs mean error [statistical]
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget usage (bytes/sec)"
# set ylabel "Mean error (meters)"
# set key above maxrows 2

# set xrange [0:11]

# set output "plots_new_end2end/budget_delay_statistical_maxerror_budget_${category}_end2end.pdf"

# plot \
# 'data_new/budget_delay_strawman_${category}_extr0' using 3:2 with linespoint ti "straw-man, const-loc", \
# 'data_new/budget_delay_strawman_${category}_extr3' using 3:2 with linespoint ti "straw-man, unified", \
# 'data_new/budget_delay_statistical_maxerror_delay0_${category}_extr0' using 4:3 with linespoint ti "delay=0,const-loc", \
# 'data_new/budget_delay_statistical_maxerror_delay0_${category}_extr3' using 4:3 with linespoint ti "delay=0, unified", \
# 'data_new/budget_delay_statistical_maxerror_delay8_${category}_extr0' using 4:3 with linespoint ti "delay=8, const-loc", \
# 'data_new/budget_delay_statistical_maxerror_delay8_${category}_extr3' using 4:3 with linespoint ti "delay=8, unified"

# EOF

#
#bargraphs together
#

cat data_new/budget_delay_p${period}_${category}_end2end | awk '$1>=2 {print}' > /tmp/budget_delay_p${period}_${category}_end2end

#absolute
	gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Mean error (meters)"
set key above maxrows 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border noborder
#set boxwidth 0.9
set auto x

set output "plots_new_end2end/budget_delay_statistical_maxerror_barchart_p${period}_${category}_end2end.pdf"

#set xrange [0:250]
set multiplot
set size 1.0,1.0
plot \
'data_new/budget_delay_p${period}_${category}_end2end' using 2:xtic(1) title col, \
        '' using 3:xtic(1) title col, \
        '' using 5:xtic(1) title col, \
        '' using 7:xtic(1) title col, \
        '' using 9:xtic(1) title col


set size 0.55,0.55
set origin 0.4,0.2
set ytics 50
set xlabel ""
set ylabel ""
plot \
'/tmp/budget_delay_p${period}_${category}_end2end' using 2:xtic(1) title "", \
        '' using 3:xtic(1) title "", \
        '' using 5:xtic(1) title "", \
        '' using 7:xtic(1) title "", \
        '' using 9:xtic(1) title ""

EOF

#percentage
	gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "% of straw-man mean error"
set key above maxrows 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border noborder
#set boxwidth 0.9
set auto x

set output "plots_new_end2end/budget_delay_statistical_maxerror_barchart_percentage_p${period}_${category}_end2end.pdf"

#set xrange [0:250]

plot \
'data_new/budget_delay_percentage_p${period}_${category}_end2end' using 2:xtic(1) title col, \
        '' using 3:xtic(1) title col, \
        '' using 5:xtic(1) title col, \
        '' using 7:xtic(1) title col, \
        '' using 9:xtic(1) title col


EOF



# linegraph and bargraph

cat data_new/budget_delay_p${period}_${category}_end2end | awk 'NR>1 {print}' > /tmp/budget_delay_p${period}_${category}_end2end

# linegraph and bars
	gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set xlabel "Budget specified (bytes/sec)"
set ylabel "Mean error (meters)"
set y2label "% of straw-man mean error"

set ytics 200 nomirror
set y2tics 10

set key above maxrows 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
#set boxwidth 0.9
set auto x

set style line 1 lc rgb "#ffffd9"
set style line 2 lc rgb "#edf8b1"
set style line 3 lc rgb "#c7e9b4"
set style line 4 lc rgb "#7fcdbb"
set style line 5 lc rgb "#41b6c4"
set style line 6 lc rgb "#1d91c0"
set style line 7 lc rgb "#225ea8"
set style line 8 lc rgb "#0c2c84"


set style line 20 lc rgb "#ff0000"

set output "plots_new_end2end/budget_delay_line_barchart_p${period}_${category}_end2end.pdf"

#set xrange [0:250]

plot \
'data_new/budget_delay_percentage_p${period}_${category}_end2end' using 5:xtic(1) axes x1y2 title col ls 1, \
        '' using 7:xtic(1) axes x1y2 title col ls 2, \
        '' using 9:xtic(1) axes x1y2 title col ls 3, \
        '' using 11:xtic(1) axes x1y2 title col ls 4, \
        '' using 13:xtic(1) axes x1y2 title col ls 5, \
        '' using 15:xtic(1) axes x1y2 title col ls 6,\
'/tmp/budget_delay_p${period}_${category}_end2end' using 2 axes x1y1 with linespoints ls 20 lw 3 ti "straw-man", \

EOF


# #
# # bargraphs seperated
# #
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget specified (bytes/sec)"
# set ylabel "Mean error (meters)"
# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# set xtic rotate -45

# set output "plots_new_end2end/budget_delay_statistical_maxerror_barchart_separated_${category}_end2end.pdf"

# #set xrange [0:250]

# plot newhistogram "", \
# 'data_new/budget_delay_${category}_end2end' using 2:xtic(1) title col, \
#         '' using 3:xtic(1) title col, \
#         newhistogram "", '' using 4:xtic(1) title col, \
#         '' using 5:xtic(1) title col, \
#         newhistogram "", '' using 6:xtic(1) title col, \
#         '' using 7:xtic(1) title col


# EOF

	done
done





#############################
# error budget end-to-end
#############################
echo "error budget plots..."

#for category in "osm2" "uic" "msmls"; do
for category in "osm2"; do
	for period in $periods; do
		echo $category
# # budget vs avg delay for various errors 
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget specified (bytes/sec)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# set output "plots_new_end2end/error_budget_budget_${category}_end2end.pdf"

# set xrange [0:6]
# set yrange [0:600]

# plot \
# 'data_new/error_budget_budget_error5_${category}_extr0' using 1:3 with linespoint ti "Error=5m, const-loc" ls 2, \
# 'data_new/error_budget_budget_error5_${category}_extr2' using 1:3 with linespoint ti "Error=5m, unified" ls 3, \
# 'data_new/error_budget_budget_error50_${category}_extr0' using 1:3 with linespoint ti "Error=50m, const-loc" ls 4, \
# 'data_new/error_budget_budget_error50_${category}_extr2' using 1:3 with linespoint ti "Error=50m, unified" ls 5

# EOF

		cat data_new/error_budget_budget_p${period}_${category}_end2end | awk 'NR>1 {print}' | awk '$1>=4 {print}' > /tmp/error_budget_budget_p${period}_${category}_end2end


#
#bargraphs together
#
		gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Budget specified (bytes/sec)"
set ylabel "Mean delay (seconds)"
set key above maxrows 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border noborder
#set boxwidth 0.9
set auto x


set output "plots_new_end2end/error_budget_budget_barchart_p${period}_${category}_end2end.pdf"


#set xrange [0:250]
set multiplot
set size 1.0,1.0

plot \
'data_new/error_budget_budget_p${period}_${category}_end2end' \
        using 3:xtic(1) title col, \
        '' using 5:xtic(1) title col, \
        '' using 7:xtic(1) title col, \
        '' using 9:xtic(1) title col, \
        '' using 11:xtic(1) title col, \
        '' using 13:xtic(1) title col, \
        '' using 15:xtic(1) title col


set size 0.42,0.42
set origin 0.55,0.25
set ytics 20

set xlabel ""
set ylabel ""
plot \
'/tmp/error_budget_budget_p${period}_${category}_end2end' \
        using 3:xtic(1) title "", \
        '' using 5:xtic(1) title "", \
        '' using 7:xtic(1) title "", \
        '' using 9:xtic(1) title "", \
        '' using 11:xtic(1) title "", \
        '' using 13:xtic(1) title "", \
        '' using 15:xtic(1) title ""


EOF

# #
# # bargraphs seperated
# #
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Budget specified (bytes/sec)"
# set ylabel "Mean delay (seconds)"
# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# set xtic rotate -45

# set output "plots_new_end2end/error_budget_budget_barchart_separated_${category}_end2end.pdf"

# #set xrange [0:250]

# plot newhistogram "", \
# 'data_new/error_budget_budget_${category}_end2end' using 2:xtic(1) title col, \
#         '' using 3:xtic(1) title col, \
#         newhistogram "", '' using 4:xtic(1) title col, \
#         '' using 5:xtic(1) title col, \
#         newhistogram "", '' using 6:xtic(1) title col, \
#         '' using 7:xtic(1) title col


# EOF





####################################################


# # error vs avg delay for various budget
# gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Max error (meters)"
# set ylabel "Mean delay (sec)"
# set key above maxrows 2

# set output "plots_new_end2end/error_budget_error_${category}_end2end.pdf"

# set xrange [0:250]
# #set yrange [0:600]

# plot \
# 'data_new/error_budget_error_budget1_${category}_extr0' using 1:3 with linespoint ti "Budget=1, const-loc", \
# 'data_new/error_budget_error_budget1_${category}_extr2' using 1:3 with linespoint ti "Budget=1, unified", \
# 'data_new/error_budget_error_budget5_${category}_extr0' using 1:3 with linespoint ti "Budget=5, const-loc", \
# 'data_new/error_budget_error_budget5_${category}_extr2' using 1:3 with linespoint ti "Budget=5, unified"

# EOF

#echo "error here"

#
#bargraphs together
#
		gnuplot<<EOF
set terminal pdf font "Helvetica,11" lw 2 dashed
set xlabel "Maximum error (meters)"
set ylabel "Mean delay (seconds)"
set key above

set style data histogram
set style histogram cluster gap 1
set style fill solid border noborder
#set boxwidth 0.9
set auto x

set output "plots_new_end2end/error_budget_error_barchart_p${period}_${category}_end2end.pdf"

#set xrange [0:250]

plot \
'data_new/error_budget_error_p${period}_${category}_end2end' \
        using 3:xtic(1) title col, \
        '' using 5:xtic(1) title col, \
        '' using 7:xtic(1) title col, \
        '' using 9:xtic(1) title col, \
        '' using 11:xtic(1) title col, \
        '' using 13:xtic(1) title col


EOF

# #
# # bargraphs seperated
# #
# 	gnuplot<<EOF
# set terminal pdf font "Helvetica,12" lw 2 dashed
# set xlabel "Max error (meters)"
# set ylabel "Mean delay (seconds)"
# set key above maxrows 2

# set style data histogram
# set style histogram cluster gap 1
# set style fill solid border noborder
# #set boxwidth 0.9
# set auto x

# #set xtic rotate -45

# set output "plots_new_end2end/error_budget_error_barchart_separated_${category}_end2end.pdf"

# #set xrange [0:250]

# plot newhistogram "", \
# 'data_new/error_budget_error_${category}_end2end' using 2:xtic(1) title col, \
#         '' using 3:xtic(1) title col, \
#         newhistogram "", '' using 4:xtic(1) title col, \
#         '' using 5:xtic(1) title col, \
#         newhistogram "", '' using 6:xtic(1) title col, \
#         '' using 7:xtic(1) title col


# EOF




	done
done


