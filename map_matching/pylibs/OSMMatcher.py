from streetmap import *
from gpsmatcher import GPSMatcher
from spatialfunclib import *
from mathfunclib import *
import time
import sys

EMISSION_SIGMA = 25.0 #50.0
EMISSION_UNKNOWN = 0.01

TRANSITION_UNKNOWN = 0.01
TRANSITION_UNKNOWN_UNKNOWN = 0.9
#TRANSITION_SELF = .5

MAX_SPEED_M_PER_S = 20.0

class OSMMatcher(GPSMatcher):
    def __init__(self, map_filename, bbox_mode=None, constraint_length=300, MAX_DIST=100):
        (hmm, self.edge_map) = self.mapdb_to_hmm(map_filename, bbox_mode)
        
        # precompute probability table
        emission_probabilities = map(lambda x: complementary_normal_distribution_cdf(x,0,EMISSION_SIGMA), 
                                     range(0,int(3.0*EMISSION_SIGMA)))
        
        def emission_probability(state, coord):
            if(state=='unknown'):
                return EMISSION_UNKNOWN
            edge = state
            projected_point = project_onto_segment(edge,coord)
            distance = haversine_distance(projected_point,coord)
            if(int(distance) >= 3 * EMISSION_SIGMA):
                return 0            
            return emission_probabilities[int(distance)]
        
        #sys.stdout.write("Initing GPS matcher... ")
        #sys.stdout.flush()
        GPSMatcher.__init__(self,hmm,emission_probability,constraint_length,MAX_DIST,priors={'unknown': 1.0})
        #sys.stdout.write("done.\n")
        #sys.stdout.flush()
    
    def map_subdivide(self, themap):
        # dictionary for mapping new edges back to their original edge
        edge_map = {} # edge_map[(new_edge_in_node_coords, new_edge_out_node_coords)] = (orig_edge_in_node, orig_edge_out_node)
        
        # storage for new nodes
        new_nodes = []
        new_node_id = max(themap.nodes.keys()) + 1
        
        # iterate through all map edges
        for in_node in themap.nodes.values():
            for out_node in list(in_node.out_nodes):
                edge_length = haversine_distance(in_node.coords(), out_node.coords())
                
                # if edge needs to be split
                if (edge_length > MAX_SPEED_M_PER_S):
                    new_node_count = int(float(edge_length) / float(MAX_SPEED_M_PER_S))
                    prev_node = in_node
                    
                    for i in range(0, new_node_count):
                        (new_node_lat, new_node_lon) = self._point_along_line(in_node.coords(), out_node.coords(), (MAX_SPEED_M_PER_S * float(i + 1)) / edge_length)
                        new_node = Node(new_node_id, new_node_lat, new_node_lon)
                        new_node_id += 1
                        
                        # store new node
                        new_nodes.append(new_node)
                        
                        # create new edge
                        prev_node.out_nodes.append(new_node)
                        new_node.in_nodes.append(prev_node)
                        
                        # store new edge mapping
                        edge_map[(prev_node.coords(), new_node.coords())] = (in_node, out_node)
                        
                        # update prev_node
                        prev_node = new_node
                    
                    # create new edge
                    prev_node.out_nodes.append(out_node)
                    out_node.in_nodes.append(prev_node)
                    
                    # store new edge mapping
                    edge_map[(prev_node.coords(), out_node.coords())] = (in_node, out_node)
                    
                    # remove old edge
                    in_node.out_nodes.remove(out_node)
                    out_node.in_nodes.remove(in_node)
                
                else:
                    #store current edge mapping
                    edge_map[(in_node.coords(), out_node.coords())] = (in_node, out_node)
        
        # if any new nodes were added
        for new_node in new_nodes:
            themap.nodes[new_node.id] = new_node
        
        return edge_map
    
    def _point_along_line(self, (a_lat, a_lon), (b_lat, b_lon), fraction_along):
        return point_along_line(a_lat, a_lon, b_lat, b_lon, fraction_along)
    
    def mapdb_to_hmm(self, map_filename, bbox_mode=None):
        themap = StreetMap()
        
        map_filename_datatype = map_filename[map_filename.rfind("."):]
        
        if (map_filename_datatype == ".pkl"):
            themap.load_pickle(map_filename)
        elif (map_filename_datatype == ".osmdb"):
            themap.load_osmdb(map_filename, bbox_mode)
        
        #sys.stdout.write("Subdividing map... ")
        #sys.stdout.flush()
        
        # subdivide the map into segments <= MAX_SPEED_M_PER_S long
        edge_map = self.map_subdivide(themap)
        
        #sys.stdout.write("into " + str(len(themap.nodes)) + " nodes.\n")
        #sys.stdout.flush()
        
        #sys.stdout.write("Creating HMM... ")
        #sys.stdout.flush()
        
        hmm = {}
        all_edges=[]
        all_edges_with_id=[]
        for node in themap.nodes.values():
            for nextnode in node.out_nodes:
                from_edge=(node.coords(), nextnode.coords())
                all_edges.append(from_edge)
                
                from_edge_with_id=((node.id, nextnode.id), node.coords(), nextnode.coords())
                all_edges_with_id.append(from_edge_with_id)
                
                next_edges=[] # list of all next hops
                for nextnextnode in nextnode.out_nodes:
                    to_edge=(nextnode.coords(),nextnextnode.coords())
                    next_edges.append(to_edge)
                
                next_edge_transition_prob = (1 - TRANSITION_UNKNOWN) / (len(next_edges) + 1)
                hmm[from_edge] = [(edge, next_edge_transition_prob) for edge in next_edges] + [(from_edge, next_edge_transition_prob), ('unknown', TRANSITION_UNKNOWN)]
                
                #hmm[from_edge]=[(edge,(1-TRANSITION_SELF-TRANSITION_UNKNOWN)/len(next_edges)) for edge in next_edges]+\
                #    [('unknown',TRANSITION_UNKNOWN),(from_edge,TRANSITION_SELF)]
        
        hmm['unknown']=[('unknown',TRANSITION_UNKNOWN_UNKNOWN)]#,(edge,(1-TRANSITION_UNKNOWN_UNKNOWN)/len(all_edges)) for edge in all_edges]
        hmm['unknown']+=[(edge,(1-TRANSITION_UNKNOWN_UNKNOWN)/len(all_edges)) for edge in all_edges]
        #hmm['unknown']=[(edge,(1-TRANSITION_UNKNOWN_UNKNOWN)/len(all_edges)) for edge in all_edges]
        
        #sys.stdout.write("done.\n")
        #sys.stdout.flush()
        
        return (hmm, edge_map)
