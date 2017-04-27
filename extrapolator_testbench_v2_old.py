from location import MapMatchedLocationWithEstimatedValues
from pylibs import spatialfunclib

debug = False

class ExtrapolatorTestbench:
    def __init__(self):
        pass
    
    def _get_error_threshold_duration(self, location_params, trip, extrapolator, max_duration, error_threshold):
        time_offsets = []
        
        for i in range(0, len(trip)):
            time_offsets.append(trip[i].time - location_params[0].time)
            
            if (time_offsets[-1] > max_duration):
                break
        
        num_time_offsets = len(time_offsets)
        #print "time_offsets: " + str(time_offsets)
        
        extrapolated_trajectory = extrapolator.get_trajectory(location_params, time_offsets)
        ground_truth_trajectory = trip[:num_time_offsets]
        
        assert(num_time_offsets == len(extrapolated_trajectory) == len(ground_truth_trajectory))
        
        prev_error = 0.0
        prev_duration = 0.0
        
        for i in range(0, num_time_offsets):
            curr_duration = time_offsets[i]
            curr_ground_truth_location = ground_truth_trajectory[i]
            curr_extrapolated_location = extrapolated_trajectory[i]
            
            curr_error = self._distance(curr_ground_truth_location, curr_extrapolated_location)
            
            if (curr_error > error_threshold):
                return (prev_error, prev_duration, i, 1)
            
            elif (i == (num_time_offsets - 1)):
                return (curr_error, curr_duration, i, 0)
            
            prev_error = curr_error
            prev_duration = curr_duration
        
        # if we reach here, something has gone horribly wrong!
        print "ERROR!! You shall not pass!"
        exit()
    
    def _get_duration_threshold_error(self, location_params, trip, extrapolator, duration_threshold):
        time_offsets = []
        
        for i in range(0, len(trip)):
            time_offsets.append(trip[i].time - location_params[0].time)
            
            if (time_offsets[-1] > duration_threshold):
                break
        
        num_time_offsets = len(time_offsets)
        #print "time_offsets: " + str(time_offsets)
        
        extrapolated_trajectory = extrapolator.get_trajectory(location_params, time_offsets)
        ground_truth_trajectory = trip[:num_time_offsets]
        
        assert(num_time_offsets == len(extrapolated_trajectory) == len(ground_truth_trajectory))
        
        extrapolation_errors = [self._distance(x, y) for (x, y) in zip(ground_truth_trajectory, extrapolated_trajectory)]
        
        max_duration = time_offsets[-1]
        
        if (max_duration > duration_threshold):
            mean_error = sum(extrapolation_errors[:-1]) / (num_time_offsets - 1)
            max_error = max(extrapolation_errors[:-1])
        else:
            mean_error = sum(extrapolation_errors) / num_time_offsets
            max_error = max(extrapolation_errors)
        
        return (max_duration, mean_error, max_error, (num_time_offsets - 1), int(max_duration > duration_threshold))
    
    def build_sample_time_tables(self, trace, extrapolator, error_thresholds, duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file):
        sample_index = 0
        curr_trip = []
        
        for raw_location in trace:
            if (raw_location == "\n"):
                if (len(curr_trip) > 1):
                    self._evaluate_error_thresholds(curr_trip, sample_index, extrapolator, error_thresholds, error_threshold_files, max_duration)
                    self._evaluate_duration_thresholds(curr_trip, sample_index, extrapolator, duration_thresholds, duration_threshold_files)
                    sample_index += len(curr_trip)
                curr_trip = []
            
            else:
                curr_location = MapMatchedLocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                curr_trip.append(curr_location)
        
        if (len(curr_trip) > 1):
            self._build_sample_time_table(curr_trip, sample_index, extrapolator, error_thresholds, duration_thresholds, error_threshold_files, duration_threshold_files, max_duration, extrapolated_paths_file)
    
    def _evaluate_error_thresholds(self, trip, sample_index, extrapolator, error_thresholds, error_threshold_files, max_duration):
        for i in range(0, len(trip) - 1):
            for error_threshold in error_thresholds:
                #print "error threshold: " + str(error_threshold)
                self._evaluate_error_threshold(trip[i:], (sample_index + i), extrapolator, error_threshold, error_threshold_files[error_threshold], max_duration)
    
    def _evaluate_duration_thresholds(self, trip, sample_index, extrapolator, duration_thresholds, duration_threshold_files):
        for i in range(0, len(trip) - 1):
            for duration_threshold in duration_thresholds:
                #print "duration threshold: " + str(duration_threshold)
                self._evaluate_duration_threshold(trip[i:], (sample_index + i), extrapolator, duration_threshold, duration_threshold_files['mean'][duration_threshold], duration_threshold_files['max'][duration_threshold])
    
    def _evaluate_error_threshold(self, trip, sample_index, extrapolator, error_threshold, error_threshold_file, max_duration):
        trip_index = 0
        trip_length = len(trip)
        #print "trip_length: " + str(trip_length)
        
        while (trip_index < len(trip)):
            if (trip_index == 0):
                curr_location_params = extrapolator.init_location_params(trip[trip_index])
            else:
                curr_location_params = extrapolator.get_location_params(trip[trip_index])
            
            #print "curr trip_index: " + str(trip_index)
            (error, duration, trip_index_offset, crossed_threshold) = self._get_error_threshold_duration(curr_location_params, trip[trip_index:], extrapolator, max_duration, error_threshold)
            
            error_threshold_file.write(str(sample_index + trip_index) + " " + str(trip[trip_index].lat) + " " + str(trip[trip_index].lon) + " " + str(duration) + " " + str(crossed_threshold) + "\n")
            
            if (trip_index_offset <= 0):
                trip_index_offset = 1
            
            trip_index += trip_index_offset
            
            if (trip_index >= (trip_length - 1)):
                break
    
    def _evaluate_duration_threshold(self, trip, sample_index, extrapolator, duration_threshold, mean_error_duration_threshold_file, max_error_duration_threshold_file):
        trip_index = 0
        trip_length = len(trip)
        #print "trip_length: " + str(trip_length)
        
        while (trip_index < len(trip)):
            if (trip_index == 0):
                curr_location_params = extrapolator.init_location_params(trip[trip_index])
            else:
                curr_location_params = extrapolator.get_location_params(trip[trip_index])
            
            #print "curr trip_index: " + str(trip_index)
            (duration, mean_error, max_error, trip_index_offset, crossed_threshold) = self._get_duration_threshold_error(curr_location_params, trip[trip_index:], extrapolator, duration_threshold)
            
            mean_error_duration_threshold_file.write(str(sample_index + trip_index) + " " + str(trip[trip_index].lat) + " " + str(trip[trip_index].lon) + " " + str(mean_error) + " " + str(crossed_threshold) + "\n")
            max_error_duration_threshold_file.write(str(sample_index + trip_index) + " " + str(trip[trip_index].lat) + " " + str(trip[trip_index].lon) + " " + str(max_error) + " " + str(crossed_threshold) + "\n")
            
            if (trip_index_offset <= 0):
                trip_index_offset = 1
            
            trip_index += trip_index_offset
            
            if (trip_index >= (trip_length - 1)):
                break
    
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
    
    elif (extrapolator_index == 12 or extrapolator_index == 15):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="e", max_error_target=max_error_target)
    elif (extrapolator_index == 13 or extrapolator_index == 16):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="dx")
    elif (extrapolator_index == 14 or extrapolator_index == 17):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="table", max_error_target=max_error_target)
    
    elif (extrapolator_index == 18): # trace-based turn proportions (w/constant velocity)
        extrapolator = MapExtrapolatorNMM(map_filename, map_trace_turn_probs_filename, map_bbox_name, step_mode=0)
    elif (extrapolator_index == 19): # trace-based turn proportions w/straight road (w/constant velocity)
        extrapolator = MapExtrapolatorNMMStraightRoad(map_filename, map_trace_turn_probs_filename, map_bbox_name, step_mode=0)
    
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
