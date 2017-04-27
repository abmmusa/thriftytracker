#!/bin/bash

#rm evaluator_output_osm_new/*

./evaluator_jobs_sampler_budget_delay_new.sh | parallel -j 13
wait 
./process_evals_jobs_new.sh | parallel -j 13
wait
./scripts/process_new.sh

