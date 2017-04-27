#!/bin/bash

error_budget_sampler_error_bounds="1 5 10 25 50 100 200 500 1000 2000"
error_budget_sampler_budget_bounds="0.1 0.25 0.5 0.75 1 2 5 8 10 15" #bytes/sec

error_delay_sampler_error_bounds="1 5 10 25 50 100 200 500 1000 2000"
error_delay_sampler_delay_bounds="0 2 4 8 16 32 64 128 256"

budget_delay_sampler_budget_bounds="0.1 0.25 0.5 0.75 1 2 5 8 10 15" #bytes/sec
budget_delay_sampler_delay_bounds="0 2 4 8 16 32 64 128 256"

########################
# error budget sampler
########################

for provider in "msmls" "uic" "osm"; do
  for extrapolator in 0 1 2; do
    
    # budget vs avg delay for various errors
    for budget in $error_budget_sampler_budget_bounds; do
      for error in $error_budget_sampler_error_bounds; do
        cat processed_evals_output_${provider}_new/processed_eval_s0_x${extrapolator}.txt | awk '{print $4, $3, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==e {print}' e=$error > data_new_e2e/"error_budget_budget_error"${error}"_"${provider}"_extr"${extrapolator}
      done;
    done;
    
    # error vs avg delay for various budget
    for error in $error_budget_sampler_error_bounds; do
      for budget in $error_budget_sampler_budget_bounds; do
        cat processed_evals_output_${provider}_new/processed_eval_s0_x${extrapolator}.txt | awk '{print $3, $4, $11}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==b {print}' b=$budget > data_new_e2e/"error_budget_error_budget"${budget}"_"${provider}"_extr"${extrapolator}
      done;
    done;
  
  done;
done

########################
# error-delay sampler
#######################

for provider in "msmls" "uic" "osm"; do
  for extrapolator in 0 1 2; do
    
    # straw-man single sample [max-error vs budget(bytes/sec) plot]
    #cat processed_evals_output_${provider}_new/processed_eval_s3_x${extrapolator}.txt | awk '{print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new_e2e/error_delay_strawman_${provider}"_extr"${extrapolator}
    
    # straw-man full window
    #cat processed_evals_output_${provider}_new/processed_eval_s5_x${extrapolator}.txt | awk '{print $3,  $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new_e2e/error_delay_strawman_window_${provider}"_extr"${extrapolator}
    
    # [max-error vs budget(bytes/sec)]
    for delay in $error_delay_sampler_delay_bounds; do
      cat processed_evals_output_${provider}_new/processed_eval_s1_x${extrapolator}.txt | awk '{print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay > data_new_e2e/"error_delay_delay"${delay}"_"${provider}"_extr"${extrapolator}
    done;
    
    # [delay vs budget(bytes/sec) plot]
    for max_error in $error_delay_sampler_error_bounds; do
      cat processed_evals_output_${provider}_new/processed_eval_s1_x${extrapolator}.txt | awk '{print $3, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$1==e {print}' e=$max_error > data_new_e2e/"error_delay_error"${max_error}"_"${provider}"_extr"${extrapolator}
    done;
  
  done;
done

########################
# budget delay sampler
########################

for provider in "msmls" "uic" "osm"; do
  for extrapolator in 0 1 3; do
    
    #straw-man single sample
    #cat processed_evals_output_${provider}_new/processed_eval_s4_x${extrapolator}.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new_e2e/budget_delay_strawman_${provider}"_extr"${extrapolator}
    
    #straw-man full window (compressed)
    #cat processed_evals_output_${provider}_new/processed_eval_s6_x${extrapolator}.txt | awk '{print $4, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n > data_new_e2e/budget_delay_strawman_window_${provider}"_extr"${extrapolator}
    
    #budget_delay sampler [mean-error vs budget plot]
    for delay in $budget_delay_sampler_delay_bounds; do
      cat processed_evals_output_${provider}_new/processed_eval_s2_x${extrapolator}.txt | awk '{print $4, $5, $7, $9/$10}' | sed 's/d//; s/e//; s/b//' | sort -n -k 1 -k 2 | awk '$2==d {print}' d=$delay > data_new_e2e/"budget_delay_delay"${delay}"_"${provider}"_extr"${extrapolator}
    done;
  
  done;
done
