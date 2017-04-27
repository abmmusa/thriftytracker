#!/bin/bash

#
# producing offline time_error_table
#
window=1800

# uses constant location extrapolator
echo "python produce_offline_reachtime_error_table.py -x 0 -i traces/osm/ -o osm.pkl -w $window"
echo "python produce_offline_reachtime_error_table.py -x 0 -i traces/uic/ -o uic.pkl -w $window"
echo "python produce_offline_reachtime_error_table.py -x 0 -i traces/msmls/ -o msmls.pkl -w $window"
#echo "python produce_offline_time_error_table.py -x 0 -i traces/ -o all.pkl -w $window"


# uses constant velocity extrapolator
echo "python produce_offline_reachtime_error_table.py -x 1 -i traces/osm/ -o osm_const_vel.pkl -w $window"
echo "python produce_offline_reachtime_error_table.py -x 1 -i traces/uic/ -o uic_const_vel.pkl -w $window"
echo "python produce_offline_reachtime_error_table.py -x 1 -i traces/msmls/ -o msmls_const_vel.pkl -w $window"
#echo "python produce_offline_time_error_table.py -x 1 -i traces/ -o all_const_vel.pkl -w $window"
