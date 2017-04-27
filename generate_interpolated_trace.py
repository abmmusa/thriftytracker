from pylibs import spatialfunclib
from location import Location
import math

class Interpolator:
    def __init__(self):
        pass
    
    def interpolate(self, trace):
        
        prev_location = None
        
        for raw_location in trace:
            
            if (raw_location == "\n"):
                prev_location = None
                sys.stdout.write(raw_location)
            
            else:
                curr_location = Location()
                curr_location.load_raw_location(raw_location)
                
                if prev_location is not None:
                    distance = self._distance(curr_location, prev_location)
                    timegap = curr_location.time - prev_location.time
                    bearing = self._path_bearing(prev_location, curr_location)

                    for time in range(int(prev_location.time+1), int(curr_location.time)):
                        distance_now = (distance/timegap)*(time-prev_location.time)
                        #print distance_now, distance
                        dest_coord=spatialfunclib.destination_point(prev_location.lat, prev_location.lon, bearing, distance_now)
                        sys.stdout.write(str(dest_coord[0])+ " " + str(dest_coord[1]) + " " + str(float(time)) + " None None None None None None None\n")

                sys.stdout.write(str(curr_location.lat) + " " + str(curr_location.lon) + " " + str(curr_location.time) + " None None None None None None None\n")
                prev_location = curr_location
    



    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)
    
    def _path_bearing(self, location1, location2):
        return spatialfunclib.path_bearing(location1.lat, location1.lon, location2.lat, location2.lon)

import sys, getopt
if __name__ == "__main__":
    
    (opts, args) = getopt.getopt(sys.argv[1:],"h")
    
    for o,a in opts:
        if o == "-h":
            print "Usage: <stdin> | python generate_interpolated_trace.py [-h]"
            exit()
    
    interpolator = Interpolator()
    interpolator.interpolate(sys.stdin)
