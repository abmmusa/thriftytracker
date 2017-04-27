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

class TableCreator:
    def __init__(self, error=0, delay=0):
        self.estimation_window = []
        self.error= error
        self.delay = delay        
        self.gps_compressor = GPSCompressor()

    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)
    

    def run(self, input_filename, output_file):
        if input_filename == "None":
            return

        trace_file = gzip.open(input_filename, 'rb')
        
        trace = trace_file.readlines()
            
        #print trace
        need_init = True
        self.trip = []
 
        
        output_file=open(output_filename, 'w')

        for raw_location in trace:
            if (raw_location == "\n"):
                need_init = True
                #print f
                
            else:
                curr_location = MapMatchedLocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                    
                if (need_init is True):
                    if self.trip:
                        stats=self.process_trip(self.trip) # statis contain max_error, mean_error, usage
                        self.write_list_to_file(stats, output_file)
                        
                    self.trip = [curr_location]
                    need_init = False  

                else:
                    #sampler.update(extrapolator.get_location_params(curr_location))
                    self.trip.append(curr_location)
                    #self.update_time_error_table(extrapolator.get_location_params(curr_location), extrapolator)

        output_file.close()



    def write_list_to_file(self, lst, output_file):
        for element in lst:
            max_error, mean_error, window_size, usage = element
            output_file.write(str(max_error)+" "+str(mean_error)+" "+str(window_size)+" "+str(usage)+"\n")


    def process_trip(self, trip):
        
        stat_windows=[]

        for i in range(len(trip)):
            delay_window = [(trip[i], None)]# None for param here

            j=i+1
            try:
                curr_loc = trip[j]
                while(curr_loc.time - delay_window[0][0].time < self.delay):
                    delay_window.append((trip[j],None)) # None for param here
                    j = j+1
                    curr_loc = trip[j]

            except: # means we don't have enough samples in this estimation window to have a full delay window, so return 1
                return stat_windows
                #print "not enough samples"


            #print map(lambda (loc, param): loc.time, delay_window)
            #compressed_window = self.get_compressed_window_size_bound(delay_window, 4) 
            compressed_window = self.get_compressed_window_max_error_bounded_usage_optimized(delay_window, self.error) 
            compression_errors = self.get_compression_error(delay_window, compressed_window)    
            max_error=max(compression_errors)
            mean_error=self.mean(compression_errors)
            window_size=len(compressed_window)
            usage = self.get_tx_bytes(window_size)

            stat_windows.append((max_error, mean_error, window_size, usage))
            #print stat_windows
        
        return stat_windows


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


    #
    # returns error bounded compressed window with max possible samples packed without consuming additional usage
    # 
    def get_compressed_window_max_error_bounded_usage_optimized(self, loc_param_window, max_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print "locs from window", len(locations_from_window)
        #print "locs from window max_error bound", map(lambda loc: loc.time, locations_from_window)
        compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 
        #print len(compressed_indices)

        final_compression_size = len(compressed_indices)
        #if len(compressed_indices) > self.delay/4:
        #    final_compression_size = int(self.delay/4)

        if final_compression_size > self.delay:
            final_compression_size = self.delay

        #print final_compression_size, "final"

        window_size_with_same_budget = self.get_max_window_size_for_same_budget(final_compression_size)
        #print window_size_with_same_budget

        # now get the size bounded gps compressed window
        compressed_indices_final = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, window_size_with_same_budget)

        #print "from sampler, compressed indices", compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices_final]


        #print map(lambda loc_param: loc_param[0].time, compressed_window)  
        return compressed_window


    # def get_compressed_window_error_bounded(self, loc_param_window, max_error):
    #     locations_from_window = map(lambda (loc,param):loc, loc_param_window)
    #     if debug1: print "locs from window", map(lambda loc: loc.time, locations_from_window)
    #     compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 
    #     if debug1: print "from sampler, compressed indices", compressed_indices
    #     compressed_window = [loc_param_window[index] for index in compressed_indices]

    #     #print map(lambda loc_param: loc_param[0].time, compressed_window)  
    #     return compressed_window


    # def get_compressed_window_size_bound(self, loc_param_window, compressed_window_size):
    #     locations_from_window = map(lambda (loc,param):loc, loc_param_window)
    #     #print map(lambda loc: loc.time, locations_from_window)
    #     compressed_indices = self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
    #     compressed_window = [loc_param_window[index] for index in compressed_indices]
    #     return compressed_window


    def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
        locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
        locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)
        
        #print "unc",map(lambda loc: loc.time, locations_uncompressed_window)
        #print "cmp",map(lambda loc: loc.time, locations_compressed_window)

        compression_error = self.gps_compressor.get_compression_error_list(locations_uncompressed_window, locations_compressed_window)
        return compression_error


    # return mean of a list
    def mean(self, l):
        return sum(l)/len(l)
    

 

import sys, getopt

if __name__ == "__main__":
    
    input_filename = ""
    output_filename = ""
    error = None
    delay = None

    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:e:d:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-e":
            error = int(a)
        elif o == "-d":
            delay = int(a)
        elif o == "-h":
            print "Usage: python produce_compressor_table [-i input_file_name] [-o output_file_name] [-e error] [-d delay] [-h]"
            exit()
    
    if input_filename == "" or output_filename=="":
        print "Usage: python produce_offline_compressor_table [-i input_file_name] [-o output_file_name] [-e error] [-d delay] [-h]"
        exit()
    
    
    tableCreator = TableCreator(error,delay)
    

    tableCreator.run(input_filename, output_filename)
    
    
