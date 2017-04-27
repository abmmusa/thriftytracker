from OSMMatcher import OSMMatcher
import spatialfunclib
import math

MAX_SPEED_M_PER_S = 20.0

class MatchOSM:
    def __init__(self, map_filename, bbox_mode, constraint_length, max_dist):
        self.matcher = OSMMatcher(map_filename, bbox_mode, constraint_length, max_dist)
        self.constraint_length = constraint_length
    
    def process_trips(self, trace):
        curr_trip = []
        
        for raw_observation in trace:
            if (raw_observation == "\n"):
                if (len(curr_trip) > 1):
                    self.process_trip(curr_trip)
                curr_trip = []
            else:
                curr_trip.append(raw_observation.strip("\n").split(" "))
        
        if (len(curr_trip) > 1):
            self.process_trip(curr_trip)
    
    def process_trip(self, raw_observations):
        V=None
        p={}
        
        obs = []
        obs_states = []
        max_prob_p = None
        
        for i in range(1, len(raw_observations)):
            (prev_lat, prev_lon, prev_time) = (raw_observations[i - 1][0], raw_observations[i - 1][1], raw_observations[i - 1][2])
            (curr_lat, curr_lon, curr_time) = (raw_observations[i][0], raw_observations[i][1], raw_observations[i][2])
            
            prev_time = float(prev_time)
            curr_time = float(curr_time)
            
            elapsed_time = int(curr_time - prev_time)
            
            if (i > 1):
                start_time = 1
            else:
                start_time = 0
            
            (prev_int_lat, prev_int_lon, prev_int_time) = (prev_lat, prev_lon, prev_time)
            
            for j in range(start_time, (elapsed_time + 1)):
                
                fraction_along = (float(j) / float(elapsed_time))
                (int_lat, int_lon) = spatialfunclib.point_along_line(float(prev_lat), float(prev_lon), float(curr_lat), float(curr_lon), fraction_along)
                
                int_distance = spatialfunclib.haversine_distance((float(prev_int_lat), float(prev_int_lon)), (float(int_lat), float(int_lon)))
                
                if (int_distance > MAX_SPEED_M_PER_S):
                    
                    int_steps = int(math.ceil(int_distance / MAX_SPEED_M_PER_S))
                    int_step_distance = (int_distance / float(int_steps))
                    int_step_time = (1.0 / float(int_steps))
                    
                    for k in range(1, int_steps):
                        step_fraction_along = ((k * int_step_distance) / int_distance)
                        (step_int_lat, step_int_lon) = spatialfunclib.point_along_line(float(prev_int_lat), float(prev_int_lon), float(int_lat), float(int_lon), step_fraction_along)
                        
                        (V, p) = self.matcher.step((float(step_int_lat), float(step_int_lon)), V, p)
                        
                        max_prob_state = max(V, key=lambda x: V[x])
                        max_prob_p = p[max_prob_state]
                        
                        if (len(max_prob_p) == self.constraint_length):
                            obs_states.append(max_prob_p[0])
                        
                        obs.append((step_int_lat, step_int_lon, (float(prev_int_time) + (float(k) * int_step_time)), 0))
                
                (V, p) = self.matcher.step((float(int_lat), float(int_lon)), V, p)
                
                max_prob_state = max(V, key=lambda x: V[x])
                max_prob_p = p[max_prob_state]
                
                if (len(max_prob_p) == self.constraint_length):
                    obs_states.append(max_prob_p[0])
                
                if ((fraction_along == 0.0) or (fraction_along == 1.0)):
                    obs.append((int_lat, int_lon, (int(prev_time) + j), 1))
                else:
                    obs.append((int_lat, int_lon, (int(prev_time) + j), 0))
                
                #obs.append((int_lat, int_lon, (int(prev_time) + j), obs_flag))
                (prev_int_lat, prev_int_lon, prev_int_time) = (int_lat, int_lon, (int(prev_time) + j))
        
        if (len(max_prob_p) < self.constraint_length):
            obs_states.extend(max_prob_p)
        else:
            obs_states.extend(max_prob_p[1:])
        
        # output matched trip to stdout
        self.output_matched_trip(obs, obs_states)
    
    def output_matched_trip(self, obs, obs_states):
        assert(len(obs_states) == len(obs))
        
        for i in range(0, len(obs)):
            (obs_lat, obs_lon, obs_time, obs_flag) = obs[i]
            sys.stdout.write(str(obs_lat) + " " + str(obs_lon) + " " + str(obs_time) + " " + str(obs_flag) + " ")
            
            if (obs_states[i] == "unknown"):
                sys.stdout.write("None None\n")
            else:
                (orig_in_node, orig_out_node) = self.matcher.edge_map[obs_states[i]]
                sys.stdout.write(str(orig_in_node.id) + " " + str(orig_out_node.id) + "\n")
        
        sys.stdout.write("\n")
        sys.stdout.flush()

import sys, getopt
if __name__ == '__main__':
    debug = False
    
    map_filename = None
    bbox_name = None
    constraint_length = 300
    max_dist = 350
    
    (opts, args) = getopt.getopt(sys.argv[1:],"f:b:c:d:h")
    
    for o,a in opts:
        if o == "-f":
            map_filename = str(a)
        elif o == "-b":
            bbox_name = str(a)
        elif o == "-c":
            constraint_length = int(a)
        elif o == "-d":
            max_dist = int(a)
        elif o == "-h":
            print "Usage: <stdin> | python OSMMatcher_run.py [-f <map_filename>] [-b <bbox_name>] [-c <constraint_length>] [-d <max_dist>] [-h]"
            exit()
    
    if (debug):
        print "map_filename: " + str(map_filename)
        print "bbox_name: " + str(bbox_name)
        print "constraint length: " + str(constraint_length)
        print "max dist: " + str(max_dist)
    
    bbox_mode = None
    
    if (bbox_name == "uic"):
        bbox_mode = 0
    elif (bbox_name == "msmls"):
        bbox_mode = 1
    
    match_osm = MatchOSM(map_filename, bbox_mode, constraint_length, max_dist)
    match_osm.process_trips(sys.stdin)
