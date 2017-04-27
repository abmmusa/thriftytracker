from location import Location
import gzip

class BoundingBox:
    def __init__(self):
        pass
    
    def evaluate_trip(self, trip, min_lat, min_lon, max_lat, max_lon):
        for location in trip:
            if ((location.lat < min_lat) or (location.lat > max_lat) or (location.lon < min_lon) or (location.lon > max_lon)):
                return False
        
        return True
    
    def write_trip_to_file(self, trip, output_file):
        for location in trip:
            output_file.write(str(location) + "\n")
        output_file.write("\n")
    
    def evaluate_traces(self, min_lat, min_lon, max_lat, max_lon, trace_file_list, input_path, output_path):
        num_traces = len(trace_file_list)
        curr_trace_id = 1
        
        for trace_filename in trace_file_list:
            sys.stdout.write("\rProcessing trace " + str(curr_trace_id) + "/" + str(num_traces) + "... ")
            sys.stdout.flush()
            
            input_trace_file = gzip.open(input_path + "/" + str(trace_filename), 'rb')
            output_trace_file = None
            
            curr_trip = []
            
            for raw_location in input_trace_file:
                if (raw_location == "\n"):
                    if (len(curr_trip) > 1):
                        valid_trip = self.evaluate_trip(curr_trip, min_lat, min_lon, max_lat, max_lon)
                        
                        if (valid_trip is True):
                            if (output_trace_file is None):
                                output_trace_file = gzip.open(output_path + "/" + str(trace_filename), 'wb')
                            
                            self.write_trip_to_file(curr_trip, output_trace_file)
                    
                    curr_trip = []
                
                else:
                    curr_location = Location()
                    curr_location.load_raw_location(raw_location)
                    curr_trip.append(curr_location)
            
            if (len(curr_trip) > 1):
                valid_trip = self.evaluate_trip(curr_trip, min_lat, min_lon, max_lat, max_lon)
                
                if (valid_trip is True):
                    if (output_trace_file is None):
                        output_trace_file = gzip.open(output_path + "/" + str(trace_filename), 'wb')
                    
                    self.write_trip_to_file(curr_trip, output_trace_file)
            
            input_trace_file.close()
            
            if (output_trace_file is not None):
                output_trace_file.close()
            
            curr_trace_id += 1
        
        sys.stdout.write("done.\n")
        sys.stdout.flush()

import sys, getopt, os, time
if __name__ == "__main__":
    min_lat = float(sys.argv[1])
    min_lon = float(sys.argv[2])
    
    max_lat = float(sys.argv[3])
    max_lon = float(sys.argv[4])
    
    trace_file_path = "../osm_gps_traces/processed/1_second_sampling_interval/"
    output_path = "../osm_gps_traces/processed/1_second_sampling_interval/bounding_boxed/moscow/500km/"
    
    (opts, args) = getopt.getopt(sys.argv[5:],"t:o:h")
    
    for o,a in opts:
        if o == "-t":
            trace_file_path = str(a)
        elif o == "-o":
            output_path = str(a)
        elif o == "-h":
            print "Usage: python bounding_box_trips2.py min_lat min_lon max_lat max_lon [-t <trace_file_path>] [-o <output_path>] [-h]"
            exit()
    
    print "min_lat: " + str(min_lat)
    print "min_lon: " + str(min_lon)
    
    print "max_lat: " + str(max_lat)
    print "max_lon: " + str(max_lon)
    
    print "trace_file_path: " + str(trace_file_path)
    print "output_path: " + str(output_path)
    
    trace_file_list = filter(lambda x: x.endswith(".txt.gz"), os.listdir(trace_file_path))
    print "trace_file_list: " + str(len(trace_file_list)) + " trace files"
    
    start_time = time.time()
    sys.stdout.write("\n")
    
    bb = BoundingBox()
    bb.evaluate_traces(min_lat, min_lon, max_lat, max_lon, trace_file_list, trace_file_path, output_path)
    
    print "Finished (in " + str(time.time() - start_time) + " seconds)."
