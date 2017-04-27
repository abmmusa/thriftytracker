for file in `ls ../traces/uic/uic_shuttle_*.txt.gz`; do
  file_no_prefix=${file#../traces/uic/};
  for c in 1 300; do
    echo "gunzip -c $file | python pylibs/OSMMatcher_run.py -f pickle/planet-130507_uic_bbx.pkl -c $c | gzip > matched_traces4/"${file_no_prefix%.txt.gz}_mm_c${c}.txt.gz
  done
done > uic_mm_jobs.txt

for file in `ls ../traces/msmls/msmls_subject_*.txt.gz`; do
  file_no_prefix=${file#../traces/msmls/};
  for c in 1 300; do
    echo "gunzip -c $file | python pylibs/OSMMatcher_run.py -f pickle/planet-130507_msmls_bbx.pkl -c $c | gzip > matched_traces4/"${file_no_prefix%.txt.gz}_mm_c${c}.txt.gz
  done
done > msmls_mm_jobs.txt

for file in `ls ../traces/osm2/osm2_subject_*.txt.gz`; do
  file_no_prefix=${file#../traces/osm2/};
  for c in 1 300; do
    echo "gunzip -c $file | python pylibs/OSMMatcher_run.py -f pickle/moscow-140114_300km.pkl -c $c | gzip > matched_traces4/"${file_no_prefix%.txt.gz}_mm_c${c}.txt.gz
  done
done > osm2_mm_jobs.txt
