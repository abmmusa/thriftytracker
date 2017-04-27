#!/bin/bash

for provider in "msmls" "uic" "osm"; do
  for extrapolator in 0 1 2; do
    echo "python process_evals_new.py -s 0 -x $extrapolator -i evaluator_output_${provider}_new/ -o processed_evals_output_${provider}_new/ -m delays_${provider}_new/"
  done;
  
  for extrapolator in 0 1 2; do
    echo "python process_evals_new.py -s 1 -x $extrapolator -i evaluator_output_${provider}_new/ -o processed_evals_output_${provider}_new/"
  done;
  
  for extrapolator in 0 1 3; do
    echo "python process_evals_new.py -s 2 -x $extrapolator -i evaluator_output_${provider}_new/ -o processed_evals_output_${provider}_new/"
  done;
done
