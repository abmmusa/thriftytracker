from location import LocationWithEstimatedValues

debug = False
ENABLE_ONLINE_TABLE = False #need to change at sampler.py too (bad!)

class Evaluator:
    def __init__(self):
        self.time_error_table_file_counter = 0
        pass
    
    def evaluate(self, trace, sampler, extrapolator, server, unique_id, offline_table_file):
        need_init = True
        last_location_time = None
        
        for raw_location in trace:
            if (raw_location == "\n"):
                need_init = True
                sampler.cleanup_last_window()
                server.cleanup()
                
                if ENABLE_ONLINE_TABLE:
                    output_file=open("time_error_table/"+str(unique_id)+"_"+str(self.time_error_table_file_counter), 'w')
                    sampler.write_time_error_table_with_bucket(output_file)
                    output_file.close()

                    self.time_error_table_file_counter += 1

            else:
                curr_location = LocationWithEstimatedValues()
                curr_location.load_raw_location(raw_location)
                
                if (need_init is True):
                    #server.cleanup()

                    sampler.init_location(extrapolator.init_location_params(curr_location))
                    last_location_time = curr_location.time
                    need_init = False

                else:
                    for i in range(0, (int(curr_location.time) - int(last_location_time) - 1)):
                        sampler.update(None)
                    
                    sampler.update(extrapolator.get_location_params(curr_location))
                    last_location_time = curr_location.time
                
                server.update_raw_locations(curr_location)
        
        #print sampler.get_expected_error_for_timerange(1,100)
        #print sampler.get_expected_error_for_timelist([1,4,5,6,7])

        server.cleanup()




class Server:
    def __init__(self, extrapolator, evaluated_locations_file, received_locations_file):
        self.extrapolator = extrapolator
        self.evaluated_locations_file = evaluated_locations_file
        self.received_locations_file = received_locations_file
        
        self.raw_locations = []
        self.received_location_extrapolator_params = {}
    
    def cleanup(self):
        
        #print sorted(self.received_location_extrapolator_params.keys())
        #print self.raw_locations

        last_received_location_extrapolator_params = None
        
        for raw_location in self.raw_locations:
            
            # if we have a received location for this time
            if raw_location.time in self.received_location_extrapolator_params:
                last_received_location_extrapolator_params = self.received_location_extrapolator_params[raw_location.time]
                received_location = last_received_location_extrapolator_params[0]
                self.evaluated_locations_file.write(str(raw_location.lat) + " " + str(raw_location.lon) + " " + str(received_location.lat) + " " + str(received_location.lon) + " " + str(raw_location.time) + "\n")
            
            # else, we need to extrapolate for this time
            else:
                time_offset = [raw_location.time - last_received_location_extrapolator_params[0].time]
                extrapolated_location = self.extrapolator.get_trajectory(last_received_location_extrapolator_params, time_offset)[0]
                self.evaluated_locations_file.write(str(raw_location.lat) + " " + str(raw_location.lon) + " " + str(extrapolated_location.lat) + " " + str(extrapolated_location.lon) + " " + str(raw_location.time) + "\n")
        
        if (len(self.raw_locations) > 0):
            self.evaluated_locations_file.write("\n")
        
        # clear storage
        self.raw_locations = []
        self.received_location_extrapolator_params = {}
    
    def update_raw_locations(self, location):
        self.raw_locations.append(location)
    
    def update_locations(self, location_extrapolator_params_window):
        for location_extrapolator_params in location_extrapolator_params_window:
            self.received_locations_file.write(str(location_extrapolator_params[0]) + "\n")
            self.received_location_extrapolator_params[location_extrapolator_params[0].time] = location_extrapolator_params
        
        self.received_locations_file.write("-----\n")
        return location_extrapolator_params_window[-1]

import sys, getopt
from sampler import ErrorBudgetSampler, ErrorDelaySampler, BudgetDelaySampler, LocationChangeBasedSampler, TimeChangeBasedSampler
from extrapolator import ConstantLocationExtrapolator, ConstantVelocityExtrapolator, UnifiedExtrapolator

if __name__ == "__main__":
    extrapolators = [ConstantLocationExtrapolator, ConstantVelocityExtrapolator, UnifiedExtrapolator]
    
    sampler_index = 1
    extrapolator_index = 0
    
    sampler_error_threshold = 50.0
    sampler_budget_threshold = 9999.0
    sampler_delay_threshold = 30.0
    
    unique_id = "0"
    output_directory = "evaluator_output/"
    delays_directory = ""

    #offline_expected_error_file = "time_error_table_offline/msmls.pkl"
    offline_expected_error_file = None


    (opts, args) = getopt.getopt(sys.argv[1:],"s:x:e:b:d:i:o:m:t:h")
    
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
        elif o == "-h":
            print "Usage: <stdin> | python evaluator.py [-s <sampler>] [-x <extrapolator_index>] [-e <sampler_error_threshold>] [-b <sampler_budget_threshold>] [-d <sampler_delay_threshold>] [-i <unique_id>] [-o <output_directory>] [-m mean_delay_directory] [-t offline_expected_error_file/offline_time_error_file(for budget_error sampler)] [-h]"
            exit()
    
    evaluated_locations_file = open(output_directory + "/evaluated_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(int(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "_i" + str(unique_id) + ".txt", 'w')
    transmitted_locations_file = open(output_directory + "/transmitted_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(int(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "_i" + str(unique_id) + ".txt", 'w')
    

    if delays_directory != "":
        delays_file = open(delays_directory + "/delays_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_e" + str(int(sampler_error_threshold)) + "_b" + str(int(sampler_budget_threshold)) + "_d" + str(int(sampler_delay_threshold)) + "_i" + str(unique_id) + ".txt", 'w')

    if (extrapolator_index < len(extrapolators)):
        extrapolator = extrapolators[extrapolator_index]()
    else:
        print "ERROR!! Invalid extrapolator index: " + str(extrapolator_index)
        exit()
    
    server = Server(extrapolator, evaluated_locations_file, transmitted_locations_file)
    
    if (sampler_index == 0):
        sampler = ErrorBudgetSampler(server, extrapolator, offline_expected_error_file, delays_file, sampler_error_threshold, sampler_budget_threshold)
    elif (sampler_index == 1):
        sampler = ErrorDelaySampler(server, extrapolator, offline_expected_error_file, sampler_error_threshold, sampler_delay_threshold)
    elif (sampler_index == 2):
        sampler = BudgetDelaySampler(server, extrapolator, offline_expected_error_file, sampler_budget_threshold, sampler_delay_threshold)
    elif (sampler_index == 3):
        sampler = LocationChangeBasedSampler(server, extrapolator, sampler_error_threshold)
    elif (sampler_index == 4):
        sampler = TimeChangeBasedSampler(server, extrapolator, sampler_budget_threshold)
    else:
        print "ERROR!! Invalid sampler_index: " + str(sampler_index)
        exit()
    
    evaluator = Evaluator()
    evaluator.evaluate(sys.stdin, sampler, extrapolator, server, unique_id, offline_expected_error_file)
    
    evaluated_locations_file.close()
    transmitted_locations_file.close()

    if delays_directory != "":
        delays_file.close()
