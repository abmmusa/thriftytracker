Some directories are used locally to avoid committing too many files in the svn. The final data used for generating plots are only committed to svn. The plots are also kept locally as they will change a lot over time. All the local directories that the scripts will need are given below. Create them locally.

evaluator_output_msmls
evaluator_output_osm
evaluator_output_uic
processed_evals_output_msmls
processed_evals_output_osm
processed_evals_output_uic
plots

The overall evaluation process is given below. I run everything in the server that produces data/* and then commit to get them locally and produce the plots.
Run 1 to 3 in the server. And 4 in the local machine.

1. Run jobs using parallel for a specific sampler. In the job script, change data or extrapolator as necessary at the top. It might be better to test a single data-set (or even subset of that) with a particular extrapolator to run things quickly. Example command is given below. This will produce output files at evaluator_output_<category>

    ./evaluator_new_jobs_script.sh | parallel

2. Combine the split results

   ./evaluator_new_results_combine.sh

2. Process the evaluator output with parallel with the command below. Change data-set, extrapolator on the top of the script. Comment/uncomment a sampler as it is used/unused. This will produce results in the processed_evals_output_<category>

    ./process_evals_jobs_new_e2e.sh | parallel

3. Process the evaluation data using the command below. Similar to previous scripts comment/uncomment whatever necessary to produce the results quickly.

    ./scripts/process_new_e2e.sh

->> data_new/
[] update parameters

[COMMIT now. This will commit the data files]

4. Generate the plots using:
    
    cp data_new/*_strawman_* data_new_e2e/
    ./scripts/plot_new_e2e.sh

-->> reads from data_new/
plots_new/


=================================================
Producing statistical tables:
-----------------------------
./offline_table_exponential_jobs.sh | parallel