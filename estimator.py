from pylibs import spatialfunclib
from location import Location
import math

class Estimator:
    def __init__(self):
        pass
    
    def estimate(self, trace):
        
        prev_location = None
        
        for raw_location in trace:
            
            if (raw_location[0:9] == "exception"):
                prev_location = None
                sys.stdout.write("\n")
            
            elif (raw_location == "\n"):
                prev_location = None
                sys.stdout.write(raw_location)
            
            else:
                curr_location = Location()
                curr_location.load_raw_location(raw_location)
                
                # drop consecutive points with the same timestamp
                if ((prev_location is not None) and (curr_location.time == prev_location.time)):
                    continue
                
                # estimate expected parameters
                estimated_bearing = self.estimate_bearing(curr_location, prev_location)
                estimated_speed = self.estimate_speed(curr_location, prev_location)
                
                if ((curr_location.bearing is None) or (curr_location.bearing > 360.0) or (curr_location.bearing < 0.0)):
                    curr_location.bearing = estimated_bearing
                else:
                    # if estimated course is valid, but the estimated and recorded course differ by more than 15 degrees, use the estimated course value
                    if ((prev_location is not None) and (spatialfunclib.bearing_difference(estimated_bearing, curr_location.bearing) > 15.0)):
                        curr_location.bearing = estimated_bearing
                
                if ((curr_location.speed is None) or (curr_location.speed > 58.1152) or (curr_location.speed < 0.0)):
                    curr_location.speed = estimated_speed
                else:
                    # if estimated speed is valid, but the estimated and recorded speed differ by more than 2.25 meters per second (5 miles per hour), use the estimated speed value
                    if ((prev_location is not None) and (math.fabs(estimated_speed - curr_location.speed) > 2.25)):
                        curr_location.speed = estimated_speed
                
                # estimate new parameters
                curr_location.acceleration = self.estimate_acceleration(curr_location, prev_location)
                curr_location.angular_velocity = self.estimate_angular_velocity(curr_location, prev_location)
                curr_location.angular_acceleration = self.estimate_angular_acceleration_with_constant_velocity(curr_location)
                
                # sanity check parameter values
                if ((curr_location.speed > 58.1152) or (curr_location.speed < 0.0)): # 130 mph or 0 mph
                    continue
                if ((curr_location.acceleration > 5.96) or (curr_location.acceleration < -12.02)): # 0-60 mph in 4.5 sec or 60-0 mph in 2.23 sec
                    continue
                if ((curr_location.angular_acceleration > 4.9) or (curr_location.angular_acceleration < -4.9)): # +/- 0.5 g
                    continue
                
                sys.stdout.write(str(curr_location) + " " + str(curr_location.acceleration) + " " + str(curr_location.angular_velocity) + "\n")
                prev_location = curr_location
    
    def estimate_bearing(self, curr_location, prev_location):
        if (prev_location is not None):
            return self._path_bearing(prev_location, curr_location)
        else:
            return 0.0
    
    def estimate_speed(self, curr_location, prev_location):
        if (prev_location is not None):
            return (self._distance(prev_location, curr_location) / (curr_location.time - prev_location.time))
        else:
            return 0.0
    
    def estimate_acceleration(self, curr_location, prev_location):
        if (prev_location is not None):
            return ((curr_location.speed - prev_location.speed) / (curr_location.time - prev_location.time))
        else:
            return 0.0
    
    def estimate_angular_velocity(self, curr_location, prev_location):
        if (prev_location is not None):
            raw_bearing_difference = (curr_location.bearing - prev_location.bearing)
            bearing_difference = spatialfunclib.bearing_difference(curr_location.bearing, prev_location.bearing)
            
            # compute correct sign for angular velocity
            if (bearing_difference > 0.0):
                if (math.fabs(raw_bearing_difference) == bearing_difference):
                    bearing_difference *= (bearing_difference / raw_bearing_difference)
                else:
                    if (raw_bearing_difference > bearing_difference):
                        bearing_difference *= -1.0
            
            return (bearing_difference / (curr_location.time - prev_location.time))
        else:
            return 0.0
    
    def estimate_angular_acceleration_with_constant_velocity(self, curr_location):
        return math.sqrt(pow(curr_location.speed, 2.0) + pow(curr_location.speed, 2.0) - (2.0 * pow(curr_location.speed, 2.0) * math.cos(math.radians(curr_location.angular_velocity))))
    
    def _path_bearing(self, location1, location2):
        return spatialfunclib.path_bearing(location1.lat, location1.lon, location2.lat, location2.lon)
    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)

import sys, getopt
if __name__ == "__main__":
    
    (opts, args) = getopt.getopt(sys.argv[1:],"h")
    
    for o,a in opts:
        if o == "-h":
            print "Usage: <stdin> | python estimator.py [-h]"
            exit()
    
    estimator = Estimator()
    estimator.estimate(sys.stdin)
