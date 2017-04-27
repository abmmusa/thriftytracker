from pylibs import spatialfunclib
import math
import pickle
#from gps_compressor import TDTR, TDTR_window_sized, get_compression_error
from gps_compressor import GPSCompressor
import fast_gps_compressor
from exponential_error_buckets import ExponentialErrorBuckets
import time

MAX_HISTORY=1800

debug=False


class Sampler:
    def __init__(self, server, extrapolator, offline_table_file, offline_table=None): 
        self.server = server
        self.extrapolator = extrapolator
        
        # Offline table here is different for error-delay and budget-delay samplers. 
        # However, both of them uses the table in this parent table.
        if offline_table == None:
            if offline_table_file is None:
                self.offline_table = None
            else:
                if "pkl" in offline_table_file: # TODO: see if this table should be given a generic name
                    self.offline_table = self.load_offline_table_pkl(offline_table_file)
                else:
                    self.offline_table = self.load_offline_table_txt(offline_table_file)
        else:
            self.offline_table = offline_table


        #delay window; list of (location, extrapolation_parameters)
        self.delay_window = []
        self.server_loc_param = None

        #double in size of delay window; list of (location, extrapolation_parameters)
        self.estimation_window = []
        
        self.current_time = None

        self.start_time = None

        self.gps_compressor = GPSCompressor()
        
        # initialize extrapolated trajectory cache (james)
        self.extrapolated_trajectory_cache = {}
        self.extrapolated_trajectory_cache_max_time_offset = None
    

    # used for older separately constructed tables in pickle format
    def load_offline_table_pkl(self, offline_table_file):

        if(offline_table_file == None):
            return None
        else:
            f = open(offline_table_file, "rb")
            offline_table = pickle.load(f)

            #print offline_table
            return offline_table        

    # used for newer extrapolator tables in txt format
    def load_offline_table_txt(self, offline_table_file):

        if(offline_table_file == None):
            return None
        else:
            f = open(offline_table_file, "r")
            offline_table = f.readlines()
            
            offline_table_list = []
            
            for line in offline_table:
                data=line.rstrip("\n").split(" ")
                
                offline_table_list.append((float(data[0]), float(data[1])))
                
            #print offline_table_list
            return offline_table_list


    def init_location(self, curr_loc_param):
        #self.cleanup_last_window()

        self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time

        self.estimation_window = [curr_loc_param]

        self.start_time = self.current_time
        
        # flush extrapolated trajectory cache (james)
        self.extrapolated_trajectory_cache = {}
        self.extrapolated_trajectory_cache_max_time_offset = None
    
        self.transmit_locations()

    def cleanup_last_window(self):
        return 
    
    def update(self, curr_loc_param):        

        self.current_time += 1

        if curr_loc_param is not None:
            self.delay_window.append(curr_loc_param)
        
        if self.transmit_locations():
            del self.delay_window[0]
    


    def transmit_locations(self, output_file):
        return NotImplemented
    

    def get_extrapolation_errors(self, server_loc_param, loc_param_window):
        time_offsets = map(lambda loc_param: int(loc_param[0].time - server_loc_param[0].time), loc_param_window)
        
        if (server_loc_param[0] not in self.extrapolated_trajectory_cache):
            self.extrapolated_trajectory_cache_max_time_offset = max(300, time_offsets[-1] * 10)
            self.extrapolated_trajectory_cache = {server_loc_param[0]: self.extrapolator.get_trajectory(server_loc_param, range(0, self.extrapolated_trajectory_cache_max_time_offset + 1))}
        
        if (time_offsets[-1] > self.extrapolated_trajectory_cache_max_time_offset):
            self.extrapolated_trajectory_cache_max_time_offset = (time_offsets[-1] * 10)
            self.extrapolated_trajectory_cache = {server_loc_param[0]: self.extrapolator.get_trajectory(server_loc_param, range(0, self.extrapolated_trajectory_cache_max_time_offset + 1))}
        
        extrapolated_trajectory = [self.extrapolated_trajectory_cache[server_loc_param[0]][i] for i in time_offsets]
        #extrapolated_trajectory = self.extrapolator.get_trajectory(server_loc_param, time_offsets)
        
        extrapolation_errors = []
        for i in range(0, len(loc_param_window)):
            extrapolation_errors.append(self._distance(loc_param_window[i][0], extrapolated_trajectory[i]))
        
        return extrapolation_errors
    
    # TODO: produce a separate class, this function is needed in the process_evals_new.py too
    # returns tx bytes from window size
    def get_tx_bytes(self, window_size):
        header_size = 32
        timestamp_size = 4 #4 byte timestamp of the first sample in the window
        payload_size = 9 #one byte differential time from timestamp. So delay can go up to 256 
        const = 10

        return math.ceil( (header_size + timestamp_size + window_size*payload_size + const)/42.0 )*42.0

    # returns max possible window size given tx bytes
    def get_window_size_for_tx_bytes(self, tx_bytes):
        window_size = 2
        while (self.get_tx_bytes(window_size) <= tx_bytes):
            window_size += 1

        return window_size-1


    def _flush_delay_window(self):
        self.delay_window = []

        
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)


#####################################################################################################################################
# Error delay sampler
######################################################################################################################################

# ID 1
debug1 = False

class ErrorDelaySampler(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, error_threshold=0.0, delay_threshold=100.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file)
        self.error_threshold = error_threshold
        self.delay_threshold = delay_threshold
    

    def get_mean_of_max_extrapolation_error_for_durationlist(self, timelist):
        error_duration_table = self.offline_table # offline_table is in paretn Sampler
        expected_total_error=0.0

        for t in timelist:
            for i in range(len(error_duration_table)):
                if t < error_duration_table[i][1]:
                    break

            
            error_first = error_duration_table[i-1][0]
            error_second = error_duration_table[i][0]

            time_first = error_duration_table[i-1][1]
            time_second = error_duration_table[i][1]


            error = error_first + (error_second - error_first)*((t-time_first)/(time_second-time_first))

            #print t, i, time_first, time_second, error_first, error_second, error

            expected_total_error += error

        #print expected_total_error/len(timelist), len(timelist)
        #print "\n"
        return expected_total_error/len(timelist)  


    def cleanup_last_window(self):
        if not self.delay_window:
            return

        ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
        ### print "dealy window from cleanup", map(lambda x:x.time, locations_delay_window)

        #extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)
        #indices_for_error_over_threshold = filter(lambda (index, error): error>self.error_threshold, list(enumerate(extrapolation_errors)))
        #if len(indices_for_error_over_threshold) > 0: # transmit if any sample causing error over threshold in the last window

        compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)
        
        if self.server_loc_param is None: # there was no window transmitted up to now
            self.server_loc_param = self.server.update_locations(compressed_window, True)
        else:
            self.server_loc_param = self.server.update_locations(compressed_window, False)
        
        if debug1: 
            print "cleanup", map(lambda loc_param: loc_param[0].time, compressed_window)

        self._flush_delay_window()



    def get_compressed_window_error_bounded(self, loc_param_window, max_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        if debug1: print "locs from window", map(lambda loc: loc.time, locations_from_window)
        compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 
        if debug1: print "from sampler, compressed indices", compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices]

        #print map(lambda loc_param: loc_param[0].time, compressed_window)  
        return compressed_window
    
    def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
        locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
        locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)
        
        #compression_error = self.gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
        compression_error = fast_gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
        
        return compression_error
    
    def transmit_locations(self):
        if not self.delay_window: #empty window, nothing to do
            return False

        if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
            return False

        else: # need to process the delay window
            ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
            ### print "dealy window tx_locations", map(lambda x:x.time, locations_delay_window)


            if (self.server_loc_param is None): # the very first window
                ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
                ### print "dealy window first tx", map(lambda x:x.time, locations_delay_window)

                compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)

                self.server_loc_param = self.server.update_locations(compressed_window, True) 
                #self.server_loc_param = self.delay_window[-1]       
                self._flush_delay_window()

                if debug1: print "first window transmission..."

                return False



            extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)

            indices_for_error_over_threshold = filter(lambda (index, error): error>self.error_threshold, list(enumerate(extrapolation_errors)))
            #print "indices over th", indices_for_error_over_threshold

            first_index_for_error_over_threshold = None
            if len(indices_for_error_over_threshold) > 0: 
                (first_index_for_error_over_threshold, _) = indices_for_error_over_threshold[0]

                if(first_index_for_error_over_threshold == 0): # we need to transmit this window immediately 
                    compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)

                    self.server_loc_param = self.server.update_locations(compressed_window, False) 
                    self._flush_delay_window()

                    if debug1: print "transmitting as fist loc in the window has high error $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

                    return False

                else: # we need to estimate if we should send this window or some future window containing the error that is over threshold
                    #return 
                    subwindow = self.delay_window[0:first_index_for_error_over_threshold]
                    #print map(lambda loc_param: loc_param[0].time - self.server_loc_param[0].time, subwindow)
                    #print self.server_loc_param[0].time

                    subwindow_errors = self.get_extrapolation_errors(self.server_loc_param, subwindow)
                    #print subwindow_errors

                    for i in range(1, len(subwindow)):
                        sub_subwindow = subwindow[0:i]
                            
                        sub_subwindow_error = sum(subwindow_errors[0:i])/len(sub_subwindow)
                        
                        window_time = self.delay_window[-1][0].time - self.delay_window[0][0].time
                        #print window_time
                        sub_subwindow_time_offsets = map(lambda loc_param: (loc_param[0].time - self.server_loc_param[0].time + window_time), sub_subwindow)
                        #print "sub subwindow time offsets", sub_subwindow_time_offsets
                        sub_subwindow_expected_error = self.get_mean_of_max_extrapolation_error_for_durationlist(sub_subwindow_time_offsets)

                        #sub_subwindow_expected_error = self.get_expected_error_for_timelist(sub_subwindow_time_offsets)

                        if(sub_subwindow_error < sub_subwindow_expected_error): 
                            # some sub_subwindow error is below expected error.
                            # so we can drop the first sample at delay window and move on...
                            if debug1: print "dropping first sample in the window"
                            #del self.delay_window[0]
                            return True
                    
                    # we are here means all sub_subwindow errors are over corresponding expected errors
                    # so we should transmit current window
                    if debug1: print "transmitting as all sub_subwindow errors over expected..."
                    compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)
                    if debug1: print map(lambda loc_param: loc_param[0].time, compressed_window)
                    self.server_loc_param = self.server.update_locations(compressed_window, False)
                    self._flush_delay_window()
                    return False


            else: #low error for the whole window; nothing to transmit
                if debug1: print "low error... not transmitting"
                if debug1: print "no tx window", map(lambda loc_param: loc_param[0].time, self.delay_window)
                self._flush_delay_window()
                return False








#####################################################################################################################################
# budget delay sampler
######################################################################################################################################

# #
# # budget delay sampler with separately produced offline table
# # 
# debug11 = False
# debug_plot = False
# debug11_cleanup=False

# PRINT_CURRENT_BALANCE=True

# # ID 11
# class BudgetDelayStatisticalMaxerrorSampler(Sampler):
#     def __init__(self, server, extrapolator, offline_table_file, budget_threshold=8, delay_threshold=30.0, period=57600.0):
#         Sampler.__init__(self, server, extrapolator, offline_table_file)

#         self.delay_threshold = delay_threshold #sec
#         self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]


#         self.current_budget = self.given_budget

#         self.elapsed_time = 0.0
#         self.tx_bytes_total = 0.0

#         self.prev_time = None # helps to calculate self.elapsed_time

#         self.bytes_in_hand = 0.0

#         self.expected_max_error_for_given_budget = self.get_expected_max_error(self.given_budget)

#         self.period = period
        

#     def init_location(self, curr_loc_param):
#         self.delay_window = [curr_loc_param]
#         self.server_loc_param = None
#         self.current_time = curr_loc_param[0].time

#         self.start_time = self.current_time

#         self.current_time = curr_loc_param[0].time
#         self.prev_time = None
       
                
#         # NOTE: uncomment to start budget calculation seperately for new trip and don't count budget in the case of not sending in cleaup_last_window()
#         # self.current_budget = self.given_budget
#         #self.budget_in_hand = 0.0


#     # TODO: produce a separate class, this function is needed in the process_evals_new.py too
#     # returns tx bytes from window size
#     def get_tx_bytes(self, window_size):
#         header_size = 32
#         timestamp_size = 4 #4 byte timestamp of the first sample in the window
#         payload_size = 9 #one byte differential time from timestamp. So delay can go up to 256 
#         const = 10

#         return math.ceil( (header_size + timestamp_size + window_size*payload_size + const)/42.0 )*42.0

#     # returns max possible window size without increasing the budget
#     def get_max_window_size_for_same_budget(self, window_size):
#         max_window_size = window_size
#         tx_bytes_current = self.get_tx_bytes(window_size)
#         while (self.get_tx_bytes(max_window_size) <= tx_bytes_current):
#             max_window_size += 1

#         return max_window_size-1


#     #
#     # returns error for a particular time interval
#     #
#     def get_error_from_time(self, time):
#         if time >= len(self.offline_table):
#             return self.offline_table[-1]
#         else:
#             #print time, self.offline_table[time]
#             return self.offline_table[time]
    

#     def get_expected_max_error(self, budget):

#         time = int(84.0/budget)

#         expected_max_error=0.0
#         exp_error_buckets = ExponentialErrorBuckets()

#         try:
#             expected_max_error = int(round(self.get_error_from_time(time)))
#         except:
#             print "got exception in get_expected_mean_error..."
#             expected_max_error = 0.0

#         #print time,factor,expected_mean_error
#         return expected_max_error


#     #
#     # returns a compressed window that have mean compression error less than or equal to the given mean error
#     #
#     def get_compressed_window_mean_error_bounded(self, loc_param_window, given_compressed_window_mean_error):
#         locations_from_window = map(lambda (loc,param):loc, loc_param_window)
#         #print map(lambda loc: loc.time, locations_from_window)

#         if ( len(loc_param_window) <=4 ):
#             return loc_param_window

#         for compressed_window_size in range(4,len(loc_param_window)):
#             compressed_indices = self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
#             #print compressed_indices
#             compressed_window = [loc_param_window[index] for index in compressed_indices]
#             #print compressed_window
#             mean_compression_error = self.get_compression_error(loc_param_window, compressed_window)/len(loc_param_window)
#             if mean_compression_error <= given_compressed_window_mean_error:
#                 return compressed_window

#         return loc_param_window

#     #
#     # returns error bounded compressed window
#     # 
#     def get_compressed_window_max_error_bounded(self, loc_param_window, max_error):
#         locations_from_window = map(lambda (loc,param):loc, loc_param_window)
#         #print "locs from window max_error bound", map(lambda loc: loc.time, locations_from_window)
#         compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 

#         final_compression_size = len(compressed_indices)
#         if len(compressed_indices) > self.delay_threshold/4:
#             final_compression_size = int(self.delay_threshold/4)


#         window_size_with_same_budget = self.get_max_window_size_for_same_budget(final_compression_size)
#         #print window_size_with_same_budget

#         # now get the size bounded gps compressed window
#         compressed_indices_final = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, window_size_with_same_budget)

#         #print "from sampler, compressed indices", compressed_indices
#         compressed_window = [loc_param_window[index] for index in compressed_indices_final]


#         #print map(lambda loc_param: loc_param[0].time, compressed_window)  
#         return compressed_window


#     #
#     # returns total compression error 
#     #
#     def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
#         locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
#         locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)

#         compression_error = self.gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
#         return compression_error


#     def update(self, curr_loc_param):
#         self.current_time += 1

#         if (self.prev_time is not None):
#             self.elapsed_time += (self.current_time - self.prev_time)
#         self.prev_time = self.current_time

#         #if debug11: print "elpased time from update", self.elapsed_time

#         if curr_loc_param is not None:
#             self.delay_window.append(curr_loc_param)

#         self.transmit_locations()

#         if PRINT_CURRENT_BALANCE: # just to see balance value over time
#             balance = self.elapsed_time*self.given_budget-self.tx_bytes_total 
#             print balance, self.get_current_factor()


#     def get_current_factorized_error_target(self):
#         savings = self.elapsed_time*self.given_budget
#         expense = self.tx_bytes_total 
#         balance = (savings - expense)
            
#         factor = 1.0
            
#         try:
#             x=(balance)/(self.given_budget*self.period)

#             if balance>=0:
#                 factor=1/(1+x)
#                 #factor=1/((1+x)**0.5)
#                 #factor=2**(-x)
#             else:
#                 factor=1-x
#                 #factor=1-(abs(x)**0.5)
#                 #factor=1+(x**2)

#         except:
#             print "exception", self.given_budget

#         #print factor

#         return factor*self.expected_max_error_for_given_budget
            
#     # just to print debug info
#     def get_current_factor(self):
#         savings = self.elapsed_time*self.given_budget
#         expense = self.tx_bytes_total 
#         balance = (savings - expense)
            
#         factor = 1.0
            
#         try:
#             x=(balance)/(self.given_budget*self.period)

#             if balance>=0:
#                 factor=1/(1+x)
#             else:
#                 factor=1-x

#         except:
#             print "exception", self.given_budget

#         return factor


#     def transmit_locations(self):
#         if not self.delay_window: #empty window, nothing to do
#             return

#         if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
#             return

#         else: # need to process the delay window
            
#             if (self.server_loc_param is None): # the very first window
#                 #print "FIRST WINDOW"

#                 self.expected_max_error_for_given_budget
#                 compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, self.expected_max_error_for_given_budget) 

#                 locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
#                 #print "dealy window", map(lambda x:x.time, locations_delay_window)
                
#                 locations_compressed_window = map(lambda (loc,param):loc, compressed_window)
#                 #print "compressed window", map(lambda x:x.time, locations_compressed_window)

#                 self.server_loc_param = self.server.update_locations(compressed_window, True) 
#                 self._flush_delay_window()

#                 self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))

#                 if debug11: print "first window tx..."

#                 return
    
#             if debug11: print "\n"
            

#             extr_error_for_sample_to_be_dropped = self.get_extrapolation_errors(self.server_loc_param, self.delay_window[:1])[0]
#             current_factorized_error_target =  self.get_current_factorized_error_target()


#             if extr_error_for_sample_to_be_dropped > current_factorized_error_target:
#                 #self.server_loc_param = self.server.update_locations(self.delay_window, False) 
#                 compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, current_factorized_error_target) #old was window_size
#                 self.server_loc_param = self.server.update_locations(compressed_window, False) 
                    
#                 self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))
#                 if debug11: print "tx_bytes_total", self.tx_bytes_total


#                 self._flush_delay_window()
#                 return


#             if debug11: print "dropping first sample"
#             del self.delay_window[0]




#####################################################################################################################################

debug12 = False
debug_plot = False
debug12_cleanup=False

PRINT_CURRENT_BALANCE=False

# ID 12
# budget delay sampler that uses only extrapolator error table (from james) rather than 
# separately computed table as of ID 11 (BudgetDelayStatisticalMaxerrorSampler)

class BudgetDelayStatisticalMaxerrorSamplerOfflineExtrTable(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, budget_threshold=8, delay_threshold=30.0, period=57600.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file)

        self.delay_threshold = delay_threshold #sec
        self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]


        self.current_budget = self.given_budget

        self.elapsed_time = 0.0
        self.tx_bytes_total = 0.0

        self.prev_time = None # helps to calculate self.elapsed_time

        self.bytes_in_hand = 0.0

        self.expected_max_error_for_given_budget = self.get_expected_max_error(self.given_budget)
        #print self.expected_max_error_for_given_budget 

        self.period = period
        

    def init_location(self, curr_loc_param):
        self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time

        self.start_time = self.current_time

        self.current_time = curr_loc_param[0].time
        self.prev_time = None
       
                
        # NOTE: uncomment to start budget calculation seperately for new trip and don't count budget in the case of not sending in cleaup_last_window()
        # self.current_budget = self.given_budget
        #self.budget_in_hand = 0.0


    def cleanup_last_window(self):
        #print "Call to cleanup >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

        if not self.delay_window:
            return


        compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, self.get_current_factorized_error_target())
        
        if self.server_loc_param is None: # there was no window transmitted up to now
            self.server_loc_param = self.server.update_locations(compressed_window, True)
        else:
            self.server_loc_param = self.server.update_locations(compressed_window, False)
        

        self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))

        self._flush_delay_window()


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


    def get_expected_max_error(self, budget):
        duration_error_table = self.offline_table # offline_table is in parent Sampler
        expected_max_error=0.0
        
        # since we gain the specified budget amount bytes at the last second,
        # we need to consider that for actual t. Hence -1
        t = int(84.0/budget) - 1

        for i in range(len(duration_error_table)):
            if t < duration_error_table[i][0]:
                break

            
        error_first = duration_error_table[i-1][1]
        error_second = duration_error_table[i][1]

        time_first = duration_error_table[i-1][0]
        time_second = duration_error_table[i][0]


        expected_max_error = error_first + (error_second - error_first)*((t-time_first)/(time_second-time_first))

        #print t, i, time_first, time_second, error_first, error_second, expected_max_error

        return expected_max_error
        

    #
    # returns a compressed window that have mean compression error less than or equal to the given mean error
    #
    def get_compressed_window_mean_error_bounded(self, loc_param_window, given_compressed_window_mean_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print map(lambda loc: loc.time, locations_from_window)

        if ( len(loc_param_window) <=4 ):
            return loc_param_window

        for compressed_window_size in range(4,len(loc_param_window)):
            compressed_indices = self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
            #print compressed_indices
            compressed_window = [loc_param_window[index] for index in compressed_indices]
            #print compressed_window
            mean_compression_error = self.get_compression_error(loc_param_window, compressed_window)/len(loc_param_window)
            if mean_compression_error <= given_compressed_window_mean_error:
                return compressed_window

        return loc_param_window

    #
    # returns error bounded compressed window
    # 
    def get_compressed_window_max_error_bounded(self, loc_param_window, max_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print "locs from window max_error bound", map(lambda loc: loc.time, locations_from_window)
        compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 

        final_compression_size = len(compressed_indices)
        #if len(compressed_indices) > self.delay_threshold/4:
        #    final_compression_size = int(self.delay_threshold/4)


        window_size_with_same_budget = self.get_max_window_size_for_same_budget(final_compression_size)
        #print window_size_with_same_budget

        # now get the size bounded gps compressed window
        compressed_indices_final = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, window_size_with_same_budget)

        #print "from sampler, compressed indices", compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices_final]


        #print map(lambda loc_param: loc_param[0].time, compressed_window)  
        return compressed_window


    #
    # returns total compression error 
    #
    def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
        locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
        locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)

        compression_error = self.gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
        return compression_error


    def update(self, curr_loc_param):
        self.current_time += 1

        if (self.prev_time is not None):
            self.elapsed_time += (self.current_time - self.prev_time)
        self.prev_time = self.current_time

        #if debug12: print "elpased time from update", self.elapsed_time

        if curr_loc_param is not None:
            self.delay_window.append(curr_loc_param)

        self.transmit_locations()

        if PRINT_CURRENT_BALANCE: # just to see balance value over time
            balance = self.elapsed_time*self.given_budget-self.tx_bytes_total 
            print balance, self.get_current_factor()


    def get_current_factorized_error_target(self):
        savings = self.elapsed_time*self.given_budget
        expense = self.tx_bytes_total 
        balance = (savings - expense)
            
        factor = 1.0
            
        try:
            x=(balance)/(self.given_budget*self.period)

            if balance>=0:
                factor=1/(1+x)
                #factor=1/((1+x)**0.5)
                #factor=2**(-x)
            else:
                factor=1-x
                #factor=1-(abs(x)**0.5)
                #factor=1+(x**2)

        except:
            print "exception", self.given_budget

        #print factor

        return factor*self.expected_max_error_for_given_budget
            
    # just to print debug info
    def get_current_factor(self):
        savings = self.elapsed_time*self.given_budget
        expense = self.tx_bytes_total 
        balance = (savings - expense)
            
        factor = 1.0
            
        try:
            x=(balance)/(self.given_budget*self.period)

            if balance>=0:
                factor=1/(1+x)
            else:
                factor=1-x

        except:
            print "exception", self.given_budget

        return factor


    def transmit_locations(self):
        if not self.delay_window: #empty window, nothing to do
            return

        if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
            return

        else: # need to process the delay window
            
            if (self.server_loc_param is None): # the very first window
                #print "FIRST WINDOW"

                self.expected_max_error_for_given_budget
                compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, self.expected_max_error_for_given_budget) 

                ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
                ### print "dealy window", map(lambda x:x.time, locations_delay_window)
                
                locations_compressed_window = map(lambda (loc,param):loc, compressed_window)
                print "compressed window", map(lambda x:x.time, locations_compressed_window)

                self.server_loc_param = self.server.update_locations(compressed_window, True) 
                self._flush_delay_window()

                self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))

                if debug12: print "first window tx..."

                return
    
            if debug12: print "\n"
            

            
            #locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
            #print "dealy window in transmit_locations()", map(lambda x:x.time, locations_delay_window)


            extr_error_for_sample_to_be_dropped = self.get_extrapolation_errors(self.server_loc_param, self.delay_window[:1])[0]
            current_factorized_error_target =  self.get_current_factorized_error_target()
            #print "current factorized error", current_factorized_error_target

            if extr_error_for_sample_to_be_dropped > current_factorized_error_target:

                ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
                ### print "dealy window in transmit_locations()", map(lambda x:x.time, locations_delay_window)

                #self.server_loc_param = self.server.update_locations(self.delay_window, False) 
                compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, current_factorized_error_target) #old was window_size
                self.server_loc_param = self.server.update_locations(compressed_window, False) 
                    
                self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))
                if debug12: print "tx_bytes_total", self.tx_bytes_total


                self._flush_delay_window()
                return


            if debug12: print "dropping first sample"
            del self.delay_window[0]







#####################################################################################################################################

debug13 = False
debug_plot = False
debug13_cleanup=False

PRINT_CURRENT_BALANCE=False

# ID 13
# budget delay sampler that uses only extrapolator error table (from james) rather than 
# separately computed table as of ID 11 (BudgetDelayStatisticalMaxerrorSampler)

class BudgetDelayStatisticalMaxerrorSamplerOfflineExtrComprTable(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, budget_threshold=8, delay_threshold=30.0, period=57600.0):
        Sampler.__init__(self, server, extrapolator, None)

        self.delay_threshold = delay_threshold #sec
        self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]


        self.current_budget = self.given_budget

        self.elapsed_time = 0.0
        self.tx_bytes_total = 0.0

        self.prev_time = None # helps to calculate self.elapsed_time

        self.bytes_in_hand = 0.0

        self.offline_table = self.load_offline_table_txt(offline_table_file)
                    
        self.expected_max_error_for_given_budget = self.get_expected_max_error(self.given_budget, self.delay_threshold)
        ### print "expected max error=",self.expected_max_error_for_given_budget 

        self.period = period
 

    # overridden
    # used for newer extrapolator tables in txt format
    def load_offline_table_txt(self, offline_table_file):
        
        if(offline_table_file == None):
            return None
        else:
            f = open(offline_table_file, "r")
            offline_table = f.readlines()
            
            offline_table_list = []
            
            for line in offline_table:
                data=line.rstrip("\n").split(" ")

                # values are: (error, duration, tx_cost)
                offline_table_list.append((float(data[0]), float(data[1]), float(data[2])))
                
            return offline_table_list


    def init_location(self, curr_loc_param):
        self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time
        ### print "init location", curr_loc_param[0].time

        self.start_time = self.current_time

        self.current_time = curr_loc_param[0].time
        self.prev_time = None
       
        self.transmit_locations()
                
        # NOTE: uncomment to start budget calculation seperately for new trip and don't count budget in the case of not sending in cleaup_last_window()
        # self.current_budget = self.given_budget
        #self.budget_in_hand = 0.0


    def cleanup_last_window(self):
        ### print "Call to cleanup >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

        locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
        ### print "dealy window from cleanup", map(lambda x:x.time, locations_delay_window)

        if not self.delay_window:
            print "returning..."
            return

        compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, self.get_current_factorized_error_target())

        if self.server_loc_param is None: # there was no window transmitted up to now
            self.server_loc_param = self.server.update_locations(compressed_window, True)

        else:
            self.server_loc_param = self.server.update_locations(compressed_window, False)
        
        self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))

        self._flush_delay_window()


    def get_interpolated_value(self, x1, x2, y1, y2, x):
        #print x1, x2, y1, y2, x
        return y1 + (y2 - y1)*((x-x1)/(x2-x1))
    
    
    # helper funciton for get_expected_max_error()
    def get_expected_max_error_by_matching(self, txcost_start, txcost_end, rightside_start, rightside_end, maxerror_start, maxerror_end):
        interpolated_rightside_txcost = []
        
        txcost_now = txcost_start
        while txcost_now >= txcost_end-0.25:
            rightside_interpolated = self.get_interpolated_value(txcost_start, txcost_end, rightside_start, rightside_end, txcost_now)
            interpolated_rightside_txcost.append((rightside_interpolated, txcost_now))

            txcost_now -= 0.25

        #print interpolated_rightside_txcost
        interpolated_rightside_txcost_w_index = enumerate(interpolated_rightside_txcost)
        #print interpolated_rightside_txcost_w_index
        distance_w_index = map(lambda (index,(rightside,txcost)): (index, abs(rightside-txcost)), interpolated_rightside_txcost_w_index)
        sorted_distance_w_index = sorted(distance_w_index, key=lambda x:x[1])        
        #print sorted(map(lambda (rightside,txcost): abs(rightside-txcost), interpolated_rightside_txcost_w_index))
        

        rightside_min_distance = interpolated_rightside_txcost[sorted_distance_w_index[0][0]][0]
        #print rightside_min_distance
        expected_max_error = self.get_interpolated_value(rightside_start, rightside_end, maxerror_start, maxerror_end, rightside_min_distance)
        if expected_max_error == 0.0:
            rightside_second_min_distance = interpolated_rightside_txcost[sorted_distance_w_index[1][0]][0]
            expected_max_error = self.get_interpolated_value(rightside_start, rightside_end, maxerror_start, maxerror_end, rightside_second_min_distance)

        
        ##if expected_max_error < 1.0:
        ##    return 1.0
        

        # print expected_max_error
        return expected_max_error

    # helper funciton for get_expected_max_error()
    def get_expected_max_error_by_exp_eqn(self, maxerror, duration, txcost): # called when the budget is greater than the start of the table
        B_long = txcost/(duration+self.delay_threshold)
        
        # now we need to find the exponential equation of the form budget=a*e^(b*error) between points (maxerror, B_long) and (0, 84)
        a=84 # for (0,84)
        b=math.log(B_long/84)/maxerror
        
        ###print "a,b",a,b

        expected_max_error = math.log(self.given_budget/a)/b
        ### print expected_maxerror
        
        return expected_max_error
            

    def get_expected_max_error(self, budget, delay):
        # matching of equation txcost = B_long*(duration+delay)
        
        for i in range(len(self.offline_table)):
            equation_right_side = budget*(self.offline_table[i][1]+delay)
            txcost = self.offline_table[i][2]
            if equation_right_side >= txcost:
                break

        ### print i

        if i == 0: # need to extrapolate for error at the begenning
            maxerror = self.offline_table[0][0]
            duration = self.offline_table[0][1]
            txcost = self.offline_table[0][2]
            
            return self.get_expected_max_error_by_exp_eqn(maxerror, duration, txcost)

        elif i==len(self.offline_table)-1: # need to extrapolate for error at the end
            #print "table bound overflow!!!"
            #print self.offline_table[len(self.offline_table)-1][0]
            return self.offline_table[len(self.offline_table)-1][0]

        else: # need to find the match with minimal distance and then interpolate for error

            maxerror_start = self.offline_table[i-1][0]
            maxerror_end = self.offline_table[i][0]

            txcost_start = self.offline_table[i-1][2]
            txcost_end = self.offline_table[i][2]

            rightside_start = budget*(self.offline_table[i-1][1]+delay)
            rightside_end = budget*(self.offline_table[i][1]+delay)


            if txcost_start == txcost_end: # no need to find bestm match, just interpolate
                return self.get_interpolated_value(rightside_start, rightside_end, maxerror_start, maxerror_end, txcost_start)



            return self.get_expected_max_error_by_matching(txcost_start, txcost_end, rightside_start, rightside_end, maxerror_start, maxerror_end)




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
    # returns a compressed window that have mean compression error less than or equal to the given mean error
    #
    def get_compressed_window_mean_error_bounded(self, loc_param_window, given_compressed_window_mean_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print map(lambda loc: loc.time, locations_from_window)

        if ( len(loc_param_window) <=4 ):
            return loc_param_window

        for compressed_window_size in range(4,len(loc_param_window)):
            compressed_indices = self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
            #print compressed_indices
            compressed_window = [loc_param_window[index] for index in compressed_indices]
            #print compressed_window
            mean_compression_error = self.get_compression_error(loc_param_window, compressed_window)/len(loc_param_window)
            if mean_compression_error <= given_compressed_window_mean_error:
                return compressed_window

        return loc_param_window

    #
    # returns error bounded compressed window
    # 
    def get_compressed_window_max_error_bounded(self, loc_param_window, max_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print "locs from window max_error bound", map(lambda loc: loc.time, locations_from_window)
        compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 

        final_compression_size = len(compressed_indices)
        #if len(compressed_indices) > self.delay_threshold/4:
        #    final_compression_size = int(self.delay_threshold/4)


        window_size_with_same_budget = self.get_max_window_size_for_same_budget(final_compression_size)
        #print window_size_with_same_budget

        # now get the size bounded gps compressed window
        compressed_indices_final = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, window_size_with_same_budget)

        #print "from sampler, compressed indices", compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices_final]


        #print map(lambda loc_param: loc_param[0].time, compressed_window)  
        return compressed_window


    #
    # returns total compression error 
    #
    def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
        locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
        locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)

        compression_error = self.gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
        return compression_error


 
        
    def get_current_factorized_error_target(self):
        savings = self.elapsed_time*self.given_budget
        expense = self.tx_bytes_total 
        balance = (savings - expense)
            
        factor = 1.0
            
        try:
            x=(balance)/(self.given_budget*self.period)

            if balance>=0:
                factor=1/(1+x)
                #factor=1/((1+x)**0.5)
                #factor=2**(-x)
            else:
                factor=1-x
                #factor=1-(abs(x)**0.5)
                #factor=1+(x**2)

        except:
            print "exception", self.given_budget

        #print factor

        return factor*self.expected_max_error_for_given_budget
            
    # just to print debug info
    def get_current_factor(self):
        savings = self.elapsed_time*self.given_budget
        expense = self.tx_bytes_total 
        balance = (savings - expense)
            
        factor = 1.0
            
        try:
            x=(balance)/(self.given_budget*self.period)

            if balance>=0:
                factor=1/(1+x)
            else:
                factor=1-x

        except:
            print "exception", self.given_budget

        return factor


    def update(self, curr_loc_param):
        if self.transmit_locations():
            #print "dropping first sample in update"
            del self.delay_window[0]

        self.current_time += 1

        if (self.prev_time is not None):
            self.elapsed_time += (self.current_time - self.prev_time)
        self.prev_time = self.current_time

        #if debug13: print "elpased time from update", self.elapsed_time
        ### print "elpased time from update", self.elapsed_time

        #print "in update", curr_loc_param[0].time

        if curr_loc_param is not None:
            self.delay_window.append(curr_loc_param)

        if PRINT_CURRENT_BALANCE: # just to see balance value over time
            balance = self.elapsed_time*self.given_budget-self.tx_bytes_total 
            ### print balance, self.get_current_factor()



    def transmit_locations(self):
        s = self.elapsed_time*self.given_budget
        e = self.tx_bytes_total 
        b = (s - e)
        
        ##### print self.current_time, s, e, b, self.get_current_factorized_error_target()


        if not self.delay_window: #empty window, nothing to do
            return False

        if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
            ### print "filling delay window"
            return False

        else: # need to process the delay window
            ### print "processing delay window"

            if (self.server_loc_param is None): # the very first window
                ###print "FIRST WINDOW"

                #print self.expected_max_error_for_given_budget, self.get_current_factorized_error_target()
                #compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, self.get_current_factorized_error_target()) 
                compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, self.expected_max_error_for_given_budget) 

                locations_uncompressed_window = map(lambda (loc,param):loc, self.delay_window)
                locations_compressed_window = map(lambda (loc,param):loc, compressed_window)
                  
                compression_error = self.gps_compressor.get_compression_error_list(locations_uncompressed_window, locations_compressed_window)

                #if debug13: print "compression error=", compression_error

                locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
                ### print "dealy window first tx", map(lambda x:x.time, locations_delay_window)
                
                #locations_compressed_window = map(lambda (loc,param):loc, compressed_window)
                #print "compressed window first tx", map(lambda x:x.time, locations_compressed_window)

                self.server_loc_param = self.server.update_locations(compressed_window, True) 
                self._flush_delay_window()

                self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))

                if debug13: print "first window tx..."

                return False
    
            if debug13: print "\n"
            
            ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
            ### print "dealy window in transmit_locations()", map(lambda x:x.time, locations_delay_window)

            extr_error_for_sample_to_be_dropped = self.get_extrapolation_errors(self.server_loc_param, self.delay_window[:1])[0]
            current_factorized_error_target =  self.get_current_factorized_error_target()
            if debug13: print "current factorized error", current_factorized_error_target
            ### print self.delay_window[0][0].time, current_factorized_error_target, extr_error_for_sample_to_be_dropped

            if extr_error_for_sample_to_be_dropped > current_factorized_error_target:
                #self.server_loc_param = self.server.update_locations(self.delay_window, False) 
                compressed_window = self.get_compressed_window_max_error_bounded(self.delay_window, current_factorized_error_target) #old was window_size
                self.server_loc_param = self.server.update_locations(compressed_window, False) 
                    
                self.tx_bytes_total += self.get_tx_bytes(len(compressed_window))
                if debug13: print "tx_bytes_total", self.tx_bytes_total

                ### print self.get_tx_bytes(len(compressed_window))

                
                ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
                ###print "dealy window", map(lambda x:x.time, locations_delay_window)
                
                ### locations_compressed_window = map(lambda (loc,param):loc, compressed_window)
                ### print "compressed window", map(lambda x:x.time, locations_compressed_window)

                self._flush_delay_window()
                return False

            
            ### if debug13: print "dropping first sample"
            #del self.delay_window[0]
            return True












#####################################################################################################################################
# error budget sampler
######################################################################################################################################

# ID 21
debug21 = False
class ErrorBudgetSampler3(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, offline_error_delay_table_file_for_error_budget_sampler, delays_file, error_threshold=0.0, budget_threshold=9999.0, period=1.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file)
        self.error_threshold = error_threshold
        self.given_budget = float(budget_threshold) #bytes/sec

        # time period over which we want spend the savings or recover the deficit 
        #self.alpha = 1.0/300.0 #1/seconds (spend savings or cover deficit it over 300 seconds)
        #self.alpha = 1.2
        self.alpha = 5.0

        self.current_budget = self.given_budget

        self.server_loc_param = None

        self.server = server
        self.extrapolator = extrapolator
        self.offline_table_file = offline_table_file
        self.offline_error_delay_table_data = self.get_error_delay_table_data(offline_error_delay_table_file_for_error_budget_sampler)
        #print self.offline_error_delay_table_data

        #TODO: don't print delays from here. tx it to the server during loc_param update and log from there
        self.delays_file = delays_file

        self.bytes_in_hand = 0.0

        self.current_delay = None
        self.error_delay_sampler = None
        self.new_error_delay_sampler_init_location_done = False

        self.elapsed_time = 0.0
        self.tx_bytes_total = 0.0

        self.prev_time = None # helps to calculate self.elapsed_time

        #self.period = 3600.0
        self.period = period


    # override 
    def init_location(self, curr_loc_param):
        if debug21: print "init location..."
        ### print "init error budget $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

        #self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time
        self.prev_time = None
        

        #self.current_delay = 0.0 # old 
        self.current_delay = self.get_updated_delay()
        self.error_delay_sampler = ErrorDelaySamplerMeta(self, self.server, self.extrapolator, self.offline_table_file, self.offline_table, self.error_threshold, self.current_delay)
        self.delays_file.write(str(self.current_delay)+"\n")

        self.error_delay_sampler.init_location(curr_loc_param)
        self.new_error_delay_sampler_init_location_done = True
        
        # always transmit the first location here as initital delay is zero anyway
        #self.server_loc_param = self.server.update_locations([curr_loc_param], True)  


    def get_error_delay_table_data(self,error_delay_table_file):
        table_data_list = []
        table_data = open(error_delay_table_file, 'r')
        for data in table_data:
            data_components = data.strip("\n").split(" ")
            table_data_list.append((float(data_components[1]), float(data_components[3])))

        #print table_data_list
        return table_data_list

    def cleanup_last_window(self):
        #TODO: decide when to send
        ### print "cleanup last window......................."
        ### print self.delay_window

        tx_window = self.error_delay_sampler.cleanup_last_window()
        ### print map(lambda loc_param: loc_param[0].time, tx_window)  

        if tx_window is not None: # error_delay_sampler has transmitted a window
            if self.server_loc_param is None: #this is the first window being sent to the server
                self.server_loc_param = self.server.update_locations(tx_window, True)     
            else:
                self.server_loc_param = self.server.update_locations(tx_window, False)       

            self.tx_bytes_total += self.get_tx_bytes(len(tx_window))
                
            self.update_current_budget()


    def update_current_budget(self):
        #self.current_budget = self.given_budget + self.alpha*(self.given_budget*self.elapsed_time - self.tx_bytes_total)
        if (self.elapsed_time == 0):
            self.current_budget = self.current_budget
        else:
            savings = self.elapsed_time*self.given_budget
            expense = self.tx_bytes_total 
            balance = (savings - expense)
            
            factor = 1.0
            
            try:
                x=(balance)/(self.given_budget*self.period)

                if balance>=0:
                    factor=1/(1+x)
                    #factor=1/((1+x)**0.5)
                    #factor=2**(-x)
                else:
                    factor=1-x
                    #factor=1-(abs(x)**0.5)
                    #factor=1+(x**2)

            except:
                print "exception", self.given_budget

            #print factor

            if debug21: print "balance factor 1/factor", balance, factor, 1.0/factor
            #self.current_budget = self.given_budget * (((self.given_budget*self.elapsed_time)/self.tx_bytes_total))**self.alpha
            self.current_budget = self.given_budget * (1.0/factor)
            

        #print "current budget", self.current_budget
        if debug21: print "elapsed time", self.elapsed_time
        if debug21: print "update of current budget", self.current_budget


    def get_updated_delay(self):
        table = self.offline_error_delay_table_data
        delay = None

        #print table

        for i in range(0, len(table)):
            if self.current_budget > table[i][1]:
                break
        
        if i == 0:
            delay = 0.0

        elif i == len(table)-1:
            # Note: this method can resutls in very large delay, so not used currently
            # need to extrapolate
            #m=(table[len(table)-1][0]-table[len(table)-2][0])/(table[len(table)-1][1]-table[len(table)-2][1]) # slope from last pair of points in the table
            #c = table[len(table)-1][0]-m*table[len(table)-1][1] # c = y - mx
            #print "delay", m*self.given_budget + c # y = mx+c
            #return m*self.given_budget + c # y = mx+c
            delay = table[len(table)-1][0]

        else:
            # interpolation
            x0 = table[i-1][1]
            x1 = table[i][1]
            y0 = table[i-1][0]
            y1 = table[i][0]
            x = self.current_budget
            
            #delay = table[i-1][0] + (table[i][0]-table[i-1][0])*((self.given_budget-table[i-1][1])/(table[i][1]-table[i-1][1]))
            delay = y0 + ((y1-y0)/(x1-x0))*(x-x0)

            
        ### print self.current_budget, int(delay)
        return int(delay)

        
            

    # overriding update from Sampler as we don't need to call transmit location.
    # also we don't have samples all the time to add to the delay window
    def update(self, curr_loc_param):

        self.current_time += 1

        if (self.prev_time is not None):
            self.elapsed_time += (self.current_time - self.prev_time)
        self.prev_time = self.current_time


        if debug21: print "elapsed_time tx_bytes_total", self.elapsed_time, self.tx_bytes_total

        if self.new_error_delay_sampler_init_location_done == False:
            if curr_loc_param is not None:
                ### print "0 init of error delay sampler"
                self.error_delay_sampler.init_location(curr_loc_param)
                self.new_error_delay_sampler_init_location_done = True
                return
        
        else:
            tx_window = self.error_delay_sampler.update(curr_loc_param)

            if tx_window is not None: # error_delay_sampler has transmitted a window
                ### print "1 TX of a window by error delay", len(tx_window)
                if self.server_loc_param is None: #this is the first window being sent to the server
                    self.server_loc_param = self.server.update_locations(tx_window, True)       
                else:
                    self.server_loc_param = self.server.update_locations(tx_window, False)       

                self.tx_bytes_total += self.get_tx_bytes(len(tx_window))
                
                self.update_current_budget()
                
                # now update the current delay
                self.current_delay = self.get_updated_delay()

                ### print self.current_delay, len(tx_window)
                
                self.error_delay_sampler = ErrorDelaySamplerMeta(self, self.server, self.extrapolator, self.offline_table_file, self.offline_table, self.error_threshold, self.current_delay)
            
                if debug21: print "created new error_delay samper"

                self.new_error_delay_sampler_init_location_done = False

                # update the server_loc_param after getting the budget as budget computation uses old window
                #print tx_window
                
            
        #print self.current_budget
        #print self.current_delay
        self.delays_file.write(str(self.current_delay)+"\n")








#
# stripped down version of ErrorDelaySampler. used by error-budget sampler
#
debugMeta = False
class ErrorDelaySamplerMeta(Sampler):
    def __init__(self, parent, server, extrapolator, offline_table_file, offline_table, error_threshold=0.0, delay_threshold=100.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file, offline_table)
        self.error_threshold = error_threshold
        self.delay_threshold = delay_threshold
        self.parent = parent
        
    # override 
    def init_location(self, curr_loc_param):
        self.delay_window = [curr_loc_param]
        #self.server_loc_param = None
        #self.server_loc_param = curr_loc_param
        self.current_time = curr_loc_param[0].time


    def get_mean_of_max_extrapolation_error_for_durationlist(self, timelist):
        error_duration_table = self.offline_table # table in parent Sampler class
        expected_total_error=0.0

        for t in timelist:
            for i in range(len(error_duration_table)):
                if t < error_duration_table[i][1]:
                    break

            
            error_first = error_duration_table[i-1][0]
            error_second = error_duration_table[i][0]

            time_first = error_duration_table[i-1][1]
            time_second = error_duration_table[i][1]


            error = error_first + (error_second - error_first)*((t-time_first)/(time_second-time_first))

            #print t, i, time_first, time_second, error_first, error_second, error

            expected_total_error += error

        #print expected_total_error/len(timelist), len(timelist)
        #print "\n"
        return expected_total_error/len(timelist)  


    def cleanup_last_window(self):
        ### print "meta cleanup last window......................."
        
        if(self.delay_window):
            compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)

            self._flush_delay_window()
            return compressed_window


    # overridden to return some value
    def update(self, curr_loc_param):
        self.current_time += 1
        
        deleteFlag, tx_window = self.transmit_locations()
        if deleteFlag:
            del self.delay_window[0]

        if curr_loc_param is not None:
            self.delay_window.append(curr_loc_param)

        return tx_window
        


    def get_compressed_window_error_bounded(self, loc_param_window, max_error):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        if debug1: print "locs from window", map(lambda loc: loc.time, locations_from_window)
        compressed_indices=self.gps_compressor.TDTR_error_bounded(locations_from_window, max_error) 
        if debug1: print "from sampler, compressed indices", compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices]

        compressed_locations = map(lambda (loc,param):loc, compressed_window)
        errors=self.gps_compressor.get_compression_error_list(locations_from_window, compressed_locations);
        ### for error in errors:
        ###    print "e", error

        #print map(lambda loc_param: loc_param[0].time, compressed_window)  
        return compressed_window


    def get_compression_error(self, uncompressed_loc_param_window, compressed_loc_param_window):
        locations_uncompressed_window = map(lambda (loc,param):loc, uncompressed_loc_param_window)
        locations_compressed_window = map(lambda (loc,param):loc, compressed_loc_param_window)

        compression_error = fast_gps_compressor.get_compression_error(locations_uncompressed_window, locations_compressed_window)
        return compression_error


    def transmit_locations(self):
        ### locations_delay_window = map(lambda (loc,param):loc, self.delay_window)
        ### print "dealy window", map(lambda x:x.time, locations_delay_window)
        
        if not self.delay_window: #empty window, nothing to do
            ### print "meta empty window"
            return False, None

        if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
            ### print "meta filling delay window"
            return False, None

        else: # need to process the delay window

            if (self.parent.server_loc_param is None): # the very first window
                compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)

                #self.server_loc_param = self.server.update_locations(compressed_window, True) 
                #self.server_loc_param = self.delay_window[-1]       
                self._flush_delay_window()

                if debugMeta: print "Meta", "first window transmission..."
                ### print "first window tx from meta"

                return False, compressed_window


            extrapolation_errors = self.get_extrapolation_errors(self.parent.server_loc_param, self.delay_window)
            #print extrapolation_errors

            indices_for_error_over_threshold = filter(lambda (index, error): error>self.error_threshold, list(enumerate(extrapolation_errors)))
            #print "indices over th", indices_for_error_over_threshold

            first_index_for_error_over_threshold = None
            if len(indices_for_error_over_threshold) > 0: 
                (first_index_for_error_over_threshold, _) = indices_for_error_over_threshold[0]
                ### print first_index_for_error_over_threshold, extrapolation_errors[first_index_for_error_over_threshold]

                if(first_index_for_error_over_threshold == 0): # we need to transmit this window immediately 
                    compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)

                    #self.server_loc_param = self.server.update_locations(compressed_window, False) 
                    self._flush_delay_window()

                    if debugMeta: print "Meta", "transmitting as fist loc in the window has high error $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

                    return False, compressed_window

                else: # we need to estimate if we should send this window or some future window containing the error that is over threshold
                    #return 
                    subwindow = self.delay_window[0:first_index_for_error_over_threshold]
                    #print map(lambda loc_param: loc_param[0].time - self.server_loc_param[0].time, subwindow)
                    #print self.server_loc_param[0].time

                    subwindow_errors = self.get_extrapolation_errors(self.parent.server_loc_param, subwindow)

                    for i in range(1, len(subwindow)):
                        sub_subwindow = subwindow[0:i]
                        
                        sub_subwindow_error = sum(subwindow_errors[0:i])/len(sub_subwindow)
                        
                        window_time = self.delay_window[-1][0].time - self.delay_window[0][0].time
                        # print window_time
                        sub_subwindow_time_offsets = map(lambda loc_param: (loc_param[0].time - self.parent.server_loc_param[0].time + window_time), sub_subwindow)
                        #print sub_subwindow_time_offsets
                        sub_subwindow_expected_error = self.get_mean_of_max_extrapolation_error_for_durationlist(sub_subwindow_time_offsets)

                        #sub_subwindow_expected_error = self.get_expected_error_for_timelist(sub_subwindow_time_offsets)

                        if(sub_subwindow_error < sub_subwindow_expected_error): 
                            # some sub_subwindow error is below expected error.
                            # so we can drop the first sample at delay window and move on...
                            if debugMeta: print "Meta", "dropping first sample in the window"
                            ### del self.delay_window[0]
                            return True, None
                    
                    # we are here means all sub_subwindow errors are over corresponding expected errors
                    # so we should transmit current window
                    if debug1: print "transmitting as all sub_subwindow errors over expected..."
                    compressed_window = self.get_compressed_window_error_bounded(self.delay_window, self.error_threshold)
                    if debugMeta: print "Meta", map(lambda loc_param: loc_param[0].time, compressed_window)
                    #self.server_loc_param = self.server.update_locations(compressed_window, False)
                    self._flush_delay_window()
                    return False, compressed_window


            else: #low error for the whole window; nothing to transmit
                if debugMeta: print "Meta", "low error... not transmitting"
                #if debugMeta: print "Meta", "no tx window", map(lambda loc_param: loc_param[0].time, self.delay_window)
                self._flush_delay_window()
                return False, None













#####################################################################################################################################
#####################################################################################################################################
#####################################################################################################################################



##############################################################################
# all straw-man samplers starting from here
##############################################################################


class ChangeBasedSampler(Sampler):
    def __init__(self, server, extrapolator, change_threshold):
        Sampler.__init__(self, server, extrapolator, None)
        self.change_threshold = float(change_threshold)


# ID 3
# strawman sampler for comarping with the error-delay sampler.
class LocationChangeBasedSampler(ChangeBasedSampler):
    # default: 15 meters
    def __init__(self, server, extrapolator, change_threshold=15.0):
        ChangeBasedSampler.__init__(self, server, extrapolator, change_threshold)
        self.server_loc_param = None
    
    def init_location(self, curr_loc_param):
        self.server_loc_param = self.server.update_locations( [curr_loc_param] , True)


    def update(self, curr_loc_param):
        if curr_loc_param is not None:
            self.transmit_locations(curr_loc_param)    
    
    def transmit_locations(self, curr_loc_param):
        (curr_loc, _) = curr_loc_param
        (last_loc, _) = self.server_loc_param
        
        if (self._distance(curr_loc, last_loc) >= self.change_threshold):
            self.server_loc_param = self.server.update_locations( [curr_loc_param] , False)


# ID 5
#strawman sampler (full window tx) for comarping with the error-delay sampler.
class LocationChangeBasedFullWindowSampler(ChangeBasedSampler):
    # default: 15 meters
    def __init__(self, server, extrapolator, change_threshold=15.0):
        ChangeBasedSampler.__init__(self, server, extrapolator, change_threshold)
        self.samples_window = []

    def init_location(self, curr_loc_param):
        self.server_loc_param = self.server.update_locations( [curr_loc_param], True )

    def cleanup_last_window(self):
        if not self.samples_window:
            return

        self.server_loc_param = self.server.update_locations( self.samples_window, False )
        self.samples_window = []

    
    def update(self, curr_loc_param):
        if curr_loc_param is not None:
            self.transmit_locations(curr_loc_param)    
    
    def transmit_locations(self, curr_loc_param):
        self.samples_window.append(curr_loc_param)
        
        (curr_loc, _) = curr_loc_param
        (last_loc, _) = self.server_loc_param
        
        if (self._distance(curr_loc, last_loc) >= self.change_threshold):
            #print len(self.samples_window)
            self.server_loc_param = self.server.update_locations( self.samples_window, False )
            self.samples_window = []





# ID 4
debug4=False
class StrawmanSingleSampleBudgetDelaySampler(Sampler):
    def __init__(self, server, extrapolator, budget_threshold=8):
        Sampler.__init__(self, server, extrapolator, None)
        self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]
        self.bytes_in_hand = 0.0
        self.elapsed_time = 0.0


    def init_location(self, curr_loc_param):
        if debug4: print "init locaiton"

        self.current_time = curr_loc_param[0].time
        self.prev_time = None


        self.server_loc_param = self.server.update_locations( [curr_loc_param] , True)
        self.current_time = curr_loc_param[0].time
        self.bytes_in_hand -= 84


    def update(self, curr_loc_param):
        if (self.prev_time is not None):
            self.elapsed_time += (self.current_time - self.prev_time)

        self.current_time += 1

        if curr_loc_param is not None:
            self.transmit_locations(curr_loc_param)

        self.prev_time = self.current_time

    def transmit_locations(self, curr_loc_param):
        if self.prev_time is None:
            self.bytes_in_hand += self.given_budget
        else:
            self.bytes_in_hand += self.given_budget*(self.current_time - self.prev_time)

        if debug4: print "bytes in hand", self.bytes_in_hand

        if self.bytes_in_hand >= 84:            
            self.server_loc_param = self.server.update_locations([curr_loc_param], False) 
            self.bytes_in_hand -= 84

            if debug4: print "tx...", self.bytes_in_hand




# ID 6
debug6 = False
class StrawmanWindowBudgetDelaySampler(Sampler):
    def __init__(self, server, extrapolator, budget_threshold=8):
        Sampler.__init__(self, server, extrapolator, None)
        
        self.samples_window = []

        self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]
        self.bytes_in_hand = 0.0


    def init_location(self, curr_loc_param):
        self.server_loc_param = self.server.update_locations( [curr_loc_param] , True)
        self.current_time = curr_loc_param[0].time


    def get_compressed_window(self, loc_param_window, compressed_window_size):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        compressed_indices = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
        compressed_window = [loc_param_window[index] for index in compressed_indices]
        return compressed_window


    def update(self, curr_loc_param):
        if curr_loc_param is not None:
            self.transmit_locations(curr_loc_param)


    def transmit_locations(self, curr_loc_param):
        self.samples_window.append(curr_loc_param)

        timegap_from_last_tx = self.samples_window[-1][0].time - self.server_loc_param[0].time
        if debug6: print "timegap from last tx", timegap_from_last_tx
        self.bytes_in_hand = timegap_from_last_tx * self.given_budget
        if debug6: print "bytes in hand", self.bytes_in_hand, "timegap_from_last_tx", timegap_from_last_tx
                
            
        if (self.bytes_in_hand >= 84): # we can transmit a compressed window with at least 4 samples
            compressed_window = self.get_compressed_window(self.samples_window, 4)
            self.server_loc_param = self.server.update_locations(compressed_window, False) 
            self.bytes_in_hand -= 84
            self.samples_window = []
            if debug6: print "tx...", self.bytes_in_hand




debug8=False
debug8_cleanup=False
# ID 2
class BudgetDelaySamplerStrawman(Sampler):
    def __init__(self, server, extrapolator, budget_threshold=8, delay_threshold=30.0):
        Sampler.__init__(self, server, extrapolator, None)

        self.delay_threshold = delay_threshold #sec
        self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]

        self.bytes_in_hand = 0.0


    def init_location(self, curr_loc_param):
        self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time

        self.start_time = self.current_time

                
        # NOTE: uncomment to start budget calculation seperately for new trip and don't count budget in the case of not sending in cleaup_last_window()
        # self.current_budget = self.given_budget
        #self.budget_in_hand = 0.0


    def cleanup_last_window(self):
        if not self.delay_window:
            return


        timegap_from_last_tx = self.delay_window[-1][0].time - self.server_loc_param[0].time
        bytes_in_hand = timegap_from_last_tx * self.given_budget

        if bytes_in_hand > 84:
            window_size = self.get_window_size_for_tx_bytes(self.bytes_in_hand)
            compressed_window = self.get_compressed_window(self.delay_window, window_size)
            self.server_loc_param = self.server.update_locations(compressed_window, False)

            self._flush_delay_window()


    def get_compressed_window(self, loc_param_window, compressed_window_size):
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)
        #print map(lambda loc: loc.time, locations_from_window)
        
        #compressed_indices=self.gps_compressor.TDTR_window_sized(locations_from_window, compressed_window_size)
        #start_time = time.time()
        compressed_indices=self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size)
        #print compressed_indices
        #print compressed_window_size, str(time.time() - start_time)
        #compressed_indices = fast_gps_compressor.TDTR_window_sized(locations_from_window, compressed_window_size)  #James' version
        

        #compressed_indices = fast_gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size)  #James' version
        
        #print compressed_indices
        compressed_window = [loc_param_window[index] for index in compressed_indices]
        return compressed_window


    def transmit_locations(self):
        if not self.delay_window: #empty window, nothing to do
            return

        if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
            return

        else: # need to process the delay window            
            if (self.server_loc_param is None): # the very first window
                compressed_window = self.get_compressed_window(self.delay_window, 4)
                #print map(lambda loc_param: loc_param[0].time, compressed_window)

                self.server_loc_param = self.server.update_locations(compressed_window, True) 
                self._flush_delay_window()

                if debug8: print "first window tx..."

                return
    
            if debug8: print "\n"
            
            timegap_from_last_tx = self.delay_window[-1][0].time - self.server_loc_param[0].time
            bytes_in_hand_from_last_tx = timegap_from_last_tx * self.given_budget
            if debug8: print "bytes in hand", self.bytes_in_hand, "timegap_from_last_tx", timegap_from_last_tx
                
            available_bytes = self.bytes_in_hand+bytes_in_hand_from_last_tx
            if debug8: print "available bytes-->", available_bytes
            
            if ( available_bytes >= 84): # we can transmit a compressed window with at least 4 samples
                window_size = self.get_window_size_for_tx_bytes(available_bytes)
                if debug8: print "after >=84", "window_size:", window_size, "delay_window_size", len(self.delay_window)
                

                compressed_window = self.get_compressed_window(self.delay_window, window_size) #old was window_size
  

                self.server_loc_param = self.server.update_locations(compressed_window, False) 
                self._flush_delay_window()
                self.bytes_in_hand = available_bytes - self.get_tx_bytes(window_size)  #old was window_size
                if debug8: print "after >=84", "compressed window tx....", "bytes_used", self.get_tx_bytes(window_size),  "bytes_in_hand:", self.bytes_in_hand
                    
                return

            if debug8: print "dropping first sample"
            del self.delay_window[0]



# # ID 8
# debug8 = False
# class StrawmanWindowBudgetDelaySamplerWithDelay(Sampler):
#     def __init__(self, server, extrapolator, budget_threshold=8.0, delay_threshold = 0.0):
#         Sampler.__init__(self, server, extrapolator, None)
        
#         self.samples_window = []

#         self.given_budget = float(budget_threshold) #bytes/sec [LONG TERM]
#         self.bytes_in_hand = 0.0


#     def init_location(self, curr_loc_param):
#         self.server_loc_param = self.server.update_locations( [curr_loc_param] , True)
#         self.current_time = curr_loc_param[0].time


#     def get_compressed_window(self, loc_param_window, compressed_window_size):
#         locations_from_window = map(lambda (loc,param):loc, loc_param_window)
#         compressed_indices=self.gps_compressor.TDTR_window_sized(locations_from_window, compressed_window_size) 
#         compressed_window = [loc_param_window[index] for index in compressed_indices]
#         return compressed_window


#     def update(self, curr_loc_param):
#         if curr_loc_param is not None:
#             self.transmit_locations(curr_loc_param)


#     def transmit_locations(self, curr_loc_param):
#         self.samples_window.append(curr_loc_param)

#         timegap_from_last_tx = self.samples_window[-1][0].time - self.server_loc_param[0].time
#         if debug8: print "timegap from last tx", timegap_from_last_tx
#         self.bytes_in_hand = timegap_from_last_tx * self.given_budget
#         if debug8: print "bytes in hand", self.bytes_in_hand, "timegap_from_last_tx", timegap_from_last_tx
                
            
#         if (self.bytes_in_hand >= 84): # we can transmit a compressed window with at least 4 samples
#             compressed_window = self.get_compressed_window(self.samples_window, 4)
#             self.server_loc_param = self.server.update_locations(compressed_window, False) 
#             self.bytes_in_hand -= 84
#             self.samples_window = []
#             if debug6: print "tx...", self.bytes_in_hand




# # ID 8 [ DONT EDIT ]
# # strawman for budget delay
# debug8 = True
# class TimeChangeBasedWindowSampler(ChangeBasedSampler):
#     # default: 0 seconds
#     def __init__(self, location_transmitter, extrapolator, change_threshold=0.0):
#         ChangeBasedSampler.__init__(self, location_transmitter, extrapolator, change_threshold)
        
#         self.change_threshold = change_threshold
#         print self.change_threshold

#         self.samples_window = []

#         self.elapsed_time = 0.0
#         self.prev_time = None # helps to calculate self.elapsed_time

#     def init_location(self, curr_loc_param):
#         # if self.server_loc_param is not None:
#         #     self.time_in_hand = (self.last_loc_param[0].time - self.server_loc_param[0].time)
#         #     #print self.time_in_hand

#         # self.server_loc_param = self.server.update_locations( [curr_loc_param] )

#         # self.last_loc_param = curr_loc_param

#         #self.samples_window = [curr_loc_param]
#         #self.server_loc_param = None
#         #self.current_time = curr_loc_param[0].time
        
#         self.server_loc_param = self.server.update_locations( [curr_loc_param] , True)
#         self.current_time = curr_loc_param[0].time



#     def get_compressed_window(self, loc_param_window, compressed_window_size):
#         locations_from_window = map(lambda (loc,param):loc, loc_param_window)
#         compressed_indices=self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
#         compressed_window = [loc_param_window[index] for index in compressed_indices]
#         return compressed_window


#     def update(self, curr_loc_param):
#         self.current_time += 1

#         if (self.prev_time is not None):
#             self.elapsed_time += (self.current_time - self.prev_time)
#         self.prev_time = self.current_time

#         if debug8: print "elpased time from update", self.elapsed_time

#         if curr_loc_param is not None:
#             self.samples_window.append(curr_loc_param)

#         self.transmit_locations()


#     def get_compressed_window(self, loc_param_window, compressed_window_size):
#         locations_from_window = map(lambda (loc,param):loc, loc_param_window)
#         compressed_indices=self.gps_compressor.TDTR_window_sized_fast(locations_from_window, compressed_window_size) 
#         if debug8: print compressed_indices
#         compressed_window = [loc_param_window[index] for index in compressed_indices]
#         return compressed_window

#     def transmit_locations(self):
#         if not self.samples_window: #empty window, nothing to do
#             return

#         if (self.current_time - self.samples_window[0][0].time < self.change_threshold): #fill the delay window if within threshold
#             return

#         else: # need to send the compressed version of the delay window
#             compressed_window = self.get_compressed_window(self.samples_window, 4)
#             self.server_loc_param = self.server.update_locations(compressed_window, False) 
            
#             self.samples_window = []

#             if debug8: print "tx..."
            

