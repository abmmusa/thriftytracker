===========
MSMLS & UIC
===========

echo -n "" > extrapolators_error_threshold_mean_max_duration.txt

for e in 1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000; do
  echo -n $e" " >> extrapolators_error_threshold_mean_max_duration.txt
  for x in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_e${e}_i*.txt.gz
    done > values_for_plots.txt
    
    mean=`cat values_for_plots.txt | column 4 | mean`
    echo -n $mean" " >> extrapolators_error_threshold_mean_max_duration.txt
  done;
  echo "" >> extrapolators_error_threshold_mean_max_duration.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_error_threshold_median_max_duration.txt

for e in 1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000; do
  echo -n $e" " >> extrapolators_error_threshold_median_max_duration.txt
  for x in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_e${e}_i*.txt.gz
    done > values_for_plots.txt
    
    median=`cat values_for_plots.txt | column 4 | median`
    echo -n $median" " >> extrapolators_error_threshold_median_max_duration.txt
  done;
  echo "" >> extrapolators_error_threshold_median_max_duration.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_duration_threshold_mean_mean_error.txt

for d in 1 5 10 15 30 45 60 90 120 240 360 480 600 900; do
  echo -n $d" " >> extrapolators_duration_threshold_mean_mean_error.txt
  for x in 0 1 2 3 4 5 6 7 8 9 10 11 13 16 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_dm${d}_i*.txt.gz
    done > values_for_plots.txt
    
    mean=`cat values_for_plots.txt | column 4 | mean`
    echo -n $mean" " >> extrapolators_duration_threshold_mean_mean_error.txt
  done;
  echo "" >> extrapolators_duration_threshold_mean_mean_error.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_duration_threshold_mean_max_error.txt

for d in 1 5 10 15 30 45 60 90 120 240 360 480 600 900; do
  echo -n $d" " >> extrapolators_duration_threshold_mean_max_error.txt
  for x in 0 1 2 3 4 5 6 7 8 9 10 11 13 16 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_dx${d}_i*.txt.gz
    done > values_for_plots.txt
    
    mean=`cat values_for_plots.txt | column 4 | mean`
    echo -n $mean" " >> extrapolators_duration_threshold_mean_max_error.txt
  done;
  echo "" >> extrapolators_duration_threshold_mean_max_error.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_duration_threshold_median_max_error.txt

for d in 1 5 10 15 30 45 60 90 120 240 360 480 600 900; do
  echo -n $d" " >> extrapolators_duration_threshold_median_max_error.txt
  for x in 0 1 2 3 4 5 6 7 8 9 10 11 13 16 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_dx${d}_i*.txt.gz
    done > values_for_plots.txt
    
    median=`cat values_for_plots.txt | column 4 | median`
    echo -n $median" " >> extrapolators_duration_threshold_median_max_error.txt
  done;
  echo "" >> extrapolators_duration_threshold_median_max_error.txt
done
rm values_for_plots.txt

===
OSM
===

echo -n "" > extrapolators_error_threshold_mean_max_duration.txt

for e in 1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000; do
  echo -n $e" " >> extrapolators_error_threshold_mean_max_duration.txt
  for x in 0 1 2 3 12 13 14 15 16 17 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_e${e}_i*.txt.gz
    done > values_for_plots.txt
    
    mean=`cat values_for_plots.txt | column 4 | mean`
    echo -n $mean" " >> extrapolators_error_threshold_mean_max_duration.txt
  done;
  echo "" >> extrapolators_error_threshold_mean_max_duration.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_error_threshold_median_max_duration.txt

for e in 1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000; do
  echo -n $e" " >> extrapolators_error_threshold_median_max_duration.txt
  for x in 0 1 2 3 12 13 14 15 16 17 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_e${e}_i*.txt.gz
    done > values_for_plots.txt
    
    median=`cat values_for_plots.txt | column 4 | median`
    echo -n $median" " >> extrapolators_error_threshold_median_max_duration.txt
  done;
  echo "" >> extrapolators_error_threshold_median_max_duration.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_duration_threshold_mean_mean_error.txt

for d in 1 5 10 15 30 45 60 90 120 240 360 480 600 900; do
  echo -n $d" " >> extrapolators_duration_threshold_mean_mean_error.txt
  for x in 0 1 2 3 13 16 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_dm${d}_i*.txt.gz
    done > values_for_plots.txt
    
    mean=`cat values_for_plots.txt | column 4 | mean`
    echo -n $mean" " >> extrapolators_duration_threshold_mean_mean_error.txt
  done;
  echo "" >> extrapolators_duration_threshold_mean_mean_error.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_duration_threshold_mean_max_error.txt

for d in 1 5 10 15 30 45 60 90 120 240 360 480 600 900; do
  echo -n $d" " >> extrapolators_duration_threshold_mean_max_error.txt
  for x in 0 1 2 3 13 16 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_dx${d}_i*.txt.gz
    done > values_for_plots.txt
    
    mean=`cat values_for_plots.txt | column 4 | mean`
    echo -n $mean" " >> extrapolators_duration_threshold_mean_max_error.txt
  done;
  echo "" >> extrapolators_duration_threshold_mean_max_error.txt
done
rm values_for_plots.txt

echo -n "" > extrapolators_duration_threshold_median_max_error.txt

for d in 1 5 10 15 30 45 60 90 120 240 360 480 600 900; do
  echo -n $d" " >> extrapolators_duration_threshold_median_max_error.txt
  for x in 0 1 2 3 13 16 99; do
    for s in `seq 0 4`; do
      gunzip -c split_${s}/sample_time_table_x${x}_dx${d}_i*.txt.gz
    done > values_for_plots.txt
    
    median=`cat values_for_plots.txt | column 4 | median`
    echo -n $median" " >> extrapolators_duration_threshold_median_max_error.txt
  done;
  echo "" >> extrapolators_duration_threshold_median_max_error.txt
done
rm values_for_plots.txt

