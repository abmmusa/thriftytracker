
for delay in 0 2 4 8 16 32 64 128; do
	cat data_new/error_delay_3d | awk '$2==d && $1<250 {print $1, $3}' d=$delay > /tmp/error_delay_d${delay}.txt
	cat data_new/budget_delay_p1800.0_3d | awk '$2==d && $1<250 {print $1, $3}' d=$delay > /tmp/budget_delay_d${delay}.txt

	cat data_new/error_delay_3d_unified | awk '$2==d && $1<250 {print $1, $3}' d=$delay > /tmp/error_delay_unified_d${delay}.txt
	cat data_new/budget_delay_p1800.0_3d_unified | awk '$2==d && $1<250 {print $1, $3}' d=$delay > /tmp/budget_delay_unified_d${delay}.txt
done





B=1

a=94.7
b=0.75
c=0.25
d=-0.347


gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 1 dashed
set xlabel "Mean error (meters)"
set ylabel "Data usage (bytes/sec)"
set key above maxrows 3


set xrange [10:200]
set yrange [0:]

#227/x ti "Usage=227/mean_error"


# f(x)=a/(x**p+h*x)
# g(x)=b/(x**q+i*x)
# h(x)=c/(x**r+j*x)
# i(x)=d/(x**s+k*x)

# good except g(x)
# f(x)=(a/x)*(1-(p/((1+x*g)*(1+p))))
# g(x)=(b/x)*(1-(q/((1+x*h)*(1+q))))
# h(x)=(c/x)*(1-(r/((1+x*i)*(1+r))))
# i(x)=(d/x)*(1-(s/((1+x*j)*(1+s))))


F(x)=$a/((x**$b)*(1**$c))+$d
M(x)=$a/((x**$b)*(3**$c))+$d
L(x)=$a/((x**$b)*(5**$c))+$d
G(x)=$a/((x**$b)*(9**$c))+$d
H(x)=$a/((x**$b)*(17**$c))+$d
I(x)=$a/((x**$b)*(33**$c))+$d
J(x)=$a/((x**$b)*(65**$c))+$d
K(x)=$a/((x**$b)*(129**$c))+$d


set output "plots_experimental/error_delay_and_budgt_delay_unification.pdf"
plot \
'/tmp/error_delay_d0.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d0.txt' using 1:2 with lines ti "" ,\
'/tmp/error_delay_d2.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d2.txt' using 1:2 with lines ti "" ,\
'/tmp/error_delay_d4.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d4.txt' using 1:2 with lines ti "" ,\
'/tmp/error_delay_d8.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d8.txt' using 1:2 with lines ti "" ,\
'/tmp/error_delay_d16.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d16.txt' using 1:2 with lines ti "",\
'/tmp/error_delay_d32.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d32.txt' using 1:2 with lines ti "" ,\
'/tmp/error_delay_d64.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d64.txt' using 1:2 with lines ti "",\
'/tmp/error_delay_d128.txt' using 1:2 with lines ti "" ,\
'/tmp/budget_delay_d128.txt' using 1:2 with lines ti "",\
F(x) with lines lw 3 ti "0",\
M(x) with lines lw 3 ti "2",\
L(x) with lines lw 3 ti "4",\
G(x) with lines lw 3 ti "8",\
H(x) with lines lw 3 ti "16",\
I(x) with lines lw 3 ti "32",\
J(x) with lines lw 3 ti "64",\
K(x) with lines lw 3 ti "128"

EOF


#F(x)=${a}/((x**${b})*(1**${c)})+${d}
#G(x)=${a}/((x**${b})*(9**${c}))+${d}
#H(x)=${a}/((x**${b})*(17**${c}))+${d}
#I(x)=${a}/((x**${b})*(33**${c}))+${d}
#J(x)=${a}/((x**${b})*(65**${c}))+${d}



#fit [10:] F(x) '/tmp/budget_delay_d0.txt' via a, p
#fit [10:] G(x) '/tmp/budget_delay_d8.txt' via b, q
#fit [10:] H(x) '/tmp/budget_delay_d16.txt' via c, r
#fit [10:] I(x) '/tmp/budget_delay_d32.txt' via d, s
#fit [10:] J(x) '/tmp/budget_delay_d64.txt' via e, t


#G(x) with lines lw 3 ,\
#H(x) with lines lw 3 ,\
#I(x) with lines lw 3 ,\
#J(x) with lines lw 3


#(110/x)*(1-(100/((1+x*0.1)*(1+150)))) ti ""

#(100/x)*(1-(150/((1+x*0.1)*(1+150))))



#-2.7/x+8.9/(x**0.5)+0.79 with lines lw 3 ti "8s"

#227/(x+1) with lines lw 3 ti "Fit, 0s",\
#227/(x+16)/x**.2 with lines lw 3 ti "Fit, 8s",\
#227/(x+64)/x**.2 with lines lw 3 ti "Fit, 32s",\
#227/(x+128)/x**.2 with lines lw 3 ti "Fit, 64s"

#227/(x+16)/x**.2 with lines lw 3 ti "Fit, 8s",\
#227/(x+64)/x**.2 with lines lw 3 ti "Fit, 32s",\
#227/(x+128)/x**.2 with lines lw 3 ti "Fit, 64s"


#(-64/(x+1)+128/(x+1)**.6) with lines lw 3 ti "Fit, 0s",\
#(-8/(x+1)+16/(x+1)**.6) with lines lw 3 ti "Fit, 8s",\
#(-0-2/(x+1)+4/(x+1)**.6) with lines lw 3 ti "Fit, 64s"




#(227/x)-9*10 with lines lw 3 ti "Fit, 8s",\
#(227/x)-64*10 with lines lw 3 ti "Fit, 64s",\
#(227/(x**0.5)) with lines lw 3 ti "Fit, 8s", \


#'/tmp/error_delay_d32.txt' using 1:2 with linespoint ti "ED, 32s", \
#'/tmp/budget_delay_d32.txt' using 1:2 with linespoint ti "BD, 32s", \
#(227/x)*(1-$B*32/((1+x)*(1+$B*32))) with lines lw 3 ti "Fit, 32s"




p=1800.0

cat data_new/error_budget_p${p}_3d | awk '$2>0.5 && $2<1.5 {print $1, $3}' > /tmp/error_budget_d0.txt
cat data_new/error_budget_p${p}_3d | awk '$2>7 && $2<9 {print $1, $3}' > /tmp/error_budget_d8.txt
cat data_new/error_budget_p${p}_3d | awk '$2>15 && $2<18 {print $1, $3}' > /tmp/error_budget_d16.txt
cat data_new/error_budget_p${p}_3d | awk '$2>31.5 && $2<40 {print $1, $3}' > /tmp/error_budget_d32.txt
cat data_new/error_budget_p${p}_3d | awk '$2>62 && $2<66 {print $1, $3}' > /tmp/error_budget_d64.txt
cat data_new/error_budget_p${p}_3d | awk '$2>115 && $2<140 {print $1, $3}' > /tmp/error_budget_d128.txt



p=94.7
q=0.75
r=0.25
s=-0.347

a=65.18
b=0.5
c=0.75
d=0.228


gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Mean error (meters)"
set ylabel "Usage (bytes/sec)"
set key above vertical width -2.0 maxcols 5 samplen 0.6 maxrows 3 spacing 0.9
set key font "Helvetica,11.5"

set xrange [10:150]
set yrange [0:4.5]


set ytics 1

set pointsize 1.2

F(x)=$p/((x**$q)*(1**$r))+$s
G(x)=$a/((x**$b)*(9**$c))+$d
H(x)=$a/((x**$b)*(17**$c))+$d
I(x)=$a/((x**$b)*(33**$c))+$d
J(x)=$a/((x**$b)*(65**$c))+$d
K(x)=$a/((x**$b)*(129**$c))+$d



set output "plots_experimental/all_unification.pdf"
plot \
G(x) with lines lw 2 ti "Fit, 8s",\
I(x) with lines lw 2 ti "Fit, 32s",\
K(x) with lines lw 2 ti "Fit, 128s",\
'/tmp/error_delay_d8.txt' u 1:2 pt 5 ti "Usage, 8s" ,\
'/tmp/error_delay_d32.txt' u 1:2 pt 5 ti "Usage, 32s" ,\
'/tmp/error_delay_d128.txt' u 1:2 pt 5 ti "Usage, 128s" ,\
'/tmp/budget_delay_d8.txt' u 1:2 pt 7 ti "Error, 8s" ,\
'/tmp/budget_delay_d32.txt' u 1:2 pt 7 ti "Error, 32s" ,\
'/tmp/budget_delay_d128.txt' u 1:2  pt 7 ti "Error, 128s", \
'/tmp/error_budget_d8.txt' pt 9 ti "Delay, 8s*", \
'/tmp/error_budget_d32.txt' pt 9 ti "Delay, 32s*", \
'/tmp/error_budget_d128.txt' pt 9 ti "Delay, 128s*"


EOF




#
# All unification for unified
#
p=24.6361
q=0.75
r=0.25
s=0.351604


a=65.18
b=0.5
c=0.75
d=0.228


cat data_new/error_budget_p1800.0_3d_unified | awk '$2>5 && $2<13 {print $1, $3}' > /tmp/error_budget_unified_d8.txt

gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2 dashed
set xlabel "Mean error (meters)"
set ylabel "Usage (bytes/sec)"
set key above vertical width 1 maxcols 3 samplen 0.6 maxrows 3 spacing 0.9
set key font "Helvetica,11.5"

set xrange [10:150]
set yrange [0:4.5]


set ytics 1

set pointsize 1.2



F(x)=$a/((x**$b)*(9**$c))+$d #constloc extrapolator
G(x)=$p/((x**$q)*(9**$r))+$s #unified extrapolator

set output "plots_experimental/all_unification_constloc_vs_unified.pdf"
plot \
'/tmp/error_delay_d8.txt' u 1:2 pt 5 ti "Usage, CL" ,\
'/tmp/budget_delay_d8.txt' u 1:2 pt 7 ti "Error, CL" ,\
'/tmp/error_budget_d8.txt' pt 9 ti "Delay, CL", \
'/tmp/error_delay_unified_d8.txt' u 1:2 pt 5 ti "Usage, UN" ,\
'/tmp/budget_delay_unified_d8.txt' u 1:2 pt 7 ti "Error, UN" ,\
'/tmp/error_budget_unified_d8.txt' pt 9 ti "Delay, UN", \
F(x) with lines lw 2 ti "Fit, CL" ,\
G(x) with lines lw 2 ti "Fit, UN" 



EOF




# F(x) with lines lw 3 ti "0",\
# G(x) with lines lw 3 ti "8",\
# H(x) with lines lw 3 ti "16",\
# I(x) with lines lw 3 ti "32",\
# J(x) with lines lw 3 ti "64",\
# K(x) with lines lw 3 ti "128",\
# '/tmp/error_delay_d0.txt' using 1:2 with lines ti "" ,\
# '/tmp/budget_delay_d0.txt' using 1:2 with lines ti "" ,\
# '/tmp/error_delay_d8.txt' using 1:2 with lines ti "" ,\
# '/tmp/budget_delay_d8.txt' using 1:2 with lines ti "" ,\
# '/tmp/error_delay_d16.txt' using 1:2 with lines ti "" ,\
# '/tmp/budget_delay_d16.txt' using 1:2 with lines ti "",\
# '/tmp/error_delay_d32.txt' using 1:2 with lines ti "" ,\
# '/tmp/budget_delay_d32.txt' using 1:2 with lines ti "" ,\
# '/tmp/error_delay_d64.txt' using 1:2 with lines ti "" ,\
# '/tmp/budget_delay_d64.txt' using 1:2 with lines ti "",\
# '/tmp/error_delay_d128.txt' using 1:2 with lines ti "" ,\
# '/tmp/budget_delay_d128.txt' using 1:2 with lines ti "", \
# '/tmp/error_budget_d0.txt' ti "0", \
# '/tmp/error_budget_d8.txt' ti "8", \
# '/tmp/error_budget_d16.txt' ti "16", \
# '/tmp/error_budget_d32.txt' ti "32", \
# '/tmp/error_budget_d64.txt' ti "64", \
# '/tmp/error_budget_d128.txt' ti "128"

