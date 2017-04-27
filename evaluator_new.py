from location import MapMatchedLocationWithEstimatedValues
from gps_compressor import GPSCompressor
from pylibs import spatialfunclib

debug = False

evaluated_locations_file = None
transmitted_locations_file = None


class Evaluator:
    def __init__(self):
        self.time_error_table_file_counter = 0


    def evaluate(self, trace, sampler, extrapolator, server, unique_id, offline_table_file):
        ###print sampler.__class__.__name__
        

        global evaluated_locations_file

        need_init = True
        last_location_time = None
        

        for raw_location in trace:
            if (raw_location == "\n"):
                need_init = True
                sampler.cleanup_last_window()
                output_evaluated_new_line = True
                
                #evaluated_locations_file.write("\n")

            else:
                curr_location = MapMatchedLocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                ###print curr_location.time
                
                if (need_init is True):
                    server.update_raw_locations(curr_location)
                    sampler.init_location(extrapolator.init_location_params(curr_location))
                    last_location_time = curr_location.time
                    need_init = False
                    
                else:

                    for i in range(0, (int(curr_location.time) - int(last_location_time) - 1)):
                        sampler.update(None)


                    # strawman samplers don't maintain a window. so we need to update the server before the sampler
                    if sampler.__class__.__name__ == "LocationChangeBasedSampler" or sampler.__class__.__name__ == "StrawmanSingleSampleBudgetDelaySampler":
                        server.update_raw_locations(curr_location)                    
                        sampler.update(extrapolator.get_location_params(curr_location))
                    else:
                        sampler.update(extrapolator.get_location_params(curr_location))
                        server.update_raw_locations(curr_location)                    

                    last_location_time = curr_location.time
                    

                                
            #before_start = False

debug_server = False
        
class Server:
    def __init__(self, extrapolator):
        self.extrapolator = extrapolator
        
        self.raw_locations = []
        self.gps_compressor = GPSCompressor()

        self.last_received_location_extrapolator_params = None
    
    def update_raw_locations(self, location):
        self.raw_locations.append(location)
    
    def update_locations(self, loc_param_window, is_init):
        global evaluated_locations_file
        global transmitted_locations_file

        # write to the evaluated locations file by combining extrapolation and interpolation
        # for i in range(0, len(self.raw_locations)):
        #     raw_location = self.raw_locations[i]
        #     #if debug_server: print "times", i, raw_location.time, loc_param_window[0][0].time
        #     if raw_location.time == loc_param_window[0][0].time:
        #         break

        if not self.raw_locations:
            #print "returning in server due to no raw_locations....."
            return

        
        for i in range(len(self.raw_locations)-1, -1, -1):
            raw_location = self.raw_locations[i]
            #if debug_server: print "times", i, raw_location.time, loc_param_window[0][0].time
            if raw_location.time == loc_param_window[0][0].time:
                break

        #print len(self.raw_locations)
        #print "i", i
        if debug_server: print "i", i
        ###print "server raw_locations", len(self.raw_locations), map(lambda x:x.time, self.raw_locations)
        raw_locations_extrapolation = self.raw_locations[0:i]
        ### print "server raw_locations_extr", len(raw_locations_extrapolation), map(lambda x:x.time, raw_locations_extrapolation)
        raw_locations_interpolation = self.raw_locations[i:]
        ### print "server raw_locations_intr", len(raw_locations_interpolation), map(lambda x:x.time, raw_locations_interpolation)
      

        if debug_server: print "raw loc extrp", len(raw_locations_extrapolation), map(lambda loc:loc.time, raw_locations_extrapolation)
       
        # extrapolation
        #for raw_location in raw_locations_extrapolation:
        #    time_offset = [raw_location.time - self.last_received_location_extrapolator_params[0].time]
        #    extrapolated_location = self.extrapolator.get_trajectory(self.last_received_location_extrapolator_params, time_offset)[0]
        #    evaluated_locations_file.write(str(raw_location.lat) + " " + str(raw_location.lon) + " " + str(extrapolated_location.lat) + \
        #                                       " " + str(extrapolated_location.lon) + " " + str(raw_location.time) + "\n")
        
        # extrapolation
        if (len(raw_locations_extrapolation) > 0):
            extrapolated_time_offsets = map(lambda raw_location: raw_location.time - self.last_received_location_extrapolator_params[0].time, raw_locations_extrapolation)
            extrapolated_locations = self.extrapolator.get_trajectory(self.last_received_location_extrapolator_params, extrapolated_time_offsets)
            
            for (raw_location, extrapolated_location) in zip(raw_locations_extrapolation, extrapolated_locations):
                evaluated_locations_file.write(str(raw_location.lat) + " " + str(raw_location.lon) + " " + str(extrapolated_location.lat) + " " + str(extrapolated_location.lon) + " " + str(raw_location.time) + "\n")
       
                ### location_error = spatialfunclib.haversine_distance(float(raw_location.lat), float(raw_location.lon), float(extrapolated_location.lat), float(extrapolated_location.lon))
                ### print "extr error", location_error
 
        # if the last part of the trip is not transmitted then it needs to be extrapolated.
        # So if this tx is for begnning/init of a trip then we put newline after the extrapolation 
        # of those non-transmitted samples for the last trip
        if is_init:
            evaluated_locations_file.write("\n")
   
        # interpolation 
        locations_from_window = map(lambda (loc,param):loc, loc_param_window)        
        if debug_server: print "locs from win in server", len(raw_locations_interpolation), map(lambda loc:loc.time, locations_from_window)
        interpolated_segment=self.gps_compressor.get_interpolated_segment(raw_locations_interpolation, locations_from_window)
        if debug_server: print len(raw_locations_interpolation), len(interpolated_segment)
        if debug_server: print "raw loc intrp", len(raw_locations_interpolation), map(lambda loc:loc.time, raw_locations_interpolation)
        if debug_server: print "interpola loc", len(interpolated_segment), map(lambda loc:loc.time, interpolated_segment)

        #print "start intr...."
        for i in range(0, len(interpolated_segment)):
            raw_loc = raw_locations_interpolation[i]
            interpolated_loc = interpolated_segment[i]
            evaluated_locations_file.write(str(raw_loc.lat) + " " + str(raw_loc.lon) + " " + str(interpolated_loc.lat) + " " + \
                                               str(interpolated_loc.lon) + " " + str(raw_loc.time) + "\n")

            
            ### location_error = spatialfunclib.haversine_distance(float(raw_loc.lat), float(raw_loc.lon), float(interpolated_loc.lat), float(interpolated_loc.lon))
            ### print "intr error", raw_loc.time, interpolated_loc.time, location_error
                
        # write to the recived location file (filename transmitted_locations_*)
        for location_extrapolator_params in loc_param_window:
            transmitted_locations_file.write(str(location_extrapolator_params[0]) + "\n")

        transmitted_locations_file.write("-----\n")

        # save the last received loc_param
        self.last_received_location_extrapolator_params = loc_param_window[-1]

        
        # clear storage
        self.raw_locations = []
        self.received_location_extrapolator_params = {}
        
        if debug_server: print "\n"

        return self.last_received_location_extrapolator_params



import sys, getopt
#ONLY Chnge from evaluator.py is importing from sampler_new rather than sampler
from sampler_new import ErrorBudgetSampler3, ErrorDelaySampler, LocationChangeBasedSampler, LocationChangeBasedFullWindowSampler, StrawmanSingleSampleBudgetDelaySampler, StrawmanWindowBudgetDelaySampler, BudgetDelayStatisticalMaxerrorSamplerOfflineExtrTable, BudgetDelayStatisticalMaxerrorSamplerOfflineExtrComprTable, BudgetDelaySamplerStrawman
from extrapolator import ConstantLocationExtrapolator, ConstantVelocityExtrapolator, MapExtrapolatorStraightRoad, UnifiedExtrapolator

if __name__ == "__main__":
    sampler_index = 1
    extrapolator_index = 0
    
    sampler_error_threshold = 50.0
    sampler_budget_threshold = 9999.0
    sampler_delay_threshold = 30.0
    budget_delay_sampler_adjusting_period_length = 14400.0
    
    # parameters for unified extrapolator
    map_filename = None
    map_trace_turn_probs_filename = None
    classifier_path = None
    map_generic_turn_probs_filename = None
    
    unique_id = "0"
    output_directory = "evaluator_output/"
    delays_directory = ""

    #offline_expected_error_file = "time_error_table_offline/msmls.pkl"
    offline_expected_error_file = None

    factor = 2.0 # defualt factor for budget delay 

    period = 1.0
    offline_error_delay_table_file_for_error_budget_sampler = None

    (opts, args) = getopt.getopt(sys.argv[1:],"s:x:e:b:d:i:o:m:t:f:p:g:c:a:l:r:u:h")
    
    for o,a in opts:
        if o == "-s":
            sampler_index = int(a)
        elif o == "-x":
            extrapolator_index = int(a)
        elif o == "-e":
            sampler_error_threshold = float(a)
        elif o == "-b":
            sampler_budget_threshold = float(a)
        elif o == "-d":
            sampler_delay_threshold = float(a)
        elif o == "-i":
            unique_id = str(a)
        elif o == "-o":
            output_directory = str(a)
        elif o == "-m":
            delays_directory = str(a)
        elif o == "-t":
            offline_expected_error_file = str(a)
        elif o == "-f":
            map_filename = str(a)
        elif o == "-p":
            map_trace_turn_probs_filename = str(a)
        elif o == "-g":
            map_generic_turn_probs_filename = str(a)
        elif o == "-c":
            classifier_path = str(a)
        elif o == "-a":
            factor = float(a)
        elif o == "-r":
            period = float(a)
        elif o == "-u":
            offline_error_delay_table_file_for_error_budget_sampler = str(a)
        elif o == "-h":
            print "Usage: <stdin> | python evaluator.py [-s <sampler>] [-x <extrapolator_index>] [-e <sampler_error_threshold>] [-b <sampler_budget_threshold>] [-d <sampler_delay_threshold>] [-i <unique_id>] [-o <output_directory>] [-m mean_delay_directory] [-r period] [-t offline_expected_error_file/offline_time_error_file(for budget_error sampler)] [-u offline_error_delay_table_file_for_error_budget_sampler] [-f <map_filename>] [-p <map_trace_turn_probs_filename>] [-c <classifier_path>] [-h]"
            exit()


    # if (sampler_index == 12): # we need to put the factor in the filename
    #     evaluated_locations_file = open(output_directory + "/evaluated_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(float(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "f_" + str(float(factor)) + "_i" + str(unique_id) + ".txt", 'w')
    #     transmitted_locations_file = open(output_directory + "/transmitted_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(float(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "f_" + str(float(factor)) + "_i" + str(unique_id) + ".txt", 'w')

    # else:    

    evaluated_locations_file = open(output_directory + "/evaluated_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(float(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "_i" + str(unique_id) + ".txt", 'w')
    transmitted_locations_file = open(output_directory + "/transmitted_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(float(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "_i" + str(unique_id) + ".txt", 'w')
    

    if delays_directory != "":
        delays_file = open(delays_directory + "/delays_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(float(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "_i" + str(unique_id) + ".txt", 'w')
    
    if (extrapolator_index == 0):
        extrapolator = ConstantLocationExtrapolator()
    elif (extrapolator_index == 1):
        extrapolator = ConstantVelocityExtrapolator()
    elif (extrapolator_index == 2):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="e", max_error_target=sampler_error_threshold)
    elif (extrapolator_index == 3):
        extrapolator = UnifiedExtrapolator(map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="dx")
    elif (extrapolator_index == 5):
        extrapolator = MapExtrapolatorStraightRoad(map_filename)
    else:
        print "ERROR!! Invalid extrapolator index: " + str(extrapolator_index)
        exit()
    
    server = Server(extrapolator)
    
    if (sampler_index == 0):
        # error budget sampler
        sampler = ErrorBudgetSampler(server, extrapolator, offline_expected_error_file, delays_file, sampler_error_threshold, sampler_budget_threshold)
    if (sampler_index == 20):
        # error budget sampler 2
        sampler = ErrorBudgetSampler2(server, extrapolator, offline_expected_error_file, delays_file, sampler_error_threshold, sampler_budget_threshold, period)    
    if (sampler_index == 21):
        # error budget sampler 3
        sampler = ErrorBudgetSampler3(server, extrapolator, offline_expected_error_file, offline_error_delay_table_file_for_error_budget_sampler, delays_file, sampler_error_threshold, sampler_budget_threshold, period)
    elif (sampler_index == 1):
        # error delay sampler
        sampler = ErrorDelaySampler(server, extrapolator, offline_expected_error_file, sampler_error_threshold, sampler_delay_threshold)
    elif (sampler_index == 2):
        # budget delay sampler
        sampler = BudgetDelaySampler(server, extrapolator, offline_expected_error_file, sampler_budget_threshold, sampler_delay_threshold)
    elif (sampler_index == 3): 
        # strawman for error delay with single sample tx
        sampler = LocationChangeBasedSampler(server, extrapolator, sampler_error_threshold)
    elif (sampler_index == 4):
        # strawman for budget delay with single sample tx
        sampler = StrawmanSingleSampleBudgetDelaySampler(server, extrapolator, sampler_budget_threshold)
    elif (sampler_index == 5):
        # strawmin for error delay with full window tx 
        sampler = LocationChangeBasedFullWindowSampler(server, extrapolator, sampler_error_threshold) 
    elif (sampler_index == 6):
        # strawman for budget delay with full window (compressed) tx
        sampler = StrawmanWindowBudgetDelaySampler(server, extrapolator, sampler_budget_threshold)
    elif (sampler_index == 8):
        # strawman for budget delay with full window (compressed) tx but with time interval
        sampler = BudgetDelaySamplerStrawman(server, extrapolator, sampler_budget_threshold, sampler_delay_threshold)
    elif (sampler_index == 12):
        # budget delay 
        sampler = BudgetDelayStatisticalMaxerrorSamplerOfflineExtrTable(server, extrapolator, offline_expected_error_file, sampler_budget_threshold, sampler_delay_threshold, period)
    elif (sampler_index == 13):
        # budget delay 
        sampler = BudgetDelayStatisticalMaxerrorSamplerOfflineExtrComprTable(server, extrapolator, offline_expected_error_file, sampler_budget_threshold, sampler_delay_threshold, period)


    else:
        print "ERROR!! Invalid sampler_index: " + str(sampler_index)
        exit()
    
    evaluator = Evaluator()
    evaluator.evaluate(sys.stdin, sampler, extrapolator, server, unique_id, offline_expected_error_file)
    
    evaluated_locations_file.close()
    transmitted_locations_file.close()

    if delays_directory != "":
        delays_file.close()
