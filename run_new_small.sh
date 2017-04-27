#!/bin/bash

./evaluator_jobs_sampler_new_small.sh | parallel
wait
./process_evals_jobs_new_small.sh | parallel
wait
./scripts/process_new_small.sh

