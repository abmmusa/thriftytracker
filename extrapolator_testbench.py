from location import MapMatchedLocationWithEstimatedValues
from pylibs import spatialfunclib

debug = False

class ExtrapolatorTestbench:
    def __init__(self):
        pass
    
    def _get_duration_errors(self, location_params, trip, extrapolator, max_duration, extrapolated_paths_file):
        time_offsets = []
        
        for i in range(0, len(trip)):
            time_offsets.append(trip[i].time - location_params[0].time)
            
            if (time_offsets[-1] > max_duration):
                break
        
        extrapolated_trajectory = extrapolator.get_trajectory(location_params, time_offsets)
        ground_truth_trajectory = trip[:len(time_offsets)]
        
        assert(len(time_offsets) == len(extrapolated_trajectory) == len(ground_truth_trajectory))
        
        duration_errors = []
        
        for i in range(0, len(time_offsets)):
            curr_duration = time_offsets[i]
            curr_ground_truth_location = ground_truth_trajectory[i]
            curr_extrapolated_location = extrapolated_trajectory[i]
            
            curr_error = self._distance(curr_ground_truth_location, curr_extrapolated_location)
            duration_errors.append((curr_duration, curr_error))
            
            if (debug):
                if (i < 1):
                    curr_extrapolated_distance = 0.0
                else:
                    curr_extrapolated_distance += self._distance(extrapolated_trajectory[i - 1], extrapolated_trajectory[i])
                
                extrapolated_paths_file.write(str(int(curr_duration)) + " " + str(int(round(curr_extrapolated_distance))) + " " + str(int(round(curr_error))) + "\n")
            
            #if (debug): extrapolated_paths_file.write(str(curr_ground_truth_location.lat) + " " + str(curr_ground_truth_location.lon) + " " + str(curr_extrapolated_location.lat) + " " + str(curr_extrapolated_location.lon) + " " + str(curr_duration) + " " + str(curr_error) + "\n")
        #if (debug): extrapolated_paths_file.write("\n")
        
        return duration_errors
    
    def _examine_duration_errors(self, duration_errors, error_thresholds, duration_thresholds):
        error_threshold_samples = {}
        duration_threshold_samples = {'mean':{}, 'max':{}}
        
        duration_errors_itr = 0
        
        for error_threshold in error_thresholds:
            while ((duration_errors_itr < len(duration_errors)) and (duration_errors[duration_errors_itr][1] <= error_threshold)):
                duration_errors_itr += 1
            
            if ((duration_errors_itr < len(duration_errors)) and (duration_errors[duration_errors_itr][1] > error_threshold)):
                crossed_error_threshold = True
            else:
                crossed_error_threshold = False
            
            if (duration_errors_itr > 0):
                prev_duration, prev_error = duration_errors[duration_errors_itr - 1]
                error_threshold_samples[error_threshold] = (prev_duration, prev_error, int(crossed_error_threshold))
            else:
                error_threshold_samples[error_threshold] = (0.0, 0.0, int(crossed_error_threshold))
        
        duration_errors_itr = 0
        
        for duration_threshold in duration_thresholds:
            while ((duration_errors_itr < len(duration_errors)) and (duration_errors[duration_errors_itr][0] <= duration_threshold)):
                duration_errors_itr += 1
            
            if ((duration_errors_itr < len(duration_errors)) and (duration_errors[duration_errors_itr][0] > duration_threshold)):
                crossed_duration_threshold = True
            else:
                crossed_duration_threshold = False
            
            if (duration_errors_itr > 0):
                prev_duration = duration_errors[duration_errors_itr - 1][0]
                prev_errors = map(lambda x: x[1], duration_errors[:duration_errors_itr])
                
                duration_threshold_samples['mean'][duration_threshold] = ((sum(prev_errors) / len(prev_errors)), prev_duration, int(crossed_duration_threshold))
                duration_threshold_samples['max'][duration_threshold] = (max(prev_errors), prev_duration, int(crossed_duration_threshold))
            else:
                duration_threshold_samples['mean'][duration_threshold] = (0.0, 0.0, int(crossed_duration_threshold))
                duration_threshold_samples['max'][duration_threshold] = (0.0, 0.0, int(crossed_duration_threshold))
        
        return (error_threshold_samples, duration_threshold_samples)
    
    def build_sample_time_tables(self, trace, extrapolator, error_thresholds, duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file):
        sample_index = 0
        curr_trip = []
        
        for raw_location in trace:
            if (raw_location == "\n"):
                if (len(curr_trip) > 1):
                    sample_index = self._build_sample_time_table(curr_trip, sample_index, extrapolator, error_thresholds, duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file)
                curr_trip = []
            
            else:
                curr_location = MapMatchedLocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                curr_trip.append(curr_location)
        
        if (len(curr_trip) > 1):
            sample_index = self._build_sample_time_table(curr_trip, sample_index, extrapolator, error_thresholds, duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file)
    
    def _build_sample_time_table(self, trip, sample_index, extrapolator, error_thresholds, duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file):
        for i in range(0, len(trip) - 1):
            if (i == 0):
                curr_location_params = extrapolator.init_location_params(trip[i])
            else:
                curr_location_params = extrapolator.get_location_params(trip[i])
            
            # don't extrapolate from points within UIC bus depot
            if ((trip[i].lat > 41.863444) and (trip[i].lat < 41.864747) and (trip[i].lon > -87.650892) and (trip[i].lon < -87.649681)):
                continue
            
            curr_duration_errors = self._get_duration_errors(curr_location_params, trip[i:], extrapolator, max_duration, extrapolated_paths_file)
            (error_threshold_samples, duration_threshold_samples) = self._examine_duration_errors(curr_duration_errors, error_thresholds, duration_thresholds)
            
            for error_threshold in error_thresholds:
                error_threshold_duration, _, crossed_error_threshold = error_threshold_samples[error_threshold]
                error_threshold_files[error_threshold].write(str(sample_index) + " " + str(trip[i].lat) + " " + str(trip[i].lon) + " " + str(error_threshold_duration) + " " + str(crossed_error_threshold) + "\n")
            
            for duration_threshold in duration_thresholds:
                duration_threshold_mean_error, _, crossed_duration_threshold = duration_threshold_samples['mean'][duration_threshold]
                duration_threshold_files['mean'][duration_threshold].write(str(sample_index) + " " + str(trip[i].lat) + " " + str(trip[i].lon) + " " + str(duration_threshold_mean_error) + " " + str(crossed_duration_threshold) + "\n")
                
                duration_threshold_max_error, _, crossed_duration_threshold = duration_threshold_samples['max'][duration_threshold]
                duration_threshold_files['max'][duration_threshold].write(str(sample_index) + " " + str(trip[i].lat) + " " + str(trip[i].lon) + " " + str(duration_threshold_max_error) + " " + str(crossed_duration_threshold) + "\n")
            
            sample_index += 1
        
        return sample_index
    
    def build_time_error_table(self, extrapolator, output_file):
        time_error_table = {}
        
        for curr_trip in self.all_trips:
            for i in range(0, len(curr_trip)):
                extrapolator.location_update(curr_trip[i])
                
                for j in range(i + 1, len(curr_trip)):
                    curr_duration = curr_trip[j].time - curr_trip[i].time
                    
                    curr_extrapolated_location = extrapolator.get_curr_location(curr_trip[j].time)
                    curr_error = round(spatialfunclib.distance(curr_trip[j].lat, curr_trip[j].lon, curr_extrapolated_location.lat, curr_extrapolated_location.lon))
                    
                    if ((curr_duration, curr_error) not in time_error_table):
                        time_error_table[(curr_duration, curr_error)] = 0
                    
                    time_error_table[(curr_duration, curr_error)] += 1
        
        for key in time_error_table:
            print str(key) + " " + str(time_error_table[key])
        
        #output_file.write(str(sample_index) + " " + str(prev_duration) + " " + str(prev_error) + "\n")
        #if (debug): sys.stdout.write(str(sample_index) + " " + str(prev_duration) + " " + str(prev_error) + "\n")
    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)

from extrapolator import ConstantLocationExtrapolator, ConstantVelocityExtrapolator, ConstantAccelerationExtrapolator, ConstantDecelerationExtrapolator, MapExtrapolator, MapExtrapolatorStraightRoad, MapExtrapolatorNMM, MapExtrapolatorNMMStraightRoad, UnifiedExtrapolator
import sys, getopt, gzip
if __name__ == "__main__":
    extrapolator_index = 0
    output_directory = "extrapolator_testbench_output/"
    
    map_filename = None #"map_matching/pickle/planet-121114_uic_bbx.pkl"
    map_generic_turn_probs_filename = None #"map_matching/osmdb/planet-121114_uic_generic_turn_probs.txt"
    map_trace_turn_probs_filename = None #"map_matching/calculated_turn_proportions2/uic_shuttle_0_mm_m0_turn_proportions.txt"
    map_bbox_name = None
    
    classifier_path = None
    max_error_target = None
    
    max_error_thresholds = [1, 5, 10, 25, 50, 75, 100, 200, 350, 500, 750, 1000, 1500, 2000]
    max_duration_thresholds = [1, 5, 10, 15, 30, 45, 60, 90, 120, 240, 360, 480, 600, 900]
    
    max_duration = 600
    
    #max_error_thresholds = [100]
    #max_duration_thresholds = [30]
    
    unique_id = None
    
    (opts, args) = getopt.getopt(sys.argv[1:],"x:m:b:g:t:c:e:o:i:h")
    
    for o,a in opts:
        if o == "-x":
            extrapolator_index = int(a)
        elif o == "-m":
            map_filename = str(a)
        elif o == "-b":
            map_bbox_name = str(a)
        elif o == "-g":
            map_generic_turn_probs_filename = str(a)
        elif o == "-t":
            map_trace_turn_probs_filename = str(a)
        elif o == "-c":
            classifier_path = str(a)
        elif o == "-e":
            max_error_target = int(a)
        elif o == "-o":
            output_directory = str(a)
        elif o == "-i":
            unique_id = str(a)
        elif o == "-h":
            print "Usage: <stdin> | python extrapolator_testbench.py [-x <extrapolator>] [-m <map_filename>] [-b <map_bbox_name>] [-g <map_generic_turn_probs_filename>] [-t <map_trace_turn_probs_filename>] [-c <classifier_path>] [-e <max_error_target>] [-o <output_directory>] [-i <unique_id>] [-h]"
            exit()
    
    if (max_error_target is not None):
        max_error_thresholds = [max_error_target]
    
    max_error_thresholds = list(set(map(lambda x: int(x), max_error_thresholds)))
    max_error_thresholds.sort()
    
    max_duration_thresholds = list(set(map(lambda x: int(x), max_duration_thresholds)))
    max_duration_thresholds.sort()
    
    if (max_duration_thresholds[-1] > max_duration):
        max_duration = max_duration_thresholds[-1]
    
    # if (debug):
    #     sys.stdout.write("extrapolator_index: " + str(extrapolator_index) + "\n")
    #     sys.stdout.write("max_error_thresholds: " + str(max_error_thresholds) + "\n")
    #     sys.stdout.write("max_duration_thresholds: " + str(max_duration_thresholds) + "\n")
    #     sys.stdout.write("map_filename: " + str(map_filename) + "\n")
    #     sys.stdout.write("map_bbox_name: " + str(map_bbox_name) + "\n")
    #     sys.stdout.write("map_generic_turn_probs_filename: " + str(map_generic_turn_probs_filename) + "\n")
    #     sys.stdout.write("map_trace_turn_probs_filename: " + str(map_trace_turn_probs_filename) + "\n")
    #     sys.stdout.write("output_directory: " + str(output_directory) + "\n")
    #     sys.stdout.write("unique id: " + str(unique_id) + "\n\n")
    #     sys.stdout.flush()
    
    if (extrapolator_index == 0):
        extrapolator = ConstantLocationExtrapolator()
    elif (extrapolator_index == 1):
        extrapolator = ConstantVelocityExtrapolator()
    elif (extrapolator_index == 2):
        extrapolator = ConstantAccelerationExtrapolator()
    elif (extrapolator_index == 3):
        extrapolator = ConstantDecelerationExtrapolator()
    
    elif (extrapolator_index == 4): # stop at intersection (w/constant velocity)
        extrapolator = MapExtrapolator(map_filename, map_bbox_name, step_mode=0)
    elif (extrapolator_index == 5): # travel along in straight direction (w/constant velocity)
        extrapolator = MapExtrapolatorStraightRoad(map_filename, map_bbox_name, step_mode=0)
    
    elif (extrapolator_index == 6): # generic turn proportions (w/constant velocity)
        extrapolator = MapExtrapolatorNMM(map_filename, map_generic_turn_probs_filename, map_bbox_name, step_mode=0)
    elif (extrapolator_index == 7): # generic turn proportions w/straight road (w/constant velocity)
        extrapolator = MapExtrapolatorNMMStraightRoad(map_filename, map_generic_turn_probs_filename, map_bbox_name, step_mode=0)
    
    elif (extrapolator_index == 8): # trace-based turn proportions (w/constant velocity)
        extrapolator = MapExtrapolatorNMM(map_filename, map_trace_turn_probs_filename, map_bbox_name, step_mode=0)
    elif (extrapolator_index == 9): # trace-based turn proportions w/straight road (w/constant velocity)
        extrapolator = MapExtrapolatorNMMStraightRoad(map_filename, map_trace_turn_probs_filename, map_bbox_name, step_mode=0)
    
    elif (extrapolator_index == 10): # trace-based turn proportions (10th-order Markov Model) (w/constant velocity)
        extrapolator = MapExtrapolatorNMM(map_filename, map_trace_turn_probs_filename, map_bbox_name, prev_trajectory_node_limit=11, step_mode=0)
    elif (extrapolator_index == 11): # trace-based turn proportions w/straight road (10th-order Markov Model) (w/constant velocity)
        extrapolator = MapExtrapolatorNMMStraightRoad(map_filename, map_trace_turn_probs_filename, map_bbox_name, prev_trajectory_node_limit=11, step_mode=0)
    
    elif (extrapolator_index == 12): # or extrapolator_index == 15):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="e", max_error_target=max_error_target)
    elif (extrapolator_index == 13): # or extrapolator_index == 16):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="dx")
    
    else:
        print "ERROR!! Invalid extrapolator index: " + str(extrapolator_index)
        exit(-1)
    
    error_threshold_files = {}
    duration_threshold_files = {'mean':{}, 'max':{}}
    
    extrapolated_paths_file = None
    
    if (debug):
        if (unique_id is None):
            extrapolated_paths_file = gzip.open(output_directory + "/extrapolated_paths_x" + str(extrapolator_index) + ".txt.gz", 'wb')
        else:
            extrapolated_paths_file = gzip.open(output_directory + "/extrapolated_paths_x" + str(extrapolator_index) + "_i" + str(unique_id) + ".txt.gz", 'wb')
    
    for error_threshold in max_error_thresholds:
        if (unique_id is None):
            error_threshold_files[error_threshold] = gzip.open(output_directory + "/sample_time_table_x" + str(extrapolator_index) + "_e" + str(error_threshold) + ".txt.gz", 'wb')
        else:
            error_threshold_files[error_threshold] = gzip.open(output_directory + "/sample_time_table_x" + str(extrapolator_index) + "_e" + str(error_threshold) + "_i" + str(unique_id) + ".txt.gz", 'wb')
    
    for duration_threshold in max_duration_thresholds:
        if (unique_id is None):
            duration_threshold_files['mean'][duration_threshold] = gzip.open(output_directory + "/sample_time_table_x" + str(extrapolator_index) + "_dm" + str(duration_threshold) + ".txt.gz", 'wb')
            duration_threshold_files['max'][duration_threshold] = gzip.open(output_directory + "/sample_time_table_x" + str(extrapolator_index) + "_dx" + str(duration_threshold) + ".txt.gz", 'wb')
        else:
            duration_threshold_files['mean'][duration_threshold] = gzip.open(output_directory + "/sample_time_table_x" + str(extrapolator_index) + "_dm" + str(duration_threshold) + "_i" + str(unique_id) + ".txt.gz", 'wb')
            duration_threshold_files['max'][duration_threshold] = gzip.open(output_directory + "/sample_time_table_x" + str(extrapolator_index) + "_dx" + str(duration_threshold) + "_i" + str(unique_id) + ".txt.gz", 'wb')
    
    extrapolator_testbench = ExtrapolatorTestbench()
    extrapolator_testbench.build_sample_time_tables(sys.stdin, extrapolator, max_error_thresholds, max_duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file)
    
    if (debug): extrapolated_paths_file.close()
    
    map(lambda x: x.close(), error_threshold_files.values())
    map(lambda x: x.close(), duration_threshold_files['mean'].values())
    map(lambda x: x.close(), duration_threshold_files['max'].values())
