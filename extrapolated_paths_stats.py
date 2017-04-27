from pylibs import spatialfunclib

class ExtrapolatedPathsStats:
    def __init__(self):
        pass
    
    def compute(self, raw_samples, extrapolator_index):
        rounding_factor = 1.0
        
        duration_errors = {}
        distance_errors = {}
        
        #prev_extrapolated_lat, prev_extrapolated_lon = None, None
        #start_extrapolated_lat, start_extrapolated_lon = None, None
        
        for raw_sample in raw_samples:
            if (raw_sample == "\n"):
                #prev_extrapolated_lat, prev_extrapolated_lon = None, None
                #start_extrapolated_lat, start_extrapolated_lon = None, None
                continue
            
            #ground_truth_lat, ground_truth_lon, curr_extrapolated_lat, curr_extrapolated_lon, curr_duration, curr_error = raw_sample.strip("\n").split(" ")
            #
            #curr_extrapolated_lat, curr_extrapolated_lon, curr_duration, curr_error = float(curr_extrapolated_lat), float(curr_extrapolated_lon), float(curr_duration), float(curr_error)
            #
            #if ((start_extrapolated_lat is None) or (start_extrapolated_lon is None)):
            #    start_extrapolated_lat, start_extrapolated_lon = curr_extrapolated_lat, curr_extrapolated_lon
            #
            #curr_distance = spatialfunclib.haversine_distance(start_extrapolated_lat, start_extrapolated_lon, curr_extrapolated_lat, curr_extrapolated_lon)
            
            #if ((prev_extrapolated_lat is None) or (prev_extrapolated_lon is None)):
            #    curr_distance = 0.0
            #else:
            #    curr_distance += spatialfunclib.haversine_distance(prev_extrapolated_lat, prev_extrapolated_lon, curr_extrapolated_lat, curr_extrapolated_lon)
            #
            #prev_extrapolated_lat, prev_extrapolated_lon = curr_extrapolated_lat, curr_extrapolated_lon
            
            curr_duration, curr_distance, curr_error = raw_sample.strip("\n").split(" ")
            curr_duration, curr_distance, curr_error = float(curr_duration), float(curr_distance), float(curr_error)
            
            adjusted_duration = int(round(curr_duration / rounding_factor) * rounding_factor)
            adjusted_distance = int(round(curr_distance / rounding_factor) * rounding_factor)
            adjusted_error = int(round(curr_error))
            
            #print prev_extrapolated_lat, prev_extrapolated_lon, curr_extrapolated_lat, curr_extrapolated_lon, adjusted_distance, adjusted_error
            
            if (adjusted_duration not in duration_errors):
                duration_errors[adjusted_duration] = {}
            
            if (adjusted_distance not in distance_errors):
                distance_errors[adjusted_distance] = {}
            
            if (adjusted_error not in duration_errors[adjusted_duration]):
                duration_errors[adjusted_duration][adjusted_error] = 0
            
            if (adjusted_error not in distance_errors[adjusted_distance]):
                distance_errors[adjusted_distance][adjusted_error] = 0
            
            duration_errors[adjusted_duration][adjusted_error] += 1
            distance_errors[adjusted_distance][adjusted_error] += 1
        
        duration_errors_keys = duration_errors.keys()
        duration_errors_keys.sort()
        
        duration_errors_file = open("extrapolated_paths_stats_x" + str(extrapolator_index) + "_duration_errors.txt", 'w')
        
        for duration_errors_key in duration_errors_keys:
            curr_duration_errors = duration_errors[duration_errors_key].items()
            curr_duration_errors.sort(key=lambda x: x[0])
            
            curr_duration_errors_sum = float(sum(map(lambda x: x[0] * x[1], curr_duration_errors)))
            curr_duration_errors_count = float(sum(map(lambda x: x[1], curr_duration_errors)))
            curr_duration_errors_mean = int(round(curr_duration_errors_sum / curr_duration_errors_count))
            curr_duration_errors_median = None
            
            curr_duration_errors_itr = 0
            for curr_duration_error in curr_duration_errors:
                curr_duration_errors_itr += curr_duration_error[1]
                
                if (curr_duration_errors_itr >= (curr_duration_errors_count / 2.0)):
                    curr_duration_errors_median = curr_duration_error[0]
                    break
            
            if (curr_duration_errors_median is None):
                print "ERROR!! duration error median is None!"
                exit(-1)
            
            duration_errors_file.write(str(duration_errors_key) + " " + str(curr_duration_errors_mean) + " " + str(curr_duration_errors_median) + "\n")
        
        duration_errors_file.close()
        
        distance_errors_keys = distance_errors.keys()
        distance_errors_keys.sort()
        
        distance_errors_file = open("extrapolated_paths_stats_x" + str(extrapolator_index) + "_distance_errors.txt", 'w')
        
        for distance_errors_key in distance_errors_keys:
            curr_distance_errors = distance_errors[distance_errors_key].items()
            curr_distance_errors.sort(key=lambda x: x[0])
            
            curr_distance_errors_sum = float(sum(map(lambda x: x[0] * x[1], curr_distance_errors)))
            curr_distance_errors_count = float(sum(map(lambda x: x[1], curr_distance_errors)))
            curr_distance_errors_mean = int(round(curr_distance_errors_sum / curr_distance_errors_count))
            curr_distance_errors_median = None
            
            curr_distance_errors_itr = 0
            for curr_distance_error in curr_distance_errors:
                curr_distance_errors_itr += curr_distance_error[1]
                
                if (curr_distance_errors_itr >= (curr_distance_errors_count / 2.0)):
                    curr_distance_errors_median = curr_distance_error[0]
                    break
            
            if (curr_distance_errors_median is None):
                print "ERROR!! distance error median is None!"
                exit(-1)
            
            distance_errors_file.write(str(distance_errors_key) + " " + str(curr_distance_errors_mean) + " " + str(curr_distance_errors_median) + "\n")
        
        distance_errors_file.close()

import sys, getopt
if __name__ == "__main__":
    extrapolator_index = 0
    
    (opts, args) = getopt.getopt(sys.argv[1:],"x:h")
    
    for o,a in opts:
        if o == "-x":
            extrapolator_index = int(a)
        elif o == "-h":
            print "Usage: <stdin> | python extrapolated_paths_stats.py [-x <extrapolator_index>] [-h]"
            exit()
    
    eps = ExtrapolatedPathsStats()
    eps.compute(sys.stdin, extrapolator_index)
