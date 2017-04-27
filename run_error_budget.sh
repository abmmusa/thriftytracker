#!/bin/bash


./evaluator_jobs_sampler_error_budget_new.sh | parallel 
wait 
./process_evals_jobs_new.sh | parallel 
wait
./scripts/process_new.sh

