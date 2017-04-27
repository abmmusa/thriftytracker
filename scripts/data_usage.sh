#!/bin/bash

header_size=32
payload_size=9
const=10
timestamp_size=4

for i in {1..5000}; do
	echo $i | awk '{print $1, ( (int( ((h+$1*p+c+t)/42) + 1))*42 )}' h=$header_size p=$payload_size c=$const t=$timestamp_size 
done > data/data_usage
