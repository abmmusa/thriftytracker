class NodeSequenceExtractor:
    def __init__(self):
        pass
    
    def extract(self, map_matched_trace):
        first_row = True
        prev_edge = None
        
        for raw_mm_trace_row in map_matched_trace: #(lat, lon, time, obs_flag, in_node_id, out_node_id)
            mm_trace_row = raw_mm_trace_row.strip("\n").split(" ")
            
            if (len(mm_trace_row) == 6):
                curr_edge = (mm_trace_row[4], mm_trace_row[5])
                
                if (curr_edge == ("None", "None")):
                    prev_edge = None
                    continue
                
                if (curr_edge != prev_edge):
                    if (prev_edge is None):
                        if (first_row is True):
                            sys.stdout.write(str(curr_edge[0]) + " " + str(curr_edge[1]))
                            first_row = False
                        else:
                            sys.stdout.write("\n" + str(curr_edge[0]) + " " + str(curr_edge[1]))
                    else:
                        if (curr_edge[0] == prev_edge[1]):
                            sys.stdout.write(" " + str(curr_edge[1]))
                        else:
                            sys.stdout.write("\n" + str(curr_edge[0]) + " " + str(curr_edge[1]))
                
                prev_edge = curr_edge
            
            else:
                prev_edge = None
                continue
        
        sys.stdout.write("\n")

import sys, getopt
if __name__ == "__main__":
    
    (opts, args) = getopt.getopt(sys.argv[1:],"h")
    
    for o,a in opts:
        if o == "-h":
            print "Usage: <stdin> | python node_sequence_extractor.py [-h]"
            exit()
    
    node_sequence_extractor = NodeSequenceExtractor()
    node_sequence_extractor.extract(sys.stdin)
