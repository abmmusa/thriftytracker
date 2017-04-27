#!/bin/bash

# separate image plots

gnuplot<<EOF
set terminal png font "Helvetica,12" 
set xlabel "Mean error (meters)"
set ylabel "Mean delay (sec)"


set xrange [:100]
set yrange [:60]
set zrange [:8]

set pm3d map clip1in interpolate 10,10

set output "plots_new/error_delay_image_3d.png"
splot 'data_new/error_delay_3d' ti ""

set output "plots_new/budget_delay_image_3d.png"
splot 'data_new/budget_delay_3d' ti ""

set output "plots_new/error_budget_image_3d.png"
splot 'data_new/error_budget_p3600.0_3d' ti ""


set pm3d map clip1in interpolate 10,10

set xlabel "Mean delay (sec)"
set ylabel "Mean usage (bytes/sec)"

set xrange [:60]
set yrange [:8]
set zrange [:100]


set output "plots_new/zerror_error_delay_image_3d.png"
splot 'data_new/error_delay_3d' using 2:3:1 ti ""

set output "plots_new/zerror_budget_delay_image_3d.png"
splot 'data_new/budget_delay_3d' using 2:3:1 ti ""

set output "plots_new/zerror_error_budget_image_3d.png"
splot 'data_new/error_budget_p3600.0_3d' using 2:3:1 ti ""




set pm3d map clip1in interpolate 10,10

set xlabel "Mean delay (sec)"
set ylabel "Mean usage (bytes/sec)"

set xrange [:100]
set yrange [:5]
set zrange [:60]


set output "plots_new/zdelay_error_delay_image_3d.png"
splot 'data_new/error_delay_3d' using 1:3:2 ti ""

set output "plots_new/zdelay_budget_delay_image_3d.png"
splot 'data_new/budget_delay_3d' using 1:3:2 ti ""

set output "plots_new/zdelay_error_budget_image_3d.png"
splot 'data_new/error_budget_p3600.0_3d' using 1:3:2 ti ""



EOF