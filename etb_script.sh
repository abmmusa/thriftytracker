for i in 0 1 2 4 5 9 10 11 12 13 14 15 16 3 6 7 8; do
  # basic extrapolators
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -i $i -x 0"
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -i $i -x 1"
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -i $i -x 2"
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -i $i -x 3"
  
  # stop at intersection
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -i $i -x 4"
  
  # travel along in straight direction
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -i $i -x 5"
  
  # generic turn proportions
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -g /home/james/sensys13/map_matching/osmdb/planet-121114_msmls_generic_turn_probs.txt -i $i -x 6"
  
  # generic turn proportions w/straight road
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -g /home/james/sensys13/map_matching/osmdb/planet-121114_msmls_generic_turn_probs.txt -i $i -x 7"
  
  # trace-based turn proportions
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/msmls_subject_${i}_mm_m0_turn_proportions.txt -i $i -x 8"
  
  # trace-based turn proportions w/straight road
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/msmls_subject_${i}_mm_m0_turn_proportions.txt -i $i -x 9"
  
  # trace-based turn proportions (10th-order Markov Model)
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/msmls_subject_${i}_mm_m0_turn_proportions.txt -i $i -x 10"
  
  # trace-based turn proportions w/straight road (10th-order Markov Model)
  echo "gunzip -c /home/james/sensys13/traces/msmls/msmls_subject_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_msmls/ -m /home/james/sensys13/map_matching/pickle/planet-121114_msmls_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/msmls_subject_${i}_mm_m0_turn_proportions.txt -i $i -x 11"
done > msmls_etb_jobs.txt

=====

for i in 14569 39026 48906 69173 69414; do
  # basic extrapolators
  echo "gunzip -c /home/james/sensys13/traces/osm/${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_osm/ -i $i -x 0"
  echo "gunzip -c /home/james/sensys13/traces/osm/${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_osm/ -i $i -x 1"
  echo "gunzip -c /home/james/sensys13/traces/osm/${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_osm/ -i $i -x 2"
  echo "gunzip -c /home/james/sensys13/traces/osm/${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_osm/ -i $i -x 3"
done > osm_uic_etb_jobs.txt

for i in 15 2 13 0; do
  # basic extrapolators
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -i $i -x 0"
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -i $i -x 1"
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -i $i -x 2"
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -i $i -x 3"
  
  # stop at intersection
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -i $i -x 4"
  
  # travel along in straight direction
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -i $i -x 5"
  
  # generic turn proportions
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -g /home/james/sensys13/map_matching/osmdb/planet-121114_uic_generic_turn_probs.txt -i $i -x 6"
  
  # generic turn proportions w/straight road
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -g /home/james/sensys13/map_matching/osmdb/planet-121114_uic_generic_turn_probs.txt -i $i -x 7"
  
  # trace-based turn proportions
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/uic_shuttle_${i}_mm_m0_turn_proportions.txt -i $i -x 8"
  
  # trace-based turn proportions w/straight road
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/uic_shuttle_${i}_mm_m0_turn_proportions.txt -i $i -x 9"
  
  # trace-based turn proportions (10th-order Markov Model)
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/uic_shuttle_${i}_mm_m0_turn_proportions.txt -i $i -x 10"
  
  # trace-based turn proportions w/straight road (10th-order Markov Model)
  echo "gunzip -c /home/james/sensys13/traces/uic/uic_shuttle_${i}.txt.gz | python /home/james/sensys13/extrapolator_testbench.py -o /home/james/sensys13/extrapolator_testbench_output_uic/ -m /home/james/sensys13/map_matching/pickle/planet-121114_uic_bbx.pkl -t /home/james/sensys13/map_matching/calculated_turn_proportions3/uic_shuttle_${i}_mm_m0_turn_proportions.txt -i $i -x 11"
done >> osm_uic_etb_jobs.txt
