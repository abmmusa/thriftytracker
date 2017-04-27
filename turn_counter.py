from pylibs import spatialfunclib
from streetmap import StreetMap

class TurnCounter:
    def __init__(self):
        pass
    
    def count(self, raw_node_sequences, map_pickle_filename):
        sys.stdout.write("Loading map... ")
        sys.stdout.flush()
        
        street_map = StreetMap()
        street_map.load_pickle(map_pickle_filename)
        
        sys.stdout.write("done.\n")
        sys.stdout.flush()
        
        sys.stdout.write("Loading node sequences... ")
        sys.stdout.flush()
        
        node_sequences = filter(lambda x: len(x) > 2, map(lambda y: y.strip("\n").split(" "), raw_node_sequences.readlines()))
        
        sys.stdout.write("done.\n")
        sys.stdout.flush()
        
        sys.stdout.write("Counting turns... ")
        sys.stdout.flush()
        
        turn_count = 0
        no_turn_count = 0
        
        for node_sequence in node_sequences:
            for i in range(2, len(node_sequence)):
                in_edge_in_node = street_map.nodes[int(node_sequence[i - 2])]
                in_edge_out_node = street_map.nodes[int(node_sequence[i - 1])]
                
                out_edge_in_node = in_edge_out_node
                out_edge_out_node = street_map.nodes[int(node_sequence[i])]
                
                num_turn_options = len(in_edge_out_node.out_nodes)
                
                if (in_edge_in_node in in_edge_out_node.out_nodes):
                    num_turn_options -= 1
                
                if (num_turn_options > 1):
                    in_edge_bearing = spatialfunclib.path_bearing(in_edge_in_node.latitude, in_edge_in_node.longitude, in_edge_out_node.latitude, in_edge_out_node.longitude)
                    out_edge_bearing = spatialfunclib.path_bearing(out_edge_in_node.latitude, out_edge_in_node.longitude, out_edge_out_node.latitude, out_edge_out_node.longitude)
                    
                    edge_bearing_difference = spatialfunclib.bearing_difference(in_edge_bearing, out_edge_bearing)
                    
                    if (edge_bearing_difference < 90.0):
                        no_turn_count += 1
                    else:
                        turn_count += 1
        
        sys.stdout.write("done.\n\n")
        sys.stdout.flush()
        
        total_count = (turn_count + no_turn_count)
        
        sys.stdout.write("total_count: " + str(total_count) + "\n\n")
        sys.stdout.write("turn_count: " + str(turn_count) + " (" + str(float(turn_count) / float(total_count)) + ")\n")
        sys.stdout.write("no_turn_count: " + str(no_turn_count) + " (" + str(float(no_turn_count) / float(total_count)) + ")\n")
        sys.stdout.flush()

import sys, getopt
if __name__ == "__main__":
    map_pickle_filename = "map_matching/pickle/moscow-140114_300km.pkl"
    
    (opts, args) = getopt.getopt(sys.argv[1:],"m:h")
    
    for o,a in opts:
        if o == "-m":
            map_pickle_filename = str(a)
        elif o == "-h":
            print "Usage: <stdin> | python turn_counter.py [-m <map_pickle_filename>] [-h]"
            exit()
    
    tc = TurnCounter()
    tc.count(sys.stdin, map_pickle_filename)
