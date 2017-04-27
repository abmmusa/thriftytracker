#for i in 0 1 2 3 4; do
#  for file in `ls matched_traces4/split_${i}/*_mm_c1.txt.gz`; do
#    file_no_prefix=${file#matched_traces4/split_${i}/}
#    echo "gunzip -c $file | python node_sequence_extractor.py | gzip > extracted_node_sequences4/split_${i}/${file_no_prefix%.txt.gz}_node_sequences.txt.gz"
#  done;
#done > nse_jobs.txt

#for file in `ls matched_traces4/*_mm_c1.txt.gz`; do
#  file_no_prefix=${file#matched_traces4/}
#  echo "gunzip -c $file | python node_sequence_extractor.py | gzip > extracted_node_sequences4/${file_no_prefix%.txt.gz}_node_sequences.txt.gz"
#done > nse_jobs.txt

#for i in `seq 0 15`; do
#  echo "gunzip -c matched_traces4/osm_subject_${i}_mm_c300.txt.gz | python node_sequence_extractor.py | gzip > extracted_node_sequences4/osm_subject_${i}_mm_c300_node_sequences.txt.gz"
#done > nse_jobs.txt

#for i in `seq 16 63`; do
#  echo "gunzip -c matched_traces4/osm_subject_${i}_mm_c1.txt.gz | python node_sequence_extractor.py | gzip > extracted_node_sequences4/osm_subject_${i}_mm_c1_node_sequences.txt.gz"
#done >> nse_jobs.txt

for i in `seq 0 7`; do gunzip -c matched_traces4/osm2_subject_${i}_mm_c300.txt.gz | python node_sequence_extractor.py; done | gzip > extracted_node_sequences4/osm2_subject_0_7_mm_c300_node_sequences.txt.gz

for i in `seq 8 15`; do gunzip -c matched_traces4/osm2_subject_${i}_mm_c300.txt.gz | python node_sequence_extractor.py; done | gzip > extracted_node_sequences4/osm2_subject_8_15_mm_c300_node_sequences.txt.gz
