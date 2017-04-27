#!/bin/bash

#rm evaluator_output_osm_new/*

./evaluator_jobs_sampler_error_delay_new.sh | parallel 
wait 
./process_evals_jobs_new.sh | parallel 
wait
./scripts/process_new.sh

