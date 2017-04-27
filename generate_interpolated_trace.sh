#!/bin/bash

for category in "msmls" "msmls2"; do
	for trace in `ls traces/$category`; do
		echo "gunzip -c traces/$category/$trace | python generate_interpolated_trace.py | gzip > traces/${category}_interpolated/$trace"
	done
done