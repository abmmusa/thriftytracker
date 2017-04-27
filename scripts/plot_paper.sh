gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Balance (bytes)"
set ylabel "Factor"
set key above maxrows 2

#set xtic rotate by -60

set output "plots_new/budget_delay_factor_function1.pdf"
plot [-100000:100000]  (x<=2000 ? 1-x/57600 : 1/0) ls 1 ti "", (x>=0 ? 1/(1+x/57600) : 1/0) ls 1 ti "", 1 with lines ls 2 lt rgb "black" ti ""


set output "plots_new/budget_delay_factor_function.pdf"
plot [-10000:10000]  (x<=200 ? 1-(x/3600) : 1/0) ls 1 ti "", (x>=0 ? 1/(1+x/3600) : 1/0) ls 1 ti "", 1 with lines ls 2 lt rgb "black" ti ""

EOF