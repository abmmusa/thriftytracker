#!/bin/bash

#error_bounds="1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000"

error_budget_sampler_error_bounds="1 5 10 25 50 100 200 500 1000 2000"
error_budget_sampler_budget_bounds="0.1 0.25 0.5 0.75 1 2 5 8 10 15" #bytes/sec

error_delay_sampler_error_bounds="1 5 10 25 50 100 200 500 1000 2000"
error_delay_sampler_delay_bounds="0 2 4 8 16 32 64 128 256"

budget_delay_sampler_budget_bounds="0.1 0.25 0.5 0.75 1 2 5 8 10 15" #bytes/sec
budget_delay_sampler_delay_bounds="0 2 4 8 16 32 64 128 256"

# MSMLS2
for id in 0 1 2 4 5 9 10 11 12 13 14 15 16; do
  for split in 0 1 2 3 4; do
    
    # error-budget sampler
    for sampler in 0; do
      for error_bound in $error_budget_sampler_error_bounds; do
        for budget_bound in $error_budget_sampler_budget_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls2/for_split_${split}/all/"
        done;
      done;
    done;
    
    # error-delay sampler
    for sampler in 1; do
      for error_bound in $error_delay_sampler_error_bounds; do
        for delay_bound in $error_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls2/for_split_${split}/all/"
        done;
      done;
    done;
    
    # budget-delay sampler
    for sampler in 2; do
      for budget_bound in $budget_delay_sampler_budget_bounds; do
        for delay_bound in $budget_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x1.pkl"
          
          # unified extrapolator no. 3
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls2_x3.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls2/for_split_${split}/all/"
        done;
      done;
    done;
  
  done;
done

# MSMLS
for id in 0 1 2 4 5 9 10 11 12 13 14 15 16 3 6 7 8; do
  for split in 0 1 2 3 4; do
    
    # error-budget sampler
    for sampler in 0; do
      for error_bound in $error_budget_sampler_error_bounds; do
        for budget_bound in $error_budget_sampler_budget_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x3.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x4_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -e $error_bound -b $budget_bound -o evaluator_output_msmls_new/split_${split} -m delays_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x5_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/mean/"
        done;
      done;
    done;
    
    # error-delay sampler
    for sampler in 1; do
      for error_bound in $error_delay_sampler_error_bounds; do
        for delay_bound in $error_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x3.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x4_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -e $error_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x5_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/mean/"
        done;
      done;
    done;
    
    # budget-delay sampler
    for sampler in 2; do
      for budget_bound in $budget_delay_sampler_budget_bounds; do
        for delay_bound in $budget_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x1.pkl"
          
          # unified extrapolator no. 2
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x3.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/msmls/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x4_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/msmls/split_${split}/msmls_subject_${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -b $budget_bound -d $delay_bound -o evaluator_output_msmls_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/msmls_x5_e${error_bound}.pkl -f map_matching/pickle/planet-130507_msmls_bbx.pkl -p map_matching/calculated_turn_proportions4/msmls_subject_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/msmls/for_split_${split}/mean/"
        done;
      done;
    done;
  
  done;
done

# UIC
for id in 15 2 13 0; do
  for split in 0 1 2 3 4; do
    
    # error-budget sampler
    for sampler in 0; do
      for error_bound in $error_budget_sampler_error_bounds; do
        for budget_bound in $error_budget_sampler_budget_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -b $budget_bound -o evaluator_output_uic_new/split_${split} -m delays_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -b $budget_bound -o evaluator_output_uic_new/split_${split} -m delays_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -b $budget_bound -o evaluator_output_uic_new/split_${split} -m delays_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -e $error_bound -b $budget_bound -o evaluator_output_uic_new/split_${split} -m delays_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x3.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -e $error_bound -b $budget_bound -o evaluator_output_uic_new/split_${split} -m delays_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x4_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -e $error_bound -b $budget_bound -o evaluator_output_uic_new/split_${split} -m delays_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x5_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/mean/"
        done;
      done;
    done;
    
    # error-delay sampler
    for sampler in 1; do
      for error_bound in $error_delay_sampler_error_bounds; do
        for delay_bound in $error_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x3.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x4_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -e $error_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x5_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/mean/"
        done;
      done;
    done;
    
    # budget-delay sampler
    for sampler in 2; do
      for budget_bound in $budget_delay_sampler_budget_bounds; do
        for delay_bound in $budget_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x1.pkl"
          
          # unified extrapolator no. 2
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x2_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x3.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/trees/uic/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x4_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/uic/split_${split}/uic_shuttle_${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -b $budget_bound -d $delay_bound -o evaluator_output_uic_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/uic_x5_e${error_bound}.pkl -f map_matching/pickle/planet-130507_uic_bbx.pkl -p map_matching/calculated_turn_proportions4/uic_shuttle_${id}_mm_c1_turn_proportions_for_split_${split}.txt -c unified_extrapolator_data_sources/tables/uic/for_split_${split}/mean/"
        done;
      done;
    done;
  
  done;
done

# OSM
for id in 14569 39026 48906 69173 69414; do
  for split in 0 1 2 3 4; do
    
    # error-budget sampler
    for sampler in 0; do
      for error_bound in $error_budget_sampler_error_bounds; do
        for budget_bound in $error_budget_sampler_budget_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -b $budget_bound -o evaluator_output_osm_new/split_${split} -m delays_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -b $budget_bound -o evaluator_output_osm_new/split_${split} -m delays_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -b $budget_bound -o evaluator_output_osm_new/split_${split} -m delays_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x2_e${error_bound}.pkl -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -e $error_bound -b $budget_bound -o evaluator_output_osm_new/split_${split} -m delays_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x3.pkl -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -e $error_bound -b $budget_bound -o evaluator_output_osm_new/split_${split} -m delays_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x4_e${error_bound}.pkl -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -e $error_bound -b $budget_bound -o evaluator_output_osm_new/split_${split} -m delays_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x5_e${error_bound}.pkl -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/mean/"
        done;
      done;
    done;
    
    # error-delay sampler
    for sampler in 1; do
      for error_bound in $error_delay_sampler_error_bounds; do
        for delay_bound in $error_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x1.pkl"
          
          # unified extrapolator no. 2
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x2_e${error_bound}.pkl -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x3.pkl -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x4_e${error_bound}.pkl -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -e $error_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x5_e${error_bound}.pkl -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/mean/"
        done;
      done;
    done;
    
    # budget-delay sampler
    for sampler in 2; do
      for budget_bound in $budget_delay_sampler_budget_bounds; do
        for delay_bound in $budget_delay_sampler_delay_bounds; do
          # constant location extrapolator
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 0 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x0.pkl"
          
          # constant velocity extrapolator
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 1 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x1.pkl"
          
          # unified extrapolator no. 2
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 2 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x2_e${error_bound}.pkl -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/"
          
          # unified extrapolator no. 3
          echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 3 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x3.pkl -c unified_extrapolator_data_sources/trees/osm/for_split_${split}/all/"
          
          # unified extrapolator no. 4
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 4 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x4_e${error_bound}.pkl -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/median/"
          
          # unified extrapolator no. 5
          #echo "gunzip -c split_traces/osm/split_${split}/${id}.txt.gz | python evaluator_new.py -s $sampler -x 5 -b $budget_bound -d $delay_bound -o evaluator_output_osm_new/split_${split}/ -i $id -t expected_reachtime_for_exponentialerror_offline_wo_hump/osm_x5_e${error_bound}.pkl -c unified_extrapolator_data_sources/tables/osm/for_split_${split}/mean/"
        done;
      done;
    done;
  
  done;
done
