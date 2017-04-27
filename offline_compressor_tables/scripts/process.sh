delay_bounds="0 8 16 32 64 128"

rm data/osm2.txt
for delay in $delay_bounds; do
	mean_of_max=`cat compressor_data_individual/osm2_d${delay}* | awk '{print $1}' | mean`
	mean_of_mean=`cat compressor_data_individual/osm2_d${delay}* | awk '{print $2}' | mean`

	echo $delay $mean_of_max $mean_of_mean >> data/osm2.txt
done