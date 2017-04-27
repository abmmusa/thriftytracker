#!/bin/bash

#usage: gelines_multi_color [name for kml <name></name> tag]

# produce multiple straight lines from beginning and end coordinates where each line has different color
# input format: lat1, lon1, lat2, lon2, speed 


cat > /tmp/segments.tmp

min_max=`cat /tmp/segments.tmp | awk 'BEGIN{min=1000; max=-1} $5<min{min=$5} $5>max{max=$5} END{print min, max}'`
range=`echo $min_max | awk '{print $2-$1}'`
min=`echo $min_max | awk '{print $1}'`
max=`echo $min_max | awk '{print $2}'`

name=$1

cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.2">
  <Document>
    <name>$name</name>
    <description>min_spped=$min max_spped=$max</description>
EOF

# red gradient 
#cat /tmp/segments.tmp | awk -v range=$range \
#'{printf "<Style id=\"myStyle\"><LineStyle><color>ff0000%x</color><width>8</width></LineStyle></Style><Placemark><name></name><styleUrl>#myStyle</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>%f,%f %f,%f</coordinates></LineString></Placemark>\n", $5/range*255, $2, $1, $4, $3}' 

#3 color gradient
# http://stackoverflow.com/questions/12875486/what-is-the-algorithm-to-create-colors-for-a-heatmap
#cat /tmp/segments.tmp | awk -v min=$min -v max=$max \
#'{
#if($5<=(max-min)/2)  
#{printf "<Style id=\"myStyle\"><LineStyle><color>ff%x%x00</color><width>8</width></LineStyle></Style><Placemark><name></name><styleUrl>#myStyle</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>%f,%f #%f,%f</coordinates></LineString></Placemark>\n", (((max-min)/2-$5)/((max-min)/2))*255, ($5-min)/((max-min)/2)*255, $2, $1, $4, $3}
#else 
#{printf "<Style id=\"myStyle\"><LineStyle><color>ff00%02x%02x</color><width>8</width></LineStyle></Style><Placemark><name></name><styleUrl>#myStyle</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>%f,%f #%f,%f</coordinates></LineString></Placemark>\n", (($5-(max-min)/2)/((max-min)/2))*255, (max-min-$5)/((max-min)/2)*255, $2, $1, $4, $3}
#}' 

#green to red gradient
cat /tmp/segments.tmp | awk -v min=$min -v max=$max \
'{
printf "<Style id=\"myStyle\"><LineStyle><color>ff00%x%x</color><width>8</width></LineStyle></Style><Placemark><name></name><styleUrl>#myStyle</styleUrl><LineString><altitudeMode>relative</altitudeMode><coordinates>%f,%f %f,%f</coordinates></LineString></Placemark>\n", ((max-$5)/(max-min))*255, (($5-min)/(max-min))*255, $2, $1, $4, $3
}'

cat <<EOF
</Document></kml>
EOF