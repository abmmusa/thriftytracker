#for file in `ls ../traces/uic/uic_shuttle_*.txt.gz`; do
#  file_no_prefix=${file#../traces/uic/};
#  for c in 1; do
#    echo "gunzip -c $file | python mm_trip_mater.py -m matched_traces4/${file_no_prefix%.txt.gz}_mm_c${c}.txt.gz | gzip > mm_mated_trips4/${file_no_prefix%.txt.gz}_mm_c${c}_mated.txt.gz"
#  done;
#done > mmtm_jobs.txt

#for file in `ls ../traces/msmls/msmls_subject_*.txt.gz`; do
#  file_no_prefix=${file#../traces/msmls/};
#  for c in 1; do
#    echo "gunzip -c $file | python mm_trip_mater.py -m matched_traces4/${file_no_prefix%.txt.gz}_mm_c${c}.txt.gz | gzip > mm_mated_trips4/${file_no_prefix%.txt.gz}_mm_c${c}_mated.txt.gz"
#  done;
#done >> mmtm_jobs.txt

for i in `seq 0 15`; do
  echo "gunzip -c ../traces/osm2/osm2_subject_${i}.txt.gz | python mm_trip_mater.py -m matched_traces4/osm2_subject_${i}_mm_c300.txt.gz | gzip > mm_mated_trips4/osm2_subject_${i}_mm_c300_mated.txt.gz"
done > mmtm_jobs.txt

for i in `seq 16 63`; do
  echo "gunzip -c ../traces/osm2/osm2_subject_${i}.txt.gz | python mm_trip_mater.py -m matched_traces4/osm2_subject_${i}_mm_c1.txt.gz | gzip > mm_mated_trips4/osm2_subject_${i}_mm_c1_mated.txt.gz"
done >> mmtm_jobs.txt
