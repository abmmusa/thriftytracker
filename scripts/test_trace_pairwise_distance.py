# usage: <stdin> | python test_trace_pairwise_distance.py

import sys, os
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0,parentdir)
from location import LocationWithEstimatedValues
from pylibs import spatialfunclib


def _distance(location1, location2):
    return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)


def process(trace):
    need_init = True
    last_location = None
    
    for raw_location in trace:
        if (raw_location == "\n"):
            need_init = True
            
        else:
            curr_location = LocationWithEstimatedValues()
            curr_location.load_raw_location(raw_location)

            if (need_init is True):
                #print "init needed"
                need_init = False
                last_location = curr_location 
            else:                
                distance= _distance(curr_location, last_location)
                timegap = curr_location.time - last_location.time
                print int(curr_location.time), timegap, distance

                last_location = curr_location
                
                
process(sys.stdin)
