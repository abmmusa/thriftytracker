from location import LocationWithEstimatedValues
from pylibs import spatialfunclib

#from fit_ellipse import fit_ellipse, get_parameters
from math import isnan, isinf
import numpy as np
import sys

class OracleTrainer:
    def __init__(self):
        pass
    
    def train(self, trace, labeled_samples):
        all_trips_samples = self._get_all_trips_samples(trace)
        #print "all_trips_samples: " + str(all_trips_samples)
        
        all_labeled_samples = self._get_all_labeled_samples(labeled_samples)
        #print "all_labeled_samples: " + str(all_labeled_samples)
        
        prev_samples_time_limit = 60
        labeled_sample_index = 0
        
        for curr_trip_samples in all_trips_samples:
            for i in range(0, len(curr_trip_samples)):
                curr_sample = curr_trip_samples[i]
                
                # avoid UIC bus depot
                if ((curr_sample.lat > 41.863444) and (curr_sample.lat < 41.864747) and (curr_sample.lon > -87.650892) and (curr_sample.lon < -87.649681)):
                    continue
                
                assert((curr_sample.lat == all_labeled_samples[labeled_sample_index][0]) and (curr_sample.lon == all_labeled_samples[labeled_sample_index][1]))
                
                prev_samples = []
                prev_sample_index = i - 1
                
                while ((prev_sample_index >= 0) and ((curr_sample.time - curr_trip_samples[prev_sample_index].time) <= prev_samples_time_limit)):
                    prev_samples.append(curr_trip_samples[prev_sample_index])
                    prev_sample_index -= 1
                
                num_prev_samples = len(prev_samples)
                
                # stats wrt previous samples' attributes
                if (len(prev_samples) > 0):
                    prev_samples_speeds = map(lambda x: x.speed, prev_samples)
                    prev_samples_bearings = map(lambda x: x.bearing, prev_samples)
                    prev_samples_accelerations = map(lambda x: x.acceleration, prev_samples)
                    
                    prev_samples_mean_speed = float(sum(prev_samples_speeds)) / num_prev_samples
                    prev_samples_mean_bearing = float(sum(prev_samples_bearings)) / num_prev_samples
                    prev_samples_mean_acceleration = float(sum(prev_samples_accelerations)) / num_prev_samples
                    
                    prev_samples_speeds.sort()
                    prev_samples_bearings.sort()
                    prev_samples_accelerations.sort()
                    
                    prev_samples_median_speed = prev_samples_speeds[num_prev_samples / 2]
                    prev_samples_median_bearing = prev_samples_bearings[num_prev_samples / 2]
                    prev_samples_median_acceleration = prev_samples_accelerations[num_prev_samples / 2]
                
                else:
                    prev_samples_mean_speed = 0.0
                    prev_samples_mean_bearing = 0.0
                    prev_samples_mean_acceleration = 0.0
                    
                    prev_samples_median_speed = 0.0
                    prev_samples_median_bearing = 0.0
                    prev_samples_median_acceleration = 0.0
                
                sys.stdout.write(str(prev_samples_mean_speed) + " " + str(prev_samples_mean_bearing) + " " + str(prev_samples_mean_acceleration) + " ")
                
                curr_sample_mean_speed_delta = curr_sample.speed - prev_samples_mean_speed
                curr_sample_mean_bearing_delta = spatialfunclib.bearing_difference(curr_sample.bearing, prev_samples_mean_bearing)
                curr_sample_mean_acceleration_delta = curr_sample.acceleration - prev_samples_mean_acceleration
                
                curr_sample_median_speed_delta = curr_sample.speed - prev_samples_median_speed
                curr_sample_median_bearing_delta = spatialfunclib.bearing_difference(curr_sample.bearing, prev_samples_median_bearing)
                curr_sample_median_acceleration_delta = curr_sample.acceleration - prev_samples_median_acceleration
                
                sys.stdout.write(str(curr_sample_mean_speed_delta) + " " + str(curr_sample_mean_bearing_delta) + " " + str(curr_sample_mean_acceleration_delta) + " " + 
                                 str(curr_sample_median_speed_delta) + " " + str(curr_sample_median_bearing_delta) + " " + str(curr_sample_median_acceleration_delta) + " ")
                
                # stats wrt previous samples' point cloud
                if (len(prev_samples) > 0):
                    prev_samples_end_to_end_distance = spatialfunclib.haversine_distance(prev_samples[0].lat, prev_samples[0].lon, prev_samples[-1].lat, prev_samples[-1].lon)
                    
                    prev_samples_path_distance = 0.0
                    for i in range(1, len(prev_samples)):
                        prev_samples_path_distance += spatialfunclib.haversine_distance(prev_samples[i - 1].lat, prev_samples[i - 1].lon, prev_samples[i].lat, prev_samples[i].lon)
                    
                    prev_samples_max_distance = 0.0
                    for i in range(0, len(prev_samples)):
                        for j in range(i + 1, len(prev_samples)):
                            prev_samples_curr_distance = spatialfunclib.haversine_distance(prev_samples[i].lat, prev_samples[i].lon, prev_samples[j].lat, prev_samples[j].lon)
                            
                            if (prev_samples_curr_distance > prev_samples_max_distance):
                                prev_samples_max_distance = prev_samples_curr_distance
                    
                    prev_samples_latitudes = map(lambda x: x.lat, prev_samples)
                    prev_samples_longitudes = map(lambda x: x.lon, prev_samples)
                    
                    prev_samples_mean_latitude = float(sum(prev_samples_latitudes)) / num_prev_samples
                    prev_samples_mean_longitude = float(sum(prev_samples_longitudes)) / num_prev_samples
                    
                    prev_samples_latitudes.sort()
                    prev_samples_longitudes.sort()
                    
                    prev_samples_median_latitude = prev_samples_latitudes[num_prev_samples / 2]
                    prev_samples_median_longitude = prev_samples_longitudes[num_prev_samples / 2]
                    
                    distance_between_mean_and_median_center = spatialfunclib.haversine_distance(prev_samples_mean_latitude, prev_samples_mean_longitude, prev_samples_median_latitude, prev_samples_median_longitude)
                    
                    prev_samples_distances_to_mean_center = map(lambda x: spatialfunclib.haversine_distance(x.lat, x.lon, prev_samples_mean_latitude, prev_samples_mean_longitude), prev_samples)
                    prev_samples_distances_to_median_center = map(lambda x: spatialfunclib.haversine_distance(x.lat, x.lon, prev_samples_median_latitude, prev_samples_median_longitude), prev_samples)
                    
                    prev_samples_mean_distance_to_mean_center = float(sum(prev_samples_distances_to_mean_center)) / num_prev_samples
                    prev_samples_mean_distance_to_median_center = float(sum(prev_samples_distances_to_median_center)) / num_prev_samples
                    
                    prev_samples_distances_to_mean_center.sort()
                    prev_samples_distances_to_median_center.sort()
                    
                    prev_samples_median_distance_to_mean_center = prev_samples_distances_to_mean_center[num_prev_samples / 2]
                    prev_samples_median_distance_to_median_center = prev_samples_distances_to_median_center[num_prev_samples / 2]
                else:
                    prev_samples_end_to_end_distance = 0.0
                    prev_samples_path_distance = 0.0
                    prev_samples_max_distance = 0.0
                    
                    prev_samples_mean_latitude = curr_sample.lat
                    prev_samples_mean_longitude = curr_sample.lon
                    prev_samples_median_latitude = curr_sample.lat
                    prev_samples_median_longitude = curr_sample.lon
                    
                    distance_between_mean_and_median_center = 0.0
                    prev_samples_mean_distance_to_mean_center = 0.0
                    prev_samples_mean_distance_to_median_center = 0.0
                    prev_samples_median_distance_to_mean_center = 0.0
                    prev_samples_median_distance_to_median_center = 0.0
                
                curr_sample_distance_to_mean_center = spatialfunclib.haversine_distance(curr_sample.lat, curr_sample.lon, prev_samples_mean_latitude, prev_samples_mean_longitude)
                curr_sample_distance_to_median_center = spatialfunclib.haversine_distance(curr_sample.lat, curr_sample.lon, prev_samples_median_latitude, prev_samples_median_longitude)
                
                sys.stdout.write(str(prev_samples_end_to_end_distance) + " " + str(prev_samples_path_distance) + " " + str(prev_samples_max_distance) + " " + 
                                 str(prev_samples_mean_distance_to_mean_center) + " " + str(prev_samples_mean_distance_to_median_center) + " " + str(prev_samples_median_distance_to_mean_center) + " " + str(prev_samples_median_distance_to_median_center) + " " + 
                                 str(curr_sample_distance_to_mean_center) + " " + str(curr_sample_distance_to_median_center) + " ")
                
                # more stats wrt previous samples' point cloud
                if (len(prev_samples) > 0):
                    distance_to_prev_sample = spatialfunclib.haversine_distance(curr_sample.lat, curr_sample.lon, prev_samples[-1].lat, prev_samples[-1].lon)
                else:
                    distance_to_prev_sample = 0.0
                
                sys.stdout.write(str(distance_to_prev_sample) + " ")
                
                # ellipse fitting wrt previous samples' point cloud
                #if (len(prev_samples) > 1):
                #    lat_offset = curr_sample.lat
                #    lon_offset = curr_sample.lon
                #    
                #    prev_samples_coords = np.array(map(lambda x: [x.lon - lon_offset, x.lat - lat_offset], prev_samples))
                #    
                #    try:
                #        prev_samples_ellipse = fit_ellipse(prev_samples_coords)
                #        (rx, ry), (xc, yc), alpha = get_parameters(prev_samples_ellipse)
                #        
                #        prev_samples_ellipse_major_axis_radius = float(max(rx, ry))
                #        prev_samples_ellipse_minor_axis_radius = float(min(rx, ry))
                #        
                #        #prev_samples_ellipse_center_latitude = float(yc + lat_offset)
                #        #prev_samples_ellipse_center_longitude = float(xc + lon_offset)
                #        
                #        #print "prev_samples_ellipse_major_axis_radius, prev_samples_ellipse_minor_axis_radius: " + str(prev_samples_ellipse_major_axis_radius) + " " + str(prev_samples_ellipse_minor_axis_radius)
                #        #print "prev_samples_ellipse_center_latitude, prev_samples_ellipse_center_longitude: " + str(prev_samples_ellipse_center_latitude) + " " + str(prev_samples_ellipse_center_longitude)
                #        sys.stdout.write(str(prev_samples_ellipse_major_axis_radius) + " " + str(prev_samples_ellipse_minor_axis_radius) + " ")
                #    except:
                #        sys.stdout.write("0.0 0.0 ")
                #else:
                #    sys.stdout.write("0.0 0.0 ")
                #
                #print "max_distance_samples: " + str(max_distance_samples)
                #
                #if (None not in max_distance_samples):
                #    for i in range(0, len(curr_samples)):
                #        if (curr_samples[i] not in max_distance_samples):
                #            (proj_lat, proj_lon), fraction_along, proj_distance = spatialfunclib.projection_onto_line(max_distance_samples[0].lat, max_distance_samples[0].lon, max_distance_samples[1].lat, max_distance_samples[1].lon, curr_samples[i].lat, curr_samples[i].lon)
                #            print proj_lat, proj_lon, fraction_along, proj_distance
                #            assert(fraction_along >= 0.0 and fraction_along <= 1.0)
                #            
                #            proj_bearing = spatialfunclib.path_bearing(curr_samples[i].lat, curr_samples[i].lon, proj_lat, proj_lon)
                #            print proj_bearing
                
                # print class label
                sys.stdout.write(str(all_labeled_samples[labeled_sample_index][2][1:]) + "\n")
                labeled_sample_index += 1
    
    def _get_all_labeled_samples(self, labeled_samples):
        all_labeled_samples = []
        
        for raw_sample in labeled_samples:
            _, lat, lon, _, _, label = raw_sample.strip("\n").split(" ")
            all_labeled_samples.append((float(lat), float(lon), label))
        
        return all_labeled_samples
    
    def _get_all_trips_samples(self, trace):
        all_trip_samples = []
        curr_trip = []
        
        for raw_location in trace:
            if (raw_location == "\n"):
                if (len(curr_trip) > 1):
                    all_trip_samples.append(curr_trip[:-1])
                curr_trip = []
            
            else:
                curr_location = LocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                curr_trip.append(curr_location)
        
        if (len(curr_trip) > 1):
            all_trip_samples.append(curr_trip[:-1])
        
        return all_trip_samples

import sys, getopt, gzip
if __name__ == "__main__":
    raw_trace_filename = "traces/msmls/msmls_subject_0.txt.gz"
    labeled_samples_filename = "extrapolator_testbench_output_msmls_c300/sample_time_table_x99_e25_i0.txt.gz"
    
    (opts, args) = getopt.getopt(sys.argv[1:],"t:l:h")
    
    for o,a in opts:
        if o == "-t":
            raw_trace_filename = str(a)
        elif o == "-l":
            labeled_samples_filename = str(a)
        elif o == "-h":
            print "Usage: <stdin> | python oracle_trainer.py [-t <raw_trace_filename>] [-l <labeled_samples_filename>] [-h]"
            exit()
    
    raw_trace = gzip.open(raw_trace_filename, 'rb')
    labeled_samples = gzip.open(labeled_samples_filename, 'rb')
    
    otr = OracleTrainer()
    otr.train(raw_trace, labeled_samples)
