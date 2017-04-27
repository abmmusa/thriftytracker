error_bounds="0 1 5 10 25 50 75 100 200 350 500 750 1000 1500 2000"
#delay_bounds="0 8 16 32 64 128"
delay_bounds="0 1 2 4 8 16 24 32 40 48 56 64 80 96 112 128"

for category in "osm2" "uic" "msmls"; do
	for delay in $delay_bounds; do
		rm data/${category}_d${delay}.txt
	
		for error in $error_bounds; do
			mean_of_max=`cat compressor_data_individual/${category}/d${delay}/stat_e${error}_i* | awk '{print $1}' | mean`
			mean_of_mean=`cat compressor_data_individual/${category}/d${delay}/stat_e${error}_i* | awk '{print $2}' | mean`
			mean_size=`cat compressor_data_individual/${category}/d${delay}/stat_e${error}_i* | awk '{print $3}' | mean`
			mean_usage=`cat compressor_data_individual/${category}/d${delay}/stat_e${error}_i* | awk '{print $4}' | mean`

			echo $error $mean_of_max $mean_of_mean $mean_size $mean_usage >> data/${category}_d${delay}.txt
		done
	done
done