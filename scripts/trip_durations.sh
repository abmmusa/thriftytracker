#!/bin/bash

cat | awk 'BEGIN{InTrip=0} NF==0 {print last_time-start_time; InTrip=0} NF!=0 {last_time=$3; if (InTrip==0) {start_time=$3; InTrip=1}}'