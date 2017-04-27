#!/bin/bash
#usage: cat single_trip_file | create_segment_with_speed.sh 


cat | awk '{print $1,$2,$3}' | awk 'NR>1 {print lastlat, lastlon, $1, $2, $3-lasttime} {lastlat=$1; lastlon=$2; lasttime=$3}' > /tmp/data


while read line; do
	lat1=`echo $line | awk '{print $1}'` 
	lon1=`echo $line | awk '{print $2}'` 
	lat2=`echo $line | awk '{print $3}'` 
	lon2=`echo $line | awk '{print $4}'` 
	time=`echo $line | awk '{print $5}'` 
	
	distance=`python -c "from pylibs import spatialfunclib; print spatialfunclib.distance($lat1, $lon1, $lat2, $lon2)"`

	speed_miles_h=`echo $distance $time | awk '{printf "%.2f\n", ($1/$2)*2.2394}'`

	echo $lat1 $lon1 $lat2 $lon2 $speed_miles_h 
	

done < /tmp/data