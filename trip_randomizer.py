import random
import time
import gzip

class TripRandomizer:
    def __init__(self):
        #random.seed(1390368065) # 193514 w/0.004 (mac)
        random.seed(1390419000) # 193771 w/0.004 (words4)
    
    def randomize_trips(self, trace_file_list, input_path, output_path, output_file_prefix, num_buckets=64):
        num_traces = len(trace_file_list)
        curr_trace_id = 1
        
        all_trips = []
        
        for trace_filename in trace_file_list:
            sys.stdout.write("\rProcessing trace " + str(curr_trace_id) + "/" + str(num_traces) + "... ")
            sys.stdout.flush()
            
            input_trace_file = gzip.open(input_path + "/" + str(trace_filename), 'rb')
            curr_trip = []
            
            for raw_location in input_trace_file:
                if (raw_location == "\n"):
                    if (len(curr_trip) > 1):
                        all_trips.append(curr_trip)
                    
                    curr_trip = []
                
                else:
                    curr_trip.append(raw_location)
            
            if (len(curr_trip) > 1):
                all_trips.append(curr_trip)
            
            input_trace_file.close()
            
            curr_trace_id += 1
        
        num_samples = sum(map(lambda x: len(x), all_trips))
        
        sys.stdout.write("done (" + str(len(all_trips)) + " trips consisting of " + str(num_samples) + " samples, loaded).\n")
        sys.stdout.flush()
        
        print "num_buckets: " + str(num_buckets)
        target_bucket_size = int(round(float(num_samples) / float(num_buckets)))
        print "target_bucket_size: " + str(target_bucket_size) + "\n"
        
        fudge_factor = (target_bucket_size * 0.004)
        
        all_buckets = []
        
        for i in range(0, num_buckets - 1):
            curr_bucket = []
            curr_bucket_size = 0
            
            while (curr_bucket_size < target_bucket_size):
                random_trip_index = random.randint(0, len(all_trips) - 1)
                
                random_trip_length = len(all_trips[random_trip_index])
                
                if (random_trip_length < (target_bucket_size - curr_bucket_size + fudge_factor)):
                    curr_bucket.append(all_trips.pop(random_trip_index))
                
                curr_bucket_size = sum(map(lambda x: len(x), curr_bucket))
                
                if (curr_bucket_size >= (target_bucket_size - fudge_factor)):
                    all_buckets.append(curr_bucket)
                    break
        
        all_buckets.append(all_trips)
        
        for i in range(0, len(all_buckets)):
            print "bucket[" + str(i) + "]: " + str(sum(map(lambda x: len(x), all_buckets[i])))
        print ""
        
        for i in range(0, len(all_buckets)):
            sys.stdout.write("\rWriting randomized trace file " + str(i + 1) + "/" + str(len(all_buckets)) + "... ")
            sys.stdout.flush()
            
            output_trace_file = gzip.open(output_path + "/" + str(output_file_prefix) + str(i) + ".txt.gz", 'wb')
            
            curr_bucket = all_buckets[i]
            num_trips = len(curr_bucket)
            
            for j in range(0, num_trips):
                for raw_location in curr_bucket[j]:
                    output_trace_file.write(raw_location)
                output_trace_file.write("\n")
            
            output_trace_file.close()
        
        sys.stdout.write("done.\n")
        sys.stdout.flush()

import sys, getopt, os, time
if __name__ == "__main__":
    trace_file_path = "moscow/300km/"
    output_path = "moscow/300km_randomized_trips/"
    output_file_prefix = "osm_subject_"
    num_buckets = 64
    
    (opts, args) = getopt.getopt(sys.argv[1:],"t:o:p:n:h")
    
    for o,a in opts:
        if o == "-t":
            trace_file_path = str(a)
        elif o == "-o":
            output_path = str(a)
        elif o == "-p":
            output_file_prefix = str(a)
        elif o == "-n":
            num_buckets = int(a)
        elif o == "-h":
            print "Usage: python trip_randomizer.py [-t <trace_file_path>] [-o <output_path>] [-p <output_file_prefix>] [-n <num_buckets>] [-h]"
            exit()
    
    print "trace_file_path: " + str(trace_file_path)
    print "output_path: " + str(output_path)
    print "output_file_prefix: " + str(output_file_prefix)
    print "num_buckets: " + str(num_buckets)
    
    trace_file_list = filter(lambda x: x.endswith(".txt.gz"), os.listdir(trace_file_path))
    print "trace_file_list: " + str(len(trace_file_list)) + " trace files"
    
    start_time = time.time()
    sys.stdout.write("\n")
    
    tr = TripRandomizer()
    tr.randomize_trips(trace_file_list, trace_file_path, output_path, output_file_prefix, num_buckets)
    
    print "Finished (in " + str(time.time() - start_time) + " seconds)."
