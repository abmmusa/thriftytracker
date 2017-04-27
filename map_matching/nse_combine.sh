target_split=0
for file in `ls extracted_node_sequences4/split_${target_split}/*_node_sequences.txt.gz`; do
  file_no_prefix=${file#extracted_node_sequences4/split_${target_split}/}
  target_file=${file_no_prefix%.txt.gz}_for_split_${target_split}.txt.gz
  echo -n "" | gzip > extracted_node_sequences4/$target_file
  
  for i in 1 2 3 4; do
    gunzip -c extracted_node_sequences4/split_${i}/$file_no_prefix | gzip >> extracted_node_sequences4/$target_file
  done;
done

target_split=1
for file in `ls extracted_node_sequences4/split_${target_split}/*_node_sequences.txt.gz`; do
  file_no_prefix=${file#extracted_node_sequences4/split_${target_split}/}
  target_file=${file_no_prefix%.txt.gz}_for_split_${target_split}.txt.gz
  echo -n "" | gzip > extracted_node_sequences4/$target_file
  
  for i in 2 3 4 0; do
    gunzip -c extracted_node_sequences4/split_${i}/$file_no_prefix | gzip >> extracted_node_sequences4/$target_file
  done;
done

target_split=2
for file in `ls extracted_node_sequences4/split_${target_split}/*_node_sequences.txt.gz`; do
  file_no_prefix=${file#extracted_node_sequences4/split_${target_split}/}
  target_file=${file_no_prefix%.txt.gz}_for_split_${target_split}.txt.gz
  echo -n "" | gzip > extracted_node_sequences4/$target_file
  
  for i in 3 4 0 1; do
    gunzip -c extracted_node_sequences4/split_${i}/$file_no_prefix | gzip >> extracted_node_sequences4/$target_file
  done;
done

target_split=3
for file in `ls extracted_node_sequences4/split_${target_split}/*_node_sequences.txt.gz`; do
  file_no_prefix=${file#extracted_node_sequences4/split_${target_split}/}
  target_file=${file_no_prefix%.txt.gz}_for_split_${target_split}.txt.gz
  echo -n "" | gzip > extracted_node_sequences4/$target_file
  
  for i in 4 0 1 2; do
    gunzip -c extracted_node_sequences4/split_${i}/$file_no_prefix | gzip >> extracted_node_sequences4/$target_file
  done;
done

target_split=4
for file in `ls extracted_node_sequences4/split_${target_split}/*_node_sequences.txt.gz`; do
  file_no_prefix=${file#extracted_node_sequences4/split_${target_split}/}
  target_file=${file_no_prefix%.txt.gz}_for_split_${target_split}.txt.gz
  echo -n "" | gzip > extracted_node_sequences4/$target_file
  
  for i in 0 1 2 3; do
    gunzip -c extracted_node_sequences4/split_${i}/$file_no_prefix | gzip >> extracted_node_sequences4/$target_file
  done;
done
