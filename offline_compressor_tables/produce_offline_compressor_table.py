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
    def __init__(self, delay=0):
        self.estimation_window = []
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
                        errors=self.process_trip(self.trip)
                        self.write_list_to_file(errors, output_file)
                        
                    self.trip = [curr_location]
                    need_init = False  

                else:
                    #sampler.update(extrapolator.get_location_params(curr_location))
                    self.trip.append(curr_location)
                    #self.update_time_error_table(extrapolator.get_location_params(curr_location), extrapolator)

        output_file.close()



    def write_list_to_file(self, lst, output_file):
        for element in lst:
            max_error, mean_error = element
            output_file.write(str(max_error)+" "+str(mean_error)+"\n")


    def process_trip(self, trip):
        
        error_windows=[]

        for i in range(len(trip)):
            delay_window = [(trip[i], None)]# None for param here

            j=i+1
            try:
                curr_loc = trip[j]
                while(curr_loc.time - delay_window[0][0].time <= self.delay):
                    delay_window.append((trip[j],None)) # None for param here
                    j = j+1
                    curr_loc = trip[j]

            except: # means we don't have enough samples in this estimation window to have a full delay window, so return 1
                return error_windows
                #print "not enough samples"


            #print map(lambda (loc, param): loc.time, delay_window)
            compressed_window = self.get_compressed_window_size_bound(delay_window, 4) 
            compression_errors = self.get_compression_error(delay_window, compressed_window)    
            max_error=max(compression_errors)
            mean_error=self.mean(compression_errors)
            
            error_windows.append((max_error, mean_error))
            #print error_windows
        
        return error_windows


    def get_compressed_window_size_bound(self, loc_param_window, compressed_window_size):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print map(lambda loc: loc.time, locations_from_window)
        compressed_indices = self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
        compressed_window = [loc_param_window[index] for index in compressed_indices]
        return compressed_window


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
    map_generic_turn_probs_filename = None

    time_error_table_pickle_filename = None
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:d:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-d":
            delay = int(a)
        elif o == "-h":
            print "Usage: python produce_compressor_table [-i input_file_name] [-o output_file_name] [-d delay] [-h]"
            exit()
    
    if input_filename == "" or output_filename=="":
        print "Usage: python produce_offline_compressor_table [-i input_file_name] [-o output_file_name] [-d delay] [-h]"
        exit()
    
    
    tableCreator = TableCreator(delay)
    

    tableCreator.run(input_filename, output_filename)
    
    
