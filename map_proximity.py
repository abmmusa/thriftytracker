from pylibs import spatialfunclib
from streetmap import StreetMap
from location import Location
from rtree import Rtree
import gzip

class MapProximity:
    def __init__(self, map_pickle_filename):
        sys.stdout.write("Loading map... ")
        sys.stdout.flush()
        
        self.map = StreetMap()
        self.map.load_pickle(map_pickle_filename)
        
        sys.stdout.write("done.\n")
        sys.stdout.flush()
        
        self.map.edges = {}
        self.map.edge_index = Rtree()
        
        sys.stdout.write("Indexing map edges... ")
        sys.stdout.flush()
        
        curr_edge_id = 0
        
        for in_node in self.map.nodes.values():
            for out_node in in_node.out_nodes:
                self.map.edges[curr_edge_id] = (in_node, out_node)
                
                curr_edge_minx = min(in_node.longitude, out_node.longitude)
                curr_edge_miny = min(in_node.latitude, out_node.latitude)
                curr_edge_maxx = max(in_node.longitude, out_node.longitude)
                curr_edge_maxy = max(in_node.latitude, out_node.latitude)
                
                self.map.edge_index.insert(curr_edge_id, (curr_edge_minx, curr_edge_miny, curr_edge_maxx, curr_edge_maxy))
                
                curr_edge_id += 1
        
        sys.stdout.write("done.\n")
        sys.stdout.flush()
    
    def evaluate_trip(self, trip, proximity_threshold):
        max_distance_to_edge = 0.0
        
        for location in trip:
            closest_edge_distance = float('infinity')
            
            for edge_id in self.map.edge_index.nearest((location.lon, location.lat), 20):
                (in_node, out_node) = self.map.edges[edge_id]
                
                (proj_location, proj_fraction, _) = spatialfunclib.projection_onto_line(in_node.latitude, in_node.longitude, out_node.latitude, out_node.longitude, location.lat, location.lon)
                
                if (proj_fraction > 1.0):
                    proj_location = (out_node.latitude, out_node.longitude)
                elif (proj_fraction < 0.0):
                    proj_location = (in_node.latitude, in_node.longitude)
                
                distance_to_edge = spatialfunclib.distance(location.lat, location.lon, proj_location[0], proj_location[1])
                
                if (distance_to_edge < closest_edge_distance):
                    closest_edge_distance = distance_to_edge
            
            if (closest_edge_distance > max_distance_to_edge):
                max_distance_to_edge = closest_edge_distance
        
        if (max_distance_to_edge < proximity_threshold):
            return True
        else:
            return False
    
    def write_trip_to_file(self, trip, output_file):
        for location in trip:
            output_file.write(str(location) + "\n")
        output_file.write("\n")
    
    def evaluate_traces(self, trace_file_list, input_path, output_path, proximity_threshold):
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
                        valid_trip = self.evaluate_trip(curr_trip, proximity_threshold)
                        
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
                valid_trip = self.evaluate_trip(curr_trip, proximity_threshold)
                
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
    map_pickle_filename = "/shared/maps/great_britain/england/greater_london/greater-london-latest.pkl"
    trace_file_path = "../osm_gps_traces/processed/1_second_sampling_interval/"
    output_path = "../osm_gps_traces/processed/1_second_sampling_interval/greater_london/"
    proximity_threshold = 100.0 # meters
    
    (opts, args) = getopt.getopt(sys.argv[1:],"m:t:o:p:h")
    
    for o,a in opts:
        if o == "-m":
            map_pickle_filename = str(a)
        elif o == "-t":
            trace_file_path = str(a)
        elif o == "-o":
            output_path = str(a)
        elif o == "-p":
            proximity_threshold = float(a)
        elif o == "-h":
            print "Usage: python map_proximity.py [-m <map_pickle_filename>] [-t <trace_file_path>] [-o <output_path>] [-p <proximity_threshold>] [-h]"
            exit()
    
    print "map_pickle_filename: " + str(map_pickle_filename)
    print "trace_file_path: " + str(trace_file_path)
    print "output_path: " + str(output_path)
    print "proximity_threshold: " + str(proximity_threshold)
    
    trace_file_list = filter(lambda x: x.endswith(".txt.gz"), os.listdir(trace_file_path))
    print "trace_file_list: " + str(len(trace_file_list)) + " trace files"
    
    start_time = time.time()
    sys.stdout.write("\n")
    
    mp = MapProximity(map_pickle_filename)
    mp.evaluate_traces(trace_file_list, trace_file_path, output_path, proximity_threshold)
    
    print "Finished (in " + str(time.time() - start_time) + " seconds)."
