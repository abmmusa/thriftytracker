# here interval/time_interval is the interval for tx for a given budget. 

import os
import gzip
from location import MapMatchedLocationWithEstimatedValues
from pylibs import spatialfunclib
from glob import glob
import pickle
import math

debug = True

MAX_BUCKETS=35 #if changed here, change at produce_offline_exponentialerror_expected_reachtime_table.py too

class BudgetErrorTableCreator:
    def __init__(self, window_size = 600, time_error_table_pickle_filename=None):
        self.estimation_window = []
        self.window_size = window_size #seconds
        self.error_upper_bounds = self.get_error_upper_bounds()
        
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
    
    def run(self, trace_dir, extrapolator):
        files=[]
        
        if (trace_dir == "None"):
            return
        elif (trace_dir.endswith(".txt.gz")):
            files = [trace_dir]
        else:
            for path,_,_ in os.walk(trace_dir):
                files.extend(glob(os.path.join(path,"*.txt.gz")))
        
        for f in files:
            if (debug):
                print f
            
            trace_file = gzip.open(f, 'rb')
            
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

    # return mean of a list
    def mean(self, l):
        return sum(l)/len(l)

    def update_time_error_table(self, curr_loc_param, extrapolator):

        (curr_loc, curr_param) = curr_loc_param

        # print curr_loc.time, self.estimation_window[0][0].time
        if(curr_loc.time - self.estimation_window[0][0].time <= self.window_size):
            self.estimation_window.append(curr_loc_param)
            #print "append", curr_loc.time

        else:
            if not self.estimation_window:
                return

            (start_loc, start_param) = self.estimation_window[0]
            time_intervals = map(lambda (loc, param): int(loc.time - start_loc.time), self.estimation_window[1:])
            extrapolated_trajectory = extrapolator.get_trajectory((start_loc, start_param), time_intervals)

            exact_trajectory = map(lambda (loc, param): loc, self.estimation_window[1:])

            extrapolation_errors = map(lambda extrapolated_loc, exact_loc: self._distance(extrapolated_loc, exact_loc), extrapolated_trajectory, exact_trajectory)
            
            
            time_intervals_interpolated = []
            extrapolation_errors_interpolated = []

            for i in range(0, len(time_intervals)):
                time_intervals_interpolated.append(time_intervals[i])
                extrapolation_errors_interpolated.append(extrapolation_errors[i])

                if i<len(time_intervals)-1:
                    if time_intervals[i+1] - time_intervals[i] > 1: # we need to interpolate
                        del_extrapolation_error = extrapolation_errors[i+1] - extrapolation_errors[i]
                        del_time = time_intervals[i+1] - time_intervals[i]

                        # interpolate over time
                        for j in range(int(time_intervals[i]+1), int(time_intervals[i+1])):
                            time_gap = j - time_intervals[i]
                            if debug:
                                print j, del_time, del_extrapolation_error
                            error = extrapolation_errors[i]+float(time_gap)/float(del_time)*del_extrapolation_error
                        
                            time_intervals_interpolated.append(j)
                            extrapolation_errors_interpolated.append(error)


            
            # find mean extrapolation error for each time interval
            mean_extraploation_errors_interpolated = []
            for i in range(0, len(extrapolation_errors_interpolated)):
                mean_extraploation_errors_interpolated.append( self.mean(extrapolation_errors_interpolated[0:i+1]) )



            # get buckets for errors
            extrapolation_error_buckets = map(lambda error: self.get_bucket_from_error(error), extrapolation_errors_interpolated)
            

            # unique_buckets=sorted(list(set(extrapolation_error_buckets)))

            # # as we are calculating reach-time, take only the first-time some error bucket is reached
            # first_index_for_extrapolation_error_buckets = [extrapolation_error_buckets.index(bucket) for bucket in unique_buckets]

            # # put together the reach-time and error bucket 
            # reachtime_error = map(lambda index: (time_intervals_interpolated[index], extrapolation_error_buckets[index]), first_index_for_extrapolation_error_buckets)
            reachtime_error = map(lambda index: (time_intervals_interpolated[index], extrapolation_error_buckets[index]), range(0, len(extrapolation_error_buckets)))

            #print reachtime_error

            # now we need to fill-up the missing error buckets over time 
            # e.g. if we reached error bucket 1 and 3 respectively at reach-time 1 and 2, 
            # then we also need to fill up that we went through error bucket 2
            reachtime_error_bucket_interpolated = []
            for i in range(0, len(reachtime_error)):
                reachtime_error_bucket_interpolated.append(reachtime_error[i])
                
                if i<len(reachtime_error)-1:
                    (curr_time, curr_bucket) = reachtime_error[i]
                    (next_time, next_bucket) = reachtime_error[i+1]
                    
                    if next_bucket - curr_bucket > 1:
                        del_bucket = next_bucket - curr_bucket
                        del_time = next_time - curr_time
                        for j in range(curr_bucket+1, next_bucket):
                            bucket_gap = j - curr_bucket
                            time = int(math.ceil(curr_time + float(bucket_gap)/float(del_bucket)*del_time))
                            
                            reachtime_error_bucket_interpolated.append((time, j))
                
            
            if debug:
                print "time intervals:", time_intervals
                print "errors:", extrapolation_errors

                print "interpolated time intervals:", time_intervals_interpolated
                print "interpolated extrapolation error:", extrapolation_errors_interpolated

                print "interpolated mean extrapolation error", mean_extraploation_errors_interpolated

                print "extrapolated error buckets:", extrapolation_error_buckets
                #print "unique buckets", unique_buckets

                #print "first index for extr error buckets:", first_index_for_extrapolation_error_buckets
                print "reachtime errorbuckets:", reachtime_error

                print "extrapolated reachtime error buckets:", reachtime_error_bucket_interpolated
                
            
            for (reachtime, bucket) in reachtime_error_bucket_interpolated:
                #print reachtime-1, bucket
                self.time_error_table[reachtime-1][bucket] += 1
            
            #print time_intervals
            #print extrapolation_errors
            #print time_intervals_interpolated
            #print extrapolation_error_buckets
            #print unique_buckets
            #print first_index_for_extrapolation_error_buckets
            #print reachtime_error
            #print reachtime_error_bucket_interpolated
            #print self.time_error_table[0]
            #print "\n"

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
    
    input_directory = ""
    output_filename = ""
    window_size = int(600)
    
    extrapolator_index=0

    # parameters for unified extrapolator
    sampler_error_threshold = None
    map_filename = None
    map_trace_turn_probs_filename = None
    classifier_path = None
    
    time_error_table_pickle_filename = None
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:x:w:e:f:p:c:t:h")
    
    for o,a in opts:
        if o == "-i":
            input_directory = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-x":
            extrapolator_index = int(a)
        elif o == "-w":
            window_size = int(a)
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
            print "Usage: python produce_offline_time_error_table [-i input_directory] [-o output_file_name] [-x extrapolator_index] [-w window_size] [-e <sampler_error_threshold>] [-f <map_filename>] [-p <map_trace_turn_probs_filename>] [-c <classifier_path>] [-t <time_error_table_pickle_filename>] [-h]"
            exit()
    
    if input_directory == "" or output_filename=="":
        print "Usage: python produce_offline_reachtime_exponentialerror_table [-i input_directory] [-o output_file_name] [-x extrapolator_index] [-w window_size] [-e <sampler_error_threshold>] [-f <map_filename>] [-p <map_trace_turn_probs_filename>] [-c <classifier_path>] [-t <time_error_table_pickle_filename>] [-h]"
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
    
    timeErrorTableCreator = BudgetErrorTableCreator(window_size, time_error_table_pickle_filename)
    timeErrorTableCreator.run(input_directory, extrapolator)
    
    output_file = open(output_filename, 'wb')
    pickle.dump(timeErrorTableCreator.time_error_table, output_file)
    output_file.close()
    #print timeErrorTableCreator.time_error_table
    
    #output_file=open(output_directory+"/"+output_filename, 'w')
    #timeErrorTableCreator.write_time_error_table_with_bucket(output_file)
