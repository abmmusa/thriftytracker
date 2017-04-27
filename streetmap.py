#
# Class to create and store a street map.
# Author: James P. Biagioni (jbiagi1@uic.edu)
# Company: University of Illinois at Chicago
# Created: 6/6/11
#

import sqlite3
from pylibs import spatialfunclib
import cPickle as pickle

debug = False

class Node:
    def __init__(self, id, latitude, longitude):
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.in_nodes = []
        self.out_nodes = []
    
    def coords(self):
        return (self.latitude, self.longitude)

class StreetMap:
    def __init__(self):
        self.nodes = {} # indexed by node id
        
        self._highway_tag_value = {} # indexed by (in_node, out_node)
        self._edge_count = None
    
    def _get_node(self, node_id):
        return self.nodes[int(node_id)]
    
    def load_pickle(self, pickle_filename):
        pickle_file = open(pickle_filename, 'r')
        pickle_map = pickle.load(pickle_file)
        pickle_file.close()
        
        self.nodes = pickle_map.nodes
        
        for node_id in self.nodes:
            self.nodes[node_id].in_nodes = map(lambda x: self.nodes[x], self.nodes[node_id].in_nodes)
            self.nodes[node_id].out_nodes = map(lambda x: self.nodes[x], self.nodes[node_id].out_nodes)
        
        self._highway_tag_value = {}
        for (in_node_id, out_node_id) in pickle_map._highway_tag_value:
            self._highway_tag_value[(self.nodes[in_node_id], self.nodes[out_node_id])] = pickle_map._highway_tag_value[(in_node_id, out_node_id)]
        
        self._edge_count = pickle_map._edge_count
    
    def load_osmdb(self, osmdb_filename, bbox_mode=None):
        
        # connect to OSMDB
        conn = sqlite3.connect(osmdb_filename)
        
        # grab cursor
        cur = conn.cursor()
        
        # output that we are loading nodes
        if (debug):
            sys.stdout.write("\nLoading nodes... ")
            sys.stdout.flush()
        
        # execute query on nodes table
        cur.execute("select id, lat, lon from nodes")
        query_result = cur.fetchall()
        
        # iterate through all query results
        for id, lat, lon in query_result:
            
            # create and store node in nodes dictionary
            self.nodes[int(id)] = Node(int(id), float(lat), float(lon))
        
        if (debug):
            print "done."
        
        # output that we are loading edges
        if (debug):
            sys.stdout.write("Loading edges... ")
            sys.stdout.flush()
        
        # execute query on ways table
        cur.execute("select id, tags, nds from ways")
        query_result = cur.fetchall()
        
        # storage for nodes used in valid edges
        valid_edge_nodes = {} # indexed by node id
        
        # iterate through all query results
        for id, tags, nodes in query_result:
            
            # grab tags associated with current way
            way_tags_dict = eval(tags)
            
            # if current way is a valid highway
            if ('highway' in way_tags_dict and self._valid_highway_edge(way_tags_dict['highway'])):
                
                # grab all node ids that compose this way
                way_node_ids_list = eval(nodes)
                
                # grab all nodes that compose this way
                way_nodes_list = map(lambda x: self.nodes[int(x)], way_node_ids_list) #map(self._get_node, way_node_ids_list)
                
                # iterate through list of way nodes
                for i in range(1, len(way_nodes_list)):
                    
                    # grab in_node from nodes dictionary
                    in_node = way_nodes_list[i - 1]
                    
                    # grab out_node from nodes dictionary
                    out_node = way_nodes_list[i]
                    
                    # store highway tag value
                    self._highway_tag_value[(in_node, out_node)] = way_tags_dict['highway']
                    
                    # add nodes to valid edges nodes dictionary
                    valid_edge_nodes[int(in_node.id)] = in_node
                    valid_edge_nodes[int(out_node.id)] = out_node
                    
                    # store out_node in in_node's out_nodes list
                    in_node.out_nodes.append(out_node)
                    
                    # store in_node in out_node's in_nodes list
                    out_node.in_nodes.append(in_node)
                
                # if way is bidirectional
                if (('oneway' not in way_tags_dict) or (way_tags_dict['oneway'].lower() == "no") or (way_tags_dict['oneway'].lower() == "false") or (way_tags_dict['oneway'].lower() == "0") or (way_tags_dict['oneway'].lower() == "reversible")):
                    
                    # reverse order of way nodes
                    way_nodes_list.reverse()
                    
                    # iterate through list of reversed way nodes
                    for i in range(1, len(way_nodes_list)):
                        
                        # grab in_node from nodes dictionary
                        in_node = way_nodes_list[i - 1]
                        
                        # grab out_node from nodes dictionary
                        out_node = way_nodes_list[i]
                        
                        # store highway tag value
                        self._highway_tag_value[(in_node, out_node)] = way_tags_dict['highway']
                        
                        # add nodes to valid edges nodes dictionary
                        valid_edge_nodes[int(in_node.id)] = in_node
                        valid_edge_nodes[int(out_node.id)] = out_node
                        
                        # store out_node in in_node's out_nodes list
                        in_node.out_nodes.append(out_node)
                        
                        # store in_node in out_node's in_nodes list
                        out_node.in_nodes.append(in_node)
        
        if (debug):
            print "done."
        
        # close connection to OSMDB
        conn.close()
        
        # replace all nodes dictionary with valid edge nodes dictionary
        self.nodes = valid_edge_nodes
        
        # output that we are collapsing in/out-node lists
        if (debug):
            sys.stdout.write("Collapsing in/out-node lists... ")
            sys.stdout.flush()
        
        # initialize edge count
        self._edge_count = 0
        
        # iterate through all nodes
        for curr_node in self.nodes.values():
            
            # create unique lists of in/out-nodes
            curr_node.in_nodes = list(set(curr_node.in_nodes))
            curr_node.out_nodes = list(set(curr_node.out_nodes))
            
            # increment edge count
            self._edge_count += len(curr_node.out_nodes)
        
        if (debug):
            print "done."
        
        # output that we are remapping node ids
        if (debug):
            sys.stdout.write("Remapping node ids... ")
            sys.stdout.flush()
        
        # create storage for remapping node ids
        remapped_id_nodes = {}
        
        # storage for new node ids
        new_node_id = 1
        
        # iterate through all nodes
        for curr_node in self.nodes.values():
            
            # remap current node id
            curr_node.id = new_node_id
            
            # increment new node id
            new_node_id += 1
            
            # store node with remapped id
            remapped_id_nodes[int(curr_node.id)] = curr_node
        
        # replace all nodes dictionary with remapped node ids dictionary
        self.nodes = remapped_id_nodes
        
        if (debug):
            print "done."
        
        # if we are applying a bounding box
        if (bbox_mode is not None):
            
            # apply bounding box to map
            (self.nodes, self._edge_count) = self._apply_bounding_box(self.nodes, bbox_mode)
        
        # output map statistics
        if (debug):
            print "Map has " + str(len(self.nodes)) + " nodes, " + str(self._edge_count) + " edges."
    
    def _apply_bounding_box(self, nodes, bbox_mode):
        
        # output that we are applying a bounding box
        if (debug):
            sys.stdout.write("Applying bounding box to map... ")
            sys.stdout.flush()
        
        # storage for bounding boxed nodes
        bounded_nodes = {}
        
        # iterate through all edges
        for in_node in nodes.values():
            for out_node in in_node.out_nodes:
                
                # if at least one end of the edge is within the bounding box
                if (self._within_bounding_box(in_node, bbox_mode) or self._within_bounding_box(out_node, bbox_mode)):
                    
                    # store edge nodes
                    bounded_nodes[int(in_node.id)] = in_node
                    bounded_nodes[int(out_node.id)] = out_node
        
        # initialize edge count
        edge_count = 0
        
        # iterate through all nodes
        for curr_node in bounded_nodes.values():
            
            # create storage for valid in/out-nodes
            in_nodes = []
            out_nodes = []
            
            # iterate through all in-nodes
            for in_node in curr_node.in_nodes:
                if (in_node.id in bounded_nodes):
                    in_nodes.append(in_node)
            
            # iterate through all out-nodes
            for out_node in curr_node.out_nodes:
                if (out_node.id in bounded_nodes):
                    out_nodes.append(out_node)
            
            # update in/out-node lists
            curr_node.in_nodes = in_nodes
            curr_node.out_nodes = out_nodes
            
            # increment edge count
            edge_count += len(out_nodes)
        
        if (debug):
            print "done."
        
        # return bounded nodes and edge count
        return (bounded_nodes, edge_count)
    
    def _within_bounding_box(self, node, bbox_mode):
        
        if (bbox_mode == 0):
            return self._uic_bounding_box(node)
        
        elif (bbox_mode == 1):
            return self._msmls_bounding_box(node)
        
        else:
            return True
    
    def _uic_bounding_box(self, node):
        
        # UIC traces bounding box (+300 meter margin)
        if ((node.latitude >= 41.860037 and node.latitude <= 41.885986) and 
            (node.longitude >= -87.689186 and node.longitude <= -87.637343)):
            
            return True
        else:
            return False
    
    def _msmls_bounding_box(self, node):
        
        # MSMLS traces bounding box (+300 meter margin)
        if ((node.latitude >= 46.640655 and node.latitude <= 48.616490) and 
            (node.longitude >= -123.152757 and node.longitude <= -121.438314)):
            
            return True
        else:
            return False
    
    def _valid_highway_edge(self, highway_tag_value):
        if ((highway_tag_value == 'motorway') or 
            (highway_tag_value == 'motorway_link') or 
            (highway_tag_value == 'trunk') or 
            (highway_tag_value == 'trunk_link') or 
            (highway_tag_value == 'primary') or 
            (highway_tag_value == 'primary_link') or 
            (highway_tag_value == 'secondary') or 
            (highway_tag_value == 'secondary_link') or 
            (highway_tag_value == 'tertiary') or 
            (highway_tag_value == 'tertiary_link') or 
            (highway_tag_value == 'residential') or 
            (highway_tag_value == 'service') or 
            (highway_tag_value == 'unclassified')):
            
            return True
        else:
            return False
    
    def _highway_edge_speed_limit(self, highway_tag_value):
        conversion_factor = 0.44704 # mph -> m/s
        
        if (highway_tag_value == 'motorway'):
            return (65.0 * conversion_factor)
        
        elif (highway_tag_value == 'motorway_link'):
            return (55.0 * conversion_factor)
        
        elif (highway_tag_value == 'trunk'):
            return (55.0 * conversion_factor)
        
        elif (highway_tag_value == 'trunk_link'):
            return (45.0 * conversion_factor)
        
        elif (highway_tag_value == 'primary'):
            return (50.0 * conversion_factor)
        
        elif (highway_tag_value == 'primary_link'):
            return (40.0 * conversion_factor)
        
        elif (highway_tag_value == 'secondary'):
            return (45.0 * conversion_factor)
        
        elif (highway_tag_value == 'secondary_link'):
            return (35.0 * conversion_factor)
        
        elif (highway_tag_value == 'tertiary'):
            return (35.0 * conversion_factor)
        
        elif (highway_tag_value == 'tertiary_link'):
            return (25.0 * conversion_factor)
        
        elif (highway_tag_value == 'residential'):
            return (25.0 * conversion_factor)
        
        elif (highway_tag_value == 'service'):
            return (15.0 * conversion_factor)
        
        elif (highway_tag_value == 'unclassified'):
            return (15.0 * conversion_factor)
        
        else:
            print "ERROR!! invalid highway tag value: " + str(highway_tag_value)
            exit(-1)
    
    def write_map_to_dimacs_file(self, map_filename="map_dimacs"):
        
        # output that we are starting the writing process
        sys.stdout.write("\nWriting map to DIMACS format file... ")
        sys.stdout.flush()
        
        # open map graph file
        map_graph_file = open(map_filename + ".gr", 'w')
        
        # write header info
        map_graph_file.write("c DIMACS graph format map\nc\n")
        
        # write out map statistics
        map_graph_file.write("p sp " + str(len(self.nodes)) + " " + str(self._edge_count) + "\nc\n")
        
        # iterate through all map edges
        for in_node in self.nodes.values():
            for out_node in in_node.out_nodes:
                
                # compute length of current edge
                curr_edge_length = spatialfunclib.haversine_distance(in_node.latitude, in_node.longitude, out_node.latitude, out_node.longitude)
                
                # compute time to traverse edge
                curr_edge_traversal_time = (curr_edge_length / self._highway_edge_speed_limit(self._highway_tag_value[(in_node, out_node)]))
                
                # sanity check traversal time
                if (curr_edge_traversal_time < 1.0):
                    curr_edge_traversal_time = 1.0
                
                # output current edge to file
                map_graph_file.write("a " + str(in_node.id) + " " + str(out_node.id) + " " + str(int(round(curr_edge_traversal_time))) + "\n")
        
        # close map graph file
        map_graph_file.close()
        
        # storage for intersection nodes
        intersection_nodes = {} # indexed by Node
        
        # iterate through all map edges
        for in_node in self.nodes.values():
            for out_node in in_node.out_nodes:
                
                # compute number of turn nodes from this edge
                turn_nodes_count = len(out_node.out_nodes)
                
                # subtract any u-turn nodes
                if (in_node in out_node.out_nodes):
                    turn_nodes_count -= 1
                
                # store node classification
                if (turn_nodes_count > 1):
                    intersection_nodes[out_node] = True
        
        # open node class file
        node_class_file = open(map_filename + ".cl", 'w')
        
        # iterate through all nodes
        for curr_node in self.nodes.values():
            
            # output node id to file
            node_class_file.write(str(curr_node.id) + " " + str(curr_node.latitude) + " " + str(curr_node.longitude) + " ")
            
            # if current node is an intersection
            if (curr_node in intersection_nodes):
                
                # output intersection node classification to file
                node_class_file.write("intersection_node\n")
            
            else:
                # output regular node classification to file
                node_class_file.write("regular_node\n")
        
        # close node class file
        node_class_file.close()
        
        print "done."
    
    def write_map_to_file(self, map_filename="map"):
        
        # output that we are starting the writing process
        sys.stdout.write("\nWriting map to file... ")
        sys.stdout.flush()
        
        # open map file
        map_file = open(map_filename + ".txt", 'w')
        
        # iterate through all map edges
        for in_node in self.nodes.values():
            for out_node in in_node.out_nodes:
                
                # output current edge to file
                map_file.write(str(in_node.latitude) + "," + str(in_node.longitude) + "\n")
                map_file.write(str(out_node.latitude) + "," + str(out_node.longitude) + "\n\n")
        
        # close map file
        map_file.close()
        
        print "done."
    
    def write_map_to_pickle_file(self, map_filename="map_pickle.pkl"):
        # flatten node in/out lists to ids (b/c can't pickle recursive data structures)
        for node_id in self.nodes:
            self.nodes[node_id].in_nodes = map(lambda x: x.id, self.nodes[node_id].in_nodes)
            self.nodes[node_id].out_nodes = map(lambda x: x.id, self.nodes[node_id].out_nodes)
        
        orig_highway_tag_value = self._highway_tag_value
        flat_highway_tag_value = {}
        
        for (in_node, out_node) in self._highway_tag_value:
            if ((in_node.id in self.nodes) and (out_node.id in self.nodes)):
                flat_highway_tag_value[(in_node.id, out_node.id)] = self._highway_tag_value[(in_node, out_node)]
        
        self._highway_tag_value = flat_highway_tag_value
        
        pickle_file = open(map_filename, 'w')
        pickle.dump(self, pickle_file)
        pickle_file.close()
        
        # un-flatten node in/out lists
        for node_id in self.nodes:
            self.nodes[node_id].in_nodes = map(lambda x: self.nodes[x], self.nodes[node_id].in_nodes)
            self.nodes[node_id].out_nodes = map(lambda x: self.nodes[x], self.nodes[node_id].out_nodes)
        
        self._highway_tag_value = orig_highway_tag_value
    
    def write_map_to_nodes_edges_files(self, map_nodes_filename="map_nodes.txt", map_edges_filename="map_edges.txt"):
        map_edges = []
        
        map_nodes_file = open(map_nodes_filename, 'w')
        
        for curr_node in self.nodes.values():
            map_nodes_file.write(str(curr_node.id) + " " + str(curr_node.latitude) + " " + str(curr_node.longitude) + "\n")
            
            for out_node in curr_node.out_nodes:
                map_edges.append((curr_node.id, out_node.id))
        
        map_nodes_file.close()
        map_edges_file = open(map_edges_filename, 'w')
        
        for curr_edge in map_edges:
            map_edges_file.write(str(curr_edge[0]) + " " + str(curr_edge[1]) + "\n")
        
        map_edges_file.close()

import sys
import time
if __name__ == '__main__':
    usage = "usage: python streetmap.py (osmdb) db_filename output_filename"
    
    if len(sys.argv) != 4:
        print usage
        exit()
    
    start_time = time.time()
    db_type = sys.argv[1]
    db_filename = sys.argv[2]
    output_filename = sys.argv[3]
    
    m = StreetMap()
    
    if (db_type == "osmdb"):
        m.load_osmdb(db_filename)
        m.write_map_to_dimacs_file(str(output_filename))
        m.write_map_to_file(str(output_filename))
    
    else:
        print "Error! '" + str(db_type) + "' is an unknown database type"
    
    print "\nMap operations complete (in " + str(time.time() - start_time) + " seconds).\n"
