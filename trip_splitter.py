import os, random

class TripSplitter:
    def __init__(self):
        pass
    
    def split(self, raw_trace_filename, output_path, num_splits):
        raw_trace = gzip.open(raw_trace_filename, 'rb')
        
        all_trips = []
        curr_trip = []
        
        for raw_location in raw_trace:
            if (raw_location == "\n"):
                all_trips.append(curr_trip)
                curr_trip = []
            else:
                curr_trip.append(raw_location)
        
        if (len(curr_trip) > 0):
            all_trips.append(curr_trip)
        
        raw_trace.close()
        
        # shuffle trip order (NOT locations within trips)
        random.seed(1370118626)
        random.shuffle(all_trips)
        
        if (raw_trace_filename.rfind("/") == -1):
            output_filename = str(raw_trace_filename)
        else:
            output_filename = raw_trace_filename[raw_trace_filename.rfind("/") + 1:]
        
        print "output filename: " + str(output_filename)
        
        trips_per_split = int(round(len(all_trips) / float(num_splits)))
        
        print "number of trips: " + str(len(all_trips))
        print "trips per split: " + str(trips_per_split)
        
        for i in range(0, num_splits):
            if (i < (num_splits - 1)):
                curr_split = all_trips[(i * trips_per_split):((i + 1) * trips_per_split)]
                print "split " + str(i) + ", trips: [" + str(i * trips_per_split) + ":" + str((i + 1) * trips_per_split) + "], length: " + str(len(curr_split))
            else:
                curr_split = all_trips[(i * trips_per_split):]
                print "split " + str(i) + ", trips: [" + str(i * trips_per_split) + ":], length: " + str(len(curr_split))
            
            self._write_trips_to_file(curr_split, i, output_path, output_filename)
    
    def _write_trips_to_file(self, trips, split_number, output_path, output_filename):
        split_path = str(output_path) + "/split_" + str(split_number) + "/"
        
        if not os.path.exists(split_path):
            os.mkdir(split_path)
        
        split_file = gzip.open(str(split_path) + "/" + str(output_filename), 'wb')
        
        for trip in trips:
            for location in trip:
                split_file.write(str(location))
            split_file.write("\n")
        
        split_file.close()

import sys, getopt, gzip
if __name__ == "__main__":
    raw_trace_filename = "traces/msmls/msmls_subject_8.txt.gz"
    output_path = "traces/msmls/"
    num_splits = 5
    
    (opts, args) = getopt.getopt(sys.argv[1:],"t:o:n:h")
    
    for o,a in opts:
        if o == "-t":
            raw_trace_filename = str(a)
        elif o == "-o":
            output_path = str(a)
        elif o == "-n":
            num_splits = int(a)
        elif o == "-h":
            print "Usage: python trip_splitter.py [-t <raw_trace_filename>] [-o <output_path>] [-n <num_splits>] [-h]"
            exit()
    
    ts = TripSplitter()
    ts.split(raw_trace_filename, output_path, num_splits)
