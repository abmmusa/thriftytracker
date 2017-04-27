for provider in "msmls" "uic"; do
	# 1,3 are error delay; 4 is budget delay straw-man
    for sampler in 1 3 4; do
		for file_type in "evaluated_locations_s${sampler}" "transmitted_locations_s${sampler}"; do
			for file in `ls evaluator_output_${provider}_new/split_0/${file_type}_*.txt`; do
				file_no_prefix=${file#evaluator_output_${provider}_new/split_0/}
        
				for s in `seq 0 4`; do
					cat evaluator_output_${provider}_new/split_${s}/$file_no_prefix
				done > evaluator_output_${provider}_new/$file_no_prefix
			done;
		done;
    done;
	
	#13 are budget delay; 21 is error budget
	for sampler in 13 21; do
		for period in 1800.0 3600.0; do
			for file_type in "evaluated_locations_s${sampler}" "transmitted_locations_s${sampler}"; do
				for file in `ls evaluator_output_p${period}_${provider}_new/split_0/${file_type}_*.txt`; do
					file_no_prefix=${file#evaluator_output_p${period}_${provider}_new/split_0/}
					#echo "prefix" $file_no_prefix
					for s in `seq 0 4`; do
						cat evaluator_output_p${period}_${provider}_new/split_${s}/$file_no_prefix
					done > evaluator_output_p${period}_${provider}_new/$file_no_prefix
				done;
			done;
		done;
	done;
	
	
	for period in 1800.0 3600.0; do
		for file in `ls delays_p${period}_${provider}_new/split_0/delays_s21_*.txt`; do
    		file_no_prefix=${file#delays_p${period}_${provider}_new/split_0/}
    
    		for s in `seq 0 4`; do
    			cat delays_p${period}_${provider}_new/split_${s}/$file_no_prefix
    		done > delays_p${period}_${provider}_new/$file_no_prefix
		done;
	done;
done
