#!/bin/bash


# msmls
files="msmls_subject_0.txt.gz msmls_subject_1.txt.gz" 

rm -rd /tmp/tmpdata
mkdir /tmp/tmpdata

for file in $files; do
	
	file_prefix=`echo $file | sed 's/.txt.gz//'`

	gunzip -c traces/msmls/$file | python scripts/splitter.py "/tmp/tmpdata/"$file_prefix
	cp /tmp/tmpdata/* splitted_traces/

	for f in `ls /tmp/tmpdata | grep $file_prefix`; do
		echo "processing $f"
		cat /tmp/tmpdata/$f | scripts/create_segments_with_speed.sh > /tmp/tmpdata/"w_speed_"$f
	   
		cat /tmp/tmpdata/"w_speed_"$f | scripts/gelines_multi_color.sh $f > kml_files/$f".kml"
	done

done

rm -rd /tmp/tmpdata



# osm
files="14569.txt.gz 39026.txt.gz"

rm -rd /tmp/tmpdata
mkdir /tmp/tmpdata

for file in $files; do
	
	file_prefix=`echo $file | sed 's/.txt.gz//'`

	gunzip -c traces/osm/$file | python scripts/splitter.py "/tmp/tmpdata/"$file_prefix
	cp /tmp/tmpdata/* splitted_traces/

	for f in `ls /tmp/tmpdata | grep $file_prefix`; do
		echo "processing $f"
		cat /tmp/tmpdata/$f | scripts/create_segments_with_speed.sh > /tmp/tmpdata/"w_speed_"$f
	   
		cat /tmp/tmpdata/"w_speed_"$f | scripts/gelines_multi_color.sh $f > kml_files/$f".kml"
	done

done

rm -rd /tmp/tmpdata


# uic