#for i in "0" "1" "2" "3" "4" "01" "02" "03" "04" "12" "13" "14" "23" "24" "34"; do
#  for file in `ls extracted_node_sequences4/*_node_sequences_for_split_${i}.txt.gz`; do
#    file_no_prefix=${file#extracted_node_sequences4/}
#    echo "gunzip -c $file | python turn_proportion_calculator.py -w 11 > calculated_turn_proportions4/${file_no_prefix%_node_sequences_for_split_${i}.txt.gz}_turn_proportions_for_split_${i}.txt"
#  done;
#done > tpc_jobs.txt

#for file in `ls extracted_node_sequences4/*_node_sequences.txt.gz`; do 
#  file_no_prefix=${file#extracted_node_sequences4/}
#  echo "gunzip -c $file | python turn_proportion_calculator.py -w 11 > calculated_turn_proportions4/${file_no_prefix%_node_sequences.txt.gz}_turn_proportions.txt"
#done > tpc_jobs.txt

#for i in `seq 0 15`; do
#  echo "gunzip -c extracted_node_sequences4/osm_subject_${i}_mm_c300_node_sequences.txt.gz | python turn_proportion_calculator.py -w 11 > calculated_turn_proportions4/osm_subject_${i}_mm_c300_turn_proportions.txt"
#done > tpc_jobs.txt

#for i in `seq 16 63`; do
#  echo "gunzip -c extracted_node_sequences4/osm_subject_${i}_mm_c1_node_sequences.txt.gz | python turn_proportion_calculator.py -w 11 > calculated_turn_proportions4/osm_subject_${i}_mm_c1_turn_proportions.txt"
#done >> tpc_jobs.txt

gunzip -c extracted_node_sequences4/osm2_subject_0_7_mm_c300_node_sequences.txt.gz | python turn_proportion_calculator.py -w 11 > calculated_turn_proportions4/osm2_subject_0_7_mm_c300_turn_proportions.txt

gunzip -c extracted_node_sequences4/osm2_subject_8_15_mm_c300_node_sequences.txt.gz | python turn_proportion_calculator.py -w 11 > calculated_turn_proportions4/osm2_subject_8_15_mm_c300_turn_proportions.txt
