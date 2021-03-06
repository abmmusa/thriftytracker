from location import Location
from pylibs import spatialfunclib
import math

class EvalProcessor:
    def __init__(self):
        pass
    
    def process(self, sampler_index, extrapolator_index, sampler_params, unique_ids):
        
        square_error = 0.0
        sample_error = 0.0
        sample_count = 0
        transmitted_locations_count = 0
        elapsed_time = 0.0
        
        mean_delay = 0.0

        for unique_id in unique_ids:
            
            evaluated_locations_file = open(evaluator_output_path + "evaluated_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_" + str(sampler_params) + "_i" + str(unique_id) + ".txt", 'r')
            (square_error, sample_error, sample_count, elapsed_time) = self.process_file(evaluated_locations_file, square_error, sample_error, sample_count, elapsed_time)
            evaluated_locations_file.close()
            
            transmitted_locations_file = open(evaluator_output_path + "transmitted_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_" + str(sampler_params) + "_i" + str(unique_id) + ".txt", 'r')
            transmitted_locations_count += len(filter(lambda x: x == "-----\n", transmitted_locations_file.readlines())) #len(transmitted_locations_file.readlines())
            transmitted_locations_file.close()
        
            if sampler_index == 0 and delays_path != "":
                delays_file = open(delays_path + "delays_s" + str(sampler_index) + "_x" + str(extrapolator_index) + "_" + str(sampler_params) + "_i" + str(unique_id) + ".txt", 'r')
                all_delays = delays_file.readlines()
                sum_delay = sum(map(lambda x:float(x), all_delays))
                count_delays = len(all_delays)
                mean_delay = sum_delay/count_delays
                #print sum_delay, count_delays, mean_delay
                delays_file.close()


        #rms_error = math.sqrt(float(square_error) / float(sample_count))
        rms_error = math.sqrt(square_error)

        if sampler_index == 0 and delays_path != "":
            output_file.write(str(sampler_index) + " " + str(extrapolator_index) + " " + str(sampler_params.replace("_"," ")) + " " + str("%.6f" % rms_error) + " " + str("%.6f" % sample_error) + " " + str(sample_count) + " " + str(transmitted_locations_count) + " " + str(elapsed_time) + " " + str(mean_delay) + "\n")
        else:
            output_file.write(str(sampler_index) + " " + str(extrapolator_index) + " " + str(sampler_params.replace("_"," ")) + " " + str("%.6f" % rms_error) + " " + str("%.6f" % sample_error) + " " + str(sample_count) + " " + str(transmitted_locations_count) + " " + str(elapsed_time) + "\n")

    def process_file(self, evaluated_locations, square_error, sample_error, sample_count, elapsed_time):
        
        prev_time = None
        
        for evaluated_location in evaluated_locations:
            
            if (evaluated_location == "\n"):
                prev_time = None
                continue
            else:
                evaluated_location_components = evaluated_location.strip("\n").split(" ")
                location_error = spatialfunclib.haversine_distance(float(evaluated_location_components[0]), float(evaluated_location_components[1]), float(evaluated_location_components[2]), float(evaluated_location_components[3]))

                #print location_error, evaluated_location_components[4]

                #print evaluated_location_components[0], evaluated_location_components[1], evaluated_location_components[2], evaluated_location_components[3], evaluated_location_components[4], location_error

                #square_error += pow(location_error, 2.0)
                #sample_error += location_error


                square_error = ((square_error * (float(sample_count) / (float(sample_count) + 1))) + (pow(location_error, 2.0) * (1.0 / (float(sample_count) + 1))))
                sample_error = ((sample_error * (float(sample_count) / (float(sample_count) + 1))) + (location_error * (1.0 / (float(sample_count) + 1))))
                sample_count += 1
                
                curr_time = float(evaluated_location_components[4])
                
                if (prev_time is not None):
                    elapsed_time += (curr_time - prev_time)
                prev_time = curr_time
        
        return (square_error, sample_error, sample_count, elapsed_time)

import sys, getopt
import os
if __name__ == "__main__":
    
    sampler_index = 0
    extrapolator_index = 0
    evaluator_output_path = "evaluator_output/"
    processed_output_path = "process_evals_output/"
    delays_path = ""

    (opts, args) = getopt.getopt(sys.argv[1:],"s:x:i:o:m:h")
    
    for o,a in opts:
        if o == "-s":
            sampler_index = int(a)
        elif o == "-x":
            extrapolator_index = int(a)
        elif o == "-i":
            evaluator_output_path = str(a)
        elif o == "-o":
            processed_output_path = str(a)
        elif o == "-m":
            delays_path = str(a)
        elif o == "-h":
            print "Usage: python process_evals.py [-s <sampler>] [-x <extrapolator>] [-i <evaluator_output_path>] [-m <mean_delays_path>] [-o <processed_output_path>] [-h]"
            exit()
    
    evaluated_locations_prefix = "evaluated_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index)
    transmitted_locations_prefix = "transmitted_locations_s" + str(sampler_index) + "_x" + str(extrapolator_index)
    delays_prfix = "delays_s" + str(sampler_index) + "_x" + str(extrapolator_index)
    
    all_eval_files = filter(lambda x: x.startswith(evaluated_locations_prefix) or x.startswith(transmitted_locations_prefix), os.listdir(evaluator_output_path))
    #print "all eval files: " + str(all_eval_files)
    
    all_sampler_params = list(set(map(lambda x: "_".join(x.split("_")[4:7]), all_eval_files)))
    #print "all sampler params: " + str(all_sampler_params)
    
    unique_ids = list(set(map(lambda x: x.split("_")[7][1:-4], all_eval_files)))
    #print "unique ids: " + str(unique_ids)
    
    eval_processor = EvalProcessor()
    
    output_file = open(processed_output_path + "processed_eval_s" + str(sampler_index) + "_x" + str(extrapolator_index) + ".txt", 'w')
    
    for sampler_params in all_sampler_params:
        eval_processor.process(sampler_index, extrapolator_index, sampler_params, unique_ids)
    
    output_file.close()
