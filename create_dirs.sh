periods="3600.0 14400.0 57600.0 230400.0"

for category in "msmls" "msmls2" "uic" "osm"; do
	for period in $periods; do
		mkdir -p evaluator_output_p${period}_${category}_new
		mkdir -p delays_p${period}_${category}_new
		mkdir -p processed_evals_output_p${period}_${category}_new

		for split in 0 1 2 3 4; do
			mkdir -p evaluator_output_p${period}_${category}_new/split_$split
			mkdir -p delays_p${period}_${category}_new/split_$split
		done
	done
done

for category in "osm2"; do
	for period in $periods; do
		mkdir -p evaluator_output_p${period}_${category}_new
		mkdir -p delays_p${period}_${category}_new
		mkdir -p processed_evals_output_p${period}_${category}_new
	done
done