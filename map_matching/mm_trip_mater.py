import gzip

class TripMater:
    def __init__(self):
        pass
    
    def mate(self, trace, map_matched_samples_file):
        map_matched_samples_file = gzip.open(map_matched_samples_filename, 'rb')
        map_matched_samples = map(lambda x: x.strip("\n").split(" "), map_matched_samples_file)
        map_matched_samples_file.close()
        
        filtered_map_matched_samples = []
        
        prev_node_limit = 11
        prev_nodes = None
        curr_nodes = None
        
        for map_matched_sample in map_matched_samples:
            #print "map_matched_sample: " + str(map_matched_sample)
            
            if (map_matched_sample[0] == ""):
                filtered_map_matched_samples.append(map_matched_sample)
                prev_nodes = None
                curr_nodes = None
            
            else:
                curr_nodes = [map_matched_sample[4], map_matched_sample[5]]
                
                if (prev_nodes is not None):
                    if (prev_nodes[-2:] == curr_nodes):
                        map_matched_sample.append(prev_nodes[-12:-1])
                    elif (prev_nodes[-1] == curr_nodes[0]):
                        map_matched_sample.append(prev_nodes[-11:])
                    else:
                        map_matched_sample.append(["None"])
                else:
                    map_matched_sample.append(["None"])
                
                if (map_matched_sample[3] == "1"):
                    filtered_map_matched_samples.append(map_matched_sample)
                    #print "valid map_matched_sample: " + str(map_matched_sample)
                
                if ((curr_nodes[0] == "None") or (curr_nodes[1] == "None")):
                    curr_nodes = None
            
            if ((prev_nodes is not None) and (curr_nodes is not None)):
                if (prev_nodes[-1] == curr_nodes[0]):
                    prev_nodes.append(curr_nodes[1])
                elif (prev_nodes[-2:] != curr_nodes):
                    prev_nodes = curr_nodes
            else:
                prev_nodes = curr_nodes
        
        mm_sample_itr = 0
        
        for raw_location in trace:
            if (raw_location == "\n"):
                sys.stdout.write(raw_location)
            
            else:
                raw_location_components = raw_location.strip("\n").split(" ")
                
                raw_location_time = int(float(raw_location_components[2]))
                map_matched_sample_time = int(filtered_map_matched_samples[mm_sample_itr][2])
                
                if (raw_location_time != map_matched_sample_time):
                    print "ERROR!! Time mismatch, raw: " + str(raw_location_time) + ", map matched: " + str(map_matched_sample_time)
                    exit()
                else:
                    sys.stdout.write(str(" ".join(raw_location_components[:7])) + " " + str(" ".join(filtered_map_matched_samples[mm_sample_itr][4:6])) + " " + str(",".join(filtered_map_matched_samples[mm_sample_itr][6])) + "\n")
            
            mm_sample_itr += 1

import sys, getopt
if __name__ == "__main__":
    map_matched_samples_filename = "matched_traces/msmls_subject_0_mm_m1.txt"
    
    (opts, args) = getopt.getopt(sys.argv[1:],"m:h")
    
    for o,a in opts:
        if o == "-m":
            map_matched_samples_filename = str(a)
        elif o == "-h":
            print "Usage: <stdin> | python mm_trip_mater.py [-m <map_matched_samples_filename>] [-h]"
            exit()
    
    trip_mater = TripMater()
    trip_mater.mate(sys.stdin, map_matched_samples_filename)
