for file in `ls msmls_subject_*_mm_c1_mated.txt.gz`; do
  cp $file ../../traces/msmls/${file%_mm_c1_mated.txt.gz}.txt.gz
done

for i in 0 1 2 3 4; do
  #rm -rf ../../split_traces/msmls/split_${i}/
  #mkdir ../../split_traces/msmls/split_${i}/
  
  for file in `ls split_${i}/msmls_subject_*_mm_c1_mated.txt.gz`; do
    file_no_prefix=${file#split_${i}/}
    cp $file ../../split_traces/msmls/split_${i}/${file_no_prefix%_mm_c1_mated.txt.gz}.txt.gz
  done
done


for file in `ls uic_shuttle_*_mm_c1_mated.txt.gz`; do
  cp $file ../../traces/uic/${file%_mm_c1_mated.txt.gz}.txt.gz
done

for i in 0 1 2 3 4; do
  #rm -rf ../../split_traces/uic/split_${i}/
  #mkdir ../../split_traces/uic/split_${i}/
  
  for file in `ls split_${i}/uic_shuttle_*_mm_c1_mated.txt.gz`; do
    file_no_prefix=${file#split_${i}/}
    cp $file ../../split_traces/uic/split_${i}/${file_no_prefix%_mm_c1_mated.txt.gz}.txt.gz
  done
done
