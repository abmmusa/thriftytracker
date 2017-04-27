#!/bin/bash

# #
# # no delay
# #
# budget_bounds="0.1640625 2.625 5.25"
# trace_files="69414.txt.gz 14569.txt.gz"
# periods="600 3600 7200"
# functions="linear exp"

# for budget in $budget_bounds; do
# 	for trace in $trace_files; do
# 		for period in $periods; do
# 			for function in $functions; do
# 				cat data_debug/data_fun${function}_id${trace}_p${period}_b${budget} | awk '$7==1 {print NR, $7}' > /tmp/data_fun${function}_id${trace}_p${period}_b${budget}
		
# 				gnuplot<<EOF
# set terminal pdf font "Helvetica,10" lw 2 dashed

# set output "plots_debug/plot_fun${function}_id${trace}_p${period}_b${budget}_meanerror.pdf"
# plot \
# 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 1 with lines ti "Mean error" axis x1y1, \
# 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 6 with lines ti "Factor" axis x1y2 

# set output "plots_debug/plot_fun${function}_id${trace}_p${period}_b${budget}_experror.pdf"
# plot 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 2 with lines ti "Expected error" 

# set output "plots_debug/plot_fun${function}_id${trace}_p${period}_b${budget}_savings_expense.pdf"
# plot \
# 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 3 with lines ti "Savings", \
# 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 4 with lines ti "Expense" 

# set output "plots_debug/plot_fun${function}_id${trace}_p${period}_b${budget}_balance.pdf"
# plot 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 5 with lines ti "Balance" 

# set logscale y
# set output "plots_debug/plot_fun${function}_id${trace}_p${period}_b${budget}_factor.pdf"
# plot 'data_debug/data_fun${function}_id${trace}_p${period}_b${budget}' using 6 with lines ti "Factor" 
# unset logscale y

# set output "plots_debug/plot_fun${function}_id${trace}_p${period}_b${budget}_tx.pdf"
# plot '/tmp/data_fun${function}_id${trace}_p${period}_b${budget}' using 1:2 with points ti "Tx" 


# EOF
# 			done
# 		done
# 	done
# done





#
# with delay
#
budget_bounds="0.1640625 2.625 5.25"
trace_files="69414.txt.gz 14569.txt.gz"
delays="8 128"

for budget in $budget_bounds; do
	for trace in $trace_files; do
		for delay in $delays; do
			cat data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay} | awk '$7==1 {print NR, $7}' > /tmp/data_funlinear_id${trace}_p7200_b${budget}_d${delay}
		
			gnuplot<<EOF
set terminal pdf font "Helvetica,10" lw 2 dashed

set output "plots_debug/plot_funlinear_id${trace}_p7200_b${budget}_d${delay}_meanerror.pdf"
plot \
'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 1 with lines ti "Mean error" axis x1y1, \
'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 6 with lines ti "Factor" axis x1y2 

set output "plots_debug/plot_funlinear_id${trace}_p7200_b${budget}_d${delay}_experror.pdf"
plot 'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 2 with lines ti "Expected error" 

set output "plots_debug/plot_funlinear_id${trace}_p7200_b${budget}_d${delay}_savings_expense.pdf"
plot \
'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 3 with lines ti "Savings", \
'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 4 with lines ti "Expense" 

set output "plots_debug/plot_funlinear_id${trace}_p7200_b${budget}_d${delay}_balance.pdf"
plot 'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 5 with lines ti "Balance" 

#set logscale y
set output "plots_debug/plot_funlinear_id${trace}_p7200_b${budget}_d${delay}_factor.pdf"
plot 'data_debug/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 6 with lines ti "Factor" 
unset logscale y

set output "plots_debug/plot_funlinear_id${trace}_p7200_b${budget}_d${delay}_tx.pdf"
plot '/tmp/data_funlinear_id${trace}_p7200_b${budget}_d${delay}' using 1:2 with points ti "Tx" 


EOF
		done
	done
done



