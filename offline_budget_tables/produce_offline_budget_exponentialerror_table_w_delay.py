# here interval/time_interval is the interval for tx for a given budget. 

import os
import gzip
from location import MapMatchedLocationWithEstimatedValues
from pylibs import spatialfunclib
from glob import glob
import pickle
import math

from gps_compressor import GPSCompressor
import fast_gps_compressor

debug = False

MAX_BUCKETS=35 #if changed here, change at produce_offline_exponentialerror_expected_reachtime_table.py too

class BudgetErrorTableCreator:
    def __init__(self, window_size = 600, delay=8, time_error_table_pickle_filename=None):
        self.estimation_window = []
        self.window_size = window_size #seconds
        self.delay = delay
        self.error_upper_bounds = self.get_error_upper_bounds()
        
        self.gps_compressor = GPSCompressor()

        if (time_error_table_pickle_filename is None):
            self.time_error_table = self.init_time_error_table() # NOTE: row 0 is for budget interval 1 and so on...
        else:
            self.time_error_table = self.load_time_error_table(time_error_table_pickle_filename)
        
        #print self.error_upper_bounds
        #print self.time_error_table, len(self.time_error_table), len(self.time_error_table[0])
    
    def init_time_error_table(self):
        time_error_table = [[0 for x in range(MAX_BUCKETS)] for x in range(self.window_size)]
        return time_error_table
    
    def load_time_error_table(self, time_error_table_pickle_filename):
        time_error_table_pickle_file = open(time_error_table_pickle_filename, 'rb')
        time_error_table = pickle.load(time_error_table_pickle_file)
        time_error_table_pickle_file.close()
        return time_error_table
    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)
    
    def get_error_upper_bounds(self):
        error_upper_bounds=sorted(list(set([round(math.pow(2,i)**(1.0/2.0)) for i in range(0, MAX_BUCKETS-1)])))
        error_upper_bounds.insert(0, 0.0)
        #print error_upper_bounds, len(error_upper_bounds)
        return error_upper_bounds

    # TODO: produce a separate class, this function is needed in the process_evals_new.py too
    # returns tx bytes from window size
    def get_tx_bytes(self, window_size):
        header_size = 32
        timestamp_size = 4 #4 byte timestamp of the first sample in the window
        payload_size = 9 #one byte differential time from timestamp. So delay can go up to 256 
        const = 10

        return math.ceil( (header_size + timestamp_size + window_size*payload_size + const)/42.0 )*42.0

    # returns max possible window size without increasing the budget
    def get_max_window_size_for_same_budget(self, window_size):
        max_window_size = window_size
        tx_bytes_current = self.get_tx_bytes(window_size)
        while (self.get_tx_bytes(max_window_size) <= tx_bytes_current):
            max_window_size += 1

        return max_window_size-1

    
    def run(self, input_filename, extrapolator):
        trace_file = gzip.open(input_filename, 'rb')
        
        trace = trace_file.readlines()
            
        #print trace
        need_init = True
        self.estimation_window = []
 
        for raw_location in trace:
            if (raw_location == "\n"):
                need_init = True
                #print f
                
            else:
                curr_location = MapMatchedLocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                    
                if (need_init is True):
                    self.estimation_window = [extrapolator.init_location_params(curr_location)]
                    need_init = False  

                else:
                    #sampler.update(extrapolator.get_location_params(curr_location))
                    self.update_time_error_table(extrapolator.get_location_params(curr_location), extrapolator)


    def get_bucket_from_error(self, error):
        if error == 0.0:
            return 0

        for i in range(0, len(self.error_upper_bounds)-1):
            if error>self.error_upper_bounds[i] and error<=self.error_upper_bounds[i+1]:
                return i+1

        # all error values greater than the max error in the error_upper_bounds goes to the last bucket
        return MAX_BUCKETS-1

    def get_error_range_from_bucket(self, bucket_no):
        if bucket_no > MAX_BUCKETS-1:
            return None

        if bucket_no == 0:
            return (0.0, 0.0)

        if bucket_no == MAX_BUCKETS-1:
            return (self.error_upper_bounds[MAX_BUCKETS-1], float('inf'))
        
        return (self.error_upper_bounds[bucket_no-1], self.error_upper_bounds[bucket_no])


    # def get_compressed_window(self, loc_param_window, compressed_window_size):
    #     locations_from_window = map(lambda (loc,param):loc, loc_param_window)
    #     #print map(lambda loc: loc.time, locations_from_window)
    #     compressed_indices = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
    #     #print compressed_indices
    #     compressed_window = [loc_param_window[index] for index in compressed_indices]
    #     return compressed_window


    #
    # returns a compressed window that have mean compression error less than or equal to the given mean error
    #
    # def get_compressed_window(self, loc_param_window, given_compressed_window_mean_error):
    #     locations_from_window = map(lambda (loc,param):loc, loc_param_window)
    #     #print map(lambda loc: loc.time, locations_from_window)

    #     if ( len(loc_param_window) <=4 ):
    #         return loc_param_window

    #     for compressed_window_size in range(4,len(loc_param_window)):
    #         compressed_indices = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
    #         #print compressed_indices
    #         compressed_window = [loc_param_window[index] for index in compressed_indices]
    #         #print compressed_window
    #         mean_compression_error = self.get_compression_error(loc_param_window, compressed_window)/len(loc_param_window)
    #         if mean_compression_error <= given_compressed_window_mean_error:
    #             return compressed_window

    #     return loc_param_window


    def get_compressed_window_error_bounded(self, loc_param_window, max_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        # print "locs from window", map(lambda loc: loc.time, locations_from_window)
        compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 

        window_size_with_same_budget = self.get_max_window_size_for_same_budget(len(compressed_indices))
        #print window_size_with_same_budget

        # now get the size bounded gps compressed window
        compressed_indices_final = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, window_size_with_same_budget)

        #print "from sampler, compressed indices", compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices_final]


        #print map(lambda loc_param: loc_param[0].time, compressed_window)  
        return compressed_window


    def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
        locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
        locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)

        compression_error = fast_gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
        #print compression_error
        return compression_error


    # return mean of a list
    def mean(self, l):
        return sum(l)/len(l)
    

    # returns mean extrapolation and compression error
    def get_mean_extrapolation_compression_error(self, extrapolation_errors, estimation_window_starting_compression_loc):
        delay_window_for_compression = []
        delay_window_for_compression.append(estimation_window_starting_compression_loc[0]) 
        
        i=0
        (curr_loc, curr_param) = estimation_window_starting_compression_loc[i]
        try:
            while(curr_loc.time - delay_window_for_compression[0][0].time <= self.delay):
                delay_window_for_compression.append(estimation_window_starting_compression_loc[i])
                i = i+1
                (curr_loc, curr_param) = estimation_window_starting_compression_loc[i]
                
        except: # means we don't have enough samples in this estimation window to have a full delay window, so return 1
            return -1

        # now we have a delay window, so get the mean compression error
        #compressed_window = self.get_compressed_window(delay_window_for_compression, mean_extrapolation_error) #old was window_size
        compressed_window = self.get_compressed_window_error_bounded(delay_window_for_compression, max(extrapolation_errors)) 
        mean_compression_error = self.get_compression_error(delay_window_for_compression, compressed_window)/len(delay_window_for_compression)

        mean_extrapolation_error = self.mean(extrapolation_errors)

        mean_extrapolation_compression_error = (mean_extrapolation_error*len(extrapolation_errors) + mean_compression_error*len(delay_window_for_compression))/(len(extrapolation_errors)+len(delay_window_for_compression))

        time = delay_window_for_compression[-1][0].time

        return (time, mean_extrapolation_compression_error)


    def update_time_error_table(self, curr_loc_param, extrapolator):

        (curr_loc, curr_param) = curr_loc_param

        # print curr_loc.time, self.estimation_window[0][0].time
        if(curr_loc.time - self.estimation_window[0][0].time <= self.window_size):
            self.estimation_window.append(curr_loc_param)

        else:
            if not self.estimation_window:
                return

            (start_loc, start_param) = self.estimation_window[0]
            time_intervals = map(lambda (loc, param): int(loc.time - start_loc.time), self.estimation_window)
            extrapolated_trajectory = extrapolator.get_trajectory((start_loc, start_param), time_intervals)

            exact_trajectory = map(lambda (loc, param): loc, self.estimation_window)

            extrapolation_errors = map(lambda extrapolated_loc, exact_loc: self._distance(extrapolated_loc, exact_loc), extrapolated_trajectory, exact_trajectory)
            #print extrapolation_errors
            

            time_errorbuckets = []
            for i in range(0, len(extrapolation_errors)):
                mean_extr_comp_error_at_time = self.get_mean_extrapolation_compression_error(extrapolation_errors[0:i+1], self.estimation_window[i:])
                if mean_extr_comp_error_at_time == -1:
                    break

                #print mean_extr_comp_error_at_time
                (window_end_time, mean_extr_comp_error) = mean_extr_comp_error_at_time
                error_bucket = self.get_bucket_from_error(mean_extr_comp_error)
                time = int(window_end_time-start_loc.time)

                time_errorbuckets.append((time, error_bucket))


            #print time_errorbuckets

            # now we need to fill-up the missing error buckets over time 
            # e.g. if we reached error bucket 1 and 3 respectively at reach-time 1 and 2, 
            # then we also need to fill up that we went through error bucket 2
            time_error_bucket_interpolated = []
            for i in range(0, len(time_errorbuckets)):
                time_error_bucket_interpolated.append(time_errorbuckets[i])
                
                if i<len(time_errorbuckets)-1:
                    (curr_time, curr_bucket) = time_errorbuckets[i]
                    (next_time, next_bucket) = time_errorbuckets[i+1]
                    
                    if next_bucket - curr_bucket > 1:
                        del_bucket = next_bucket - curr_bucket
                        del_time = next_time - curr_time
                        for j in range(curr_bucket+1, next_bucket):
                            bucket_gap = j - curr_bucket
                            time = int(math.ceil(curr_time + float(bucket_gap)/float(del_bucket)*del_time))
                            
                            time_error_bucket_interpolated.append((time, j))
                
            
            if debug:
                print "time errorbuckets:", time_errorbuckets
                print "interpolated time errorbuckets:", time_error_bucket_interpolated
                
            
            for (time, bucket) in time_error_bucket_interpolated:
                self.time_error_table[time-1][bucket] += 1
            
            if debug:
                print self.time_error_table
                print "\n"



            # make room for curr_loc_param in the estimation window
            while( self.estimation_window and (curr_loc.time - self.estimation_window[0][0].time >= self.window_size) ): 
                del self.estimation_window[0]

            # put the curr_loc_param in the estimation window now
            self.estimation_window.append(curr_loc_param)


 

import sys, getopt
from extrapolator import ConstantLocationExtrapolator, ConstantVelocityExtrapolator, UnifiedExtrapolator

if __name__ == "__main__":
    
    input_filename = ""
    output_filename = ""
    window_size = int(600)
    
    extrapolator_index=0

    # parameters for unified extrapolator
    sampler_error_threshold = None
    map_filename = None
    map_trace_turn_probs_filename = None
    classifier_path = None
    
    time_error_table_pickle_filename = None
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:x:w:d:e:f:p:c:t:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-x":
            extrapolator_index = int(a)
        elif o == "-w":
            window_size = int(a)
        elif o == "-d":
            delay = int(a)
        elif o == "-e":
            sampler_error_threshold = float(a)
        elif o == "-f":
            map_filename = str(a)
        elif o == "-p":
            map_trace_turn_probs_filename = str(a)
        elif o == "-c":
            classifier_path = str(a)
        elif o == "-t":
            time_error_table_pickle_filename = str(a)
        elif o == "-h":
            print "Usage: python produce_offline_time_error_table [-i input_file_name] [-o output_file_name] [-x extrapolator_index] [-w window_size] [-d delay] [-e <sampler_error_threshold>] [-f <map_filename>] [-p <map_trace_turn_probs_filename>] [-c <classifier_path>] [-t <time_error_table_pickle_filename>] [-h]"
            exit()
    
    if input_filename == "" or output_filename=="":
        print "Usage: python produce_offline_reachtime_exponentialerror_table [-i input_file_name] [-o output_file_name] [-x extrapolator_index] [-w window_size] [-d delay] [-e <sampler_error_threshold>] [-f <map_filename>] [-p <map_trace_turn_probs_filename>] [-c <classifier_path>] [-t <time_error_table_pickle_filename>] [-h]"
        exit()
    
    if (extrapolator_index == 0):
        extrapolator = ConstantLocationExtrapolator()
    elif (extrapolator_index == 1):
        extrapolator = ConstantVelocityExtrapolator()
    elif (extrapolator_index == 2):
        extrapolator = UnifiedExtrapolator(map_filename, None, map_trace_turn_probs_filename, classifier_path, mode="e", max_error_target=sampler_error_threshold)
    elif (extrapolator_index == 3):
        extrapolator = UnifiedExtrapolator(map_filename, None, map_trace_turn_probs_filename, classifier_path, mode="dx")
    elif (extrapolator_index == 4):
        extrapolator = UnifiedExtrapolator(map_filename, None, map_trace_turn_probs_filename, classifier_path, mode="table", max_error_target=sampler_error_threshold)
    elif (extrapolator_index == 5):
        extrapolator = UnifiedExtrapolator(map_filename, None, map_trace_turn_probs_filename, classifier_path, mode="table", max_error_target=sampler_error_threshold)
    else:
        print "ERROR!! Invalid extrapolator index: " + str(extrapolator_index)
        exit()

    output_file = open(output_filename, 'wb')
    
    timeErrorTableCreator = BudgetErrorTableCreator(window_size, delay, time_error_table_pickle_filename)
    timeErrorTableCreator.run(input_filename, extrapolator)
    
    pickle.dump(timeErrorTableCreator.time_error_table, output_file)
    output_file.close()
    #print timeErrorTableCreator.time_error_table
    
    #output_file=open(output_directory+"/"+output_filename, 'w')
    #timeErrorTableCreator.write_time_error_table_with_bucket(output_file)
