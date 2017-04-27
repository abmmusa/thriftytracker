from pylibs import spatialfunclib
from location import Location

#
# UIC (1 Hz, 5 sec max): 180 samples, 900 sec duration
# MSMLS (1/10 Hz, 30 sec max): 90 samples, 900 sec duration
# OSM (1 Hz, 5 sec max): 180 samples, 900 sec duration
#

class PreProcessor:
    def __init__(self):
        pass
    
    def preprocess(self, trace):
        curr_trip = []
        
        for raw_location in trace:
            if (raw_location[0:9] == "exception"):
                break
            
            elif (raw_location == "\n"):
                self._write_valid_trip(curr_trip)
                curr_trip = []
            
            else:
                curr_location = Location()
                curr_location.load_raw_location(raw_location)
                
                # if the current trip has at least one previous location
                if (len(curr_trip) > 0):
                    prev_location = curr_trip[-1]
                    
                    # drop consecutive points with the same timestamp
                    if (curr_location.time == prev_location.time):
                        continue
                    
                    # drop points with invalid timestamps
                    elif ((curr_location.time < 1041379200) or (curr_location.time > 1389306130)):
                        continue
                    
                    # split current trip if locations are more than 30 seconds apart
                    #elif (abs(curr_location.time - prev_location.time) > 30.0):
                    #elif (abs(curr_location.time - prev_location.time) > 5.0):
                    elif (abs(curr_location.time - prev_location.time) > 1.0):
                        self._write_valid_trip(curr_trip)
                        curr_trip = []
                    
                    # split current trip if locations are not in increasing time order
                    elif (curr_location.time < prev_location.time):
                        self._write_valid_trip(curr_trip)
                        curr_trip = []
                    
                    # split current trip if speed between locations is greater than 130 mph
                    elif ((self._distance(curr_location, prev_location) / (curr_location.time - prev_location.time)) > 58.12):
                        self._write_valid_trip(curr_trip)
                        curr_trip = []
                    
                    # split current trip if duration is greater than 12 hours
                    elif ((curr_location.time - curr_trip[0].time) > 43200):
                        self._write_valid_trip(curr_trip)
                        curr_trip = []
                
                # if current location made it through the gauntlet, add it to the current trip
                curr_trip.append(curr_location)
    
    def _write_valid_trip(self, curr_trip):
        #if ((len(curr_trip) >= 90) and ((curr_trip[-1].time - curr_trip[0].time) >= 900)):
        if ((len(curr_trip) >= 180) and ((curr_trip[-1].time - curr_trip[0].time) >= 900)):
            for location in curr_trip:
                sys.stdout.write(str(location) + "\n")
            sys.stdout.write("\n")
    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)

import sys, getopt
if __name__ == "__main__":
    
    (opts, args) = getopt.getopt(sys.argv[1:],"h")
    
    for o,a in opts:
        if o == "-h":
            print "Usage: <stdin> | python preprocessor.py [-h]"
            exit()
    
    preprocessor = PreProcessor()
    preprocessor.preprocess(sys.stdin)
