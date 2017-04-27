from pylibs import spatialfunclib
from location import Location
import math
import os

from streetmap import StreetMap
import random

import cPickle as pickle
from sklearn import tree

class Extrapolator:
    def __init__(self):
        random.seed(1384473217)
    
    def init_location_params(self, curr_location):
        return self.get_location_params(curr_location)
    
    def get_location_params(self, curr_location):
        return (curr_location, self._get_params(curr_location))
    
    def get_trajectory(self, (location, params), time_offsets):
        return NotImplemented
    
    def _get_params(self, curr_location):
        return {'speed': curr_location.speed, 'bearing': curr_location.bearing, 'acceleration': curr_location.acceleration, 'angular_velocity': curr_location.angular_velocity}

class ConstantLocationExtrapolator(Extrapolator):
    def get_trajectory(self, (location, params), time_offsets):
        location_trajectory = []
        
        for time_offset in time_offsets:
            location_trajectory.append(Location(location.lat, location.lon, (location.time + time_offset), location.speed, location.bearing))
        
        return location_trajectory

class ConstantVelocityExtrapolator(Extrapolator):
    def get_trajectory(self, (location, params), time_offsets):
        location_trajectory = []
        
        for time_offset in time_offsets:
            (new_location_lat, new_location_lon) = spatialfunclib.destination_point(location.lat, location.lon, params['bearing'], (params['speed'] * time_offset))
            location_trajectory.append(Location(new_location_lat, new_location_lon, (location.time + time_offset), params['speed'], params['bearing']))
        
        return location_trajectory

class ConstantAccelerationExtrapolator(Extrapolator):
    def __init__(self, max_speed=26.82): # 26.82 m/s == 60 mph
        Extrapolator.__init__(self)
        self.max_speed = max_speed
    
    def get_trajectory(self, (location, params), time_offsets):
        location_trajectory = []
        
        for time_offset in time_offsets:
            distance_traveled = 0.0
            
            if (params['acceleration'] < 0.0):
                time_to_reach_zero_velocity = ((0.0 - params['speed']) / params['acceleration'])
                
                if (time_to_reach_zero_velocity < time_offset):
                    time_offset = time_to_reach_zero_velocity
            
            elif (params['acceleration'] > 0.0):
                if (params['speed'] > self.max_speed):
                    time_to_reach_max_velocity = 0.0
                else:
                    time_to_reach_max_velocity = ((self.max_speed - params['speed']) / params['acceleration'])
                
                if (time_to_reach_max_velocity < time_offset):
                    distance_traveled += (self.max_speed * (time_offset - time_to_reach_max_velocity))
                    time_offset = time_to_reach_max_velocity
            
            distance_traveled += ((params['speed'] * time_offset) + ((params['acceleration'] * pow(time_offset, 2.0)) / 2.0))
            (new_location_lat, new_location_lon) = spatialfunclib.destination_point(location.lat, location.lon, params['bearing'], distance_traveled)
            location_trajectory.append(Location(new_location_lat, new_location_lon, (location.time + time_offset), (params['speed'] + (params['acceleration'] * time_offset)), params['bearing']))
        
        return location_trajectory

class ConstantDecelerationExtrapolator(Extrapolator):
    def get_trajectory(self, (location, params), time_offsets):
        location_trajectory = []
        
        for time_offset in time_offsets:
            if (params['acceleration'] < 0.0):
                time_to_reach_zero_velocity = ((0.0 - params['speed']) / params['acceleration'])
                
                if (time_to_reach_zero_velocity < time_offset):
                    time_offset = time_to_reach_zero_velocity
                
                distance_traveled = ((params['speed'] * time_offset) + ((params['acceleration'] * pow(time_offset, 2.0)) / 2.0))
                (new_location_lat, new_location_lon) = spatialfunclib.destination_point(location.lat, location.lon, params['bearing'], distance_traveled)
                location_trajectory.append(Location(new_location_lat, new_location_lon, (location.time + time_offset), (params['speed'] + (params['acceleration'] * time_offset)), params['bearing']))
            
            else:
                (new_location_lat, new_location_lon) = spatialfunclib.destination_point(location.lat, location.lon, params['bearing'], (params['speed'] * time_offset))
                location_trajectory.append(Location(new_location_lat, new_location_lon, (location.time + time_offset), params['speed'], params['bearing']))
        
        return location_trajectory

class MapExtrapolator(Extrapolator):
    def __init__(self, map_filename, bbox_name=None, map_object=None, step_mode=0, offset_distance=0.0):
        Extrapolator.__init__(self)
        
        if (map_filename is None):
            self.map = map_object
        
        else:
            self.map = StreetMap()
            
            map_filename_datatype = map_filename[map_filename.rfind("."):]
            
            if (map_filename_datatype == ".pkl"):
                self.map.load_pickle(map_filename)
            
            elif (map_filename_datatype == ".osmdb"):
                if (bbox_name == "uic"):
                    self.map.load_osmdb(map_filename, 0)
                elif (bbox_name == "msmls"):
                    self.map.load_osmdb(map_filename, 1)
                else:
                    self.map.load_osmdb(map_filename)
            
            else:
                print "ERROR!! Invalid map datatype: " + str(map_filename_datatype)
                exit(-1)
        
        self._step_mode = step_mode
        self._offset_distance = offset_distance
        self._constant_location_extrapolator = ConstantLocationExtrapolator()
    
    def get_trajectory(self, (location, params), time_offsets):
        location_trajectory = []
        
        time_offsets = list(set(map(lambda x: int(x), time_offsets)))
        time_offsets.sort()
        
        max_time_offset = time_offsets[-1]
        step_distance, curr_speed = self._get_step_distance(params['speed'], params['acceleration'])
        
        if ((params['map_in_node_id'] is None) or (params['map_out_node_id'] is None)):
            return self._constant_location_extrapolator.get_trajectory((location, params), time_offsets)
        
        curr_edge = (self.map.nodes[int(params['map_in_node_id'])], self.map.nodes[int(params['map_out_node_id'])])
        curr_location = self._snap_location_to_edge(location, curr_edge)
        
        # do something with previous trajectory nodes
        self._handle_prev_trajectory_nodes(curr_edge, params)
        
        time_offset_itr = 0
        
        if (time_offsets[time_offset_itr] == 0):
            location_trajectory.append(Location(curr_location[0], curr_location[1], location.time, params['speed'], self._edge_bearing(curr_edge)))
            time_offset_itr += 1
        
        for i in range(1, max_time_offset + 1, 1):
            distance_to_edge_end = self._distance(curr_location, (curr_edge[1].latitude, curr_edge[1].longitude))
            
            if (step_distance <= distance_to_edge_end):
                curr_location = self._point_along_line(curr_location, (curr_edge[1].latitude, curr_edge[1].longitude), (step_distance / (distance_to_edge_end + 0.00001)))
            
            else:
                while (step_distance > distance_to_edge_end):
                    next_edge = self._get_next_edge(curr_edge)
                    
                    if (next_edge is not None):
                        step_distance -= distance_to_edge_end
                        
                        curr_edge = next_edge
                        distance_to_edge_end = self._distance((curr_edge[0].latitude, curr_edge[0].longitude), (curr_edge[1].latitude, curr_edge[1].longitude))
                        
                        # temporary fix -- TODO for james
                        if (distance_to_edge_end == 0.0):
                            break
                    
                    else:
                        break
                
                if (step_distance <= distance_to_edge_end):
                    curr_location = self._point_along_line((curr_edge[0].latitude, curr_edge[0].longitude), (curr_edge[1].latitude, curr_edge[1].longitude), (step_distance / (distance_to_edge_end + 0.00001)))
                
                else:
                    # we couldn't find a next edge to transition onto, finish up and break
                    curr_location = (curr_edge[1].latitude, curr_edge[1].longitude)
                    curr_edge_bearing = self._edge_bearing(curr_edge)
                    
                    for time_offset in time_offsets[time_offset_itr:]:
                        location_trajectory.append(Location(curr_location[0], curr_location[1], (location.time + time_offset), 0.0, curr_edge_bearing))
                    
                    break
            
            if (time_offsets[time_offset_itr] == i):
                location_trajectory.append(Location(curr_location[0], curr_location[1], (location.time + i), curr_speed, self._edge_bearing(curr_edge)))
                time_offset_itr += 1
            
            step_distance, curr_speed = self._get_step_distance(curr_speed, params['acceleration'])
        
        return self._get_offset_trajectory(location_trajectory, self._offset_distance)
    
    def _get_step_distance(self, speed, acceleration, duration=1, max_speed=26.82): # 26.82 m/s == 60 mph
        # constant velocity
        if (self._step_mode == 0):
            step_distance = (speed * duration)
            final_speed = speed
        
        # constant acceleration/deceleration
        elif (self._step_mode == 1 or self._step_mode == 2):
            step_distance = 0.0
            
            # handle deceleration
            if (acceleration < 0.0):
                time_to_reach_zero_velocity = ((0.0 - speed) / acceleration)
                
                if (time_to_reach_zero_velocity < duration):
                    duration = time_to_reach_zero_velocity
            
            # else, handle acceleration
            elif (self._step_mode == 1 and acceleration > 0.0):
                if (speed > max_speed):
                    time_to_reach_max_velocity = 0.0
                else:
                    time_to_reach_max_velocity = ((max_speed - speed) / acceleration)
                
                if (time_to_reach_max_velocity < duration):
                    step_distance += (max_speed * (duration - time_to_reach_max_velocity))
                    duration = time_to_reach_max_velocity
            
            step_distance += ((speed * duration) + ((acceleration * pow(duration, 2.0)) / 2.0))
            final_speed = (speed + (acceleration * duration))
        
        return (step_distance, final_speed)
    
    def _get_next_edge(self, curr_edge):
        turn_nodes = list(curr_edge[1].out_nodes)
        
        if (curr_edge[0] in turn_nodes):
            turn_nodes.remove(curr_edge[0])
        
        if (len(turn_nodes) == 1):
            return (curr_edge[1], turn_nodes[0])
        else:
            return self._get_alternate_edge(curr_edge)
    
    def _get_alternate_edge(self, curr_edge):
        return None
    
    def _handle_prev_trajectory_nodes(self, curr_edge, params):
        pass
    
    def _snap_location_to_edge(self, location, edge):
        (proj_location, proj_fraction, _) = spatialfunclib.projection_onto_line(edge[0].latitude, edge[0].longitude, edge[1].latitude, edge[1].longitude, location.lat, location.lon)
        
        if (proj_fraction > 1.0):
            proj_location = (edge[1].latitude, edge[1].longitude)
        elif (proj_fraction < 0.0):
            proj_location = (edge[0].latitude, edge[0].longitude)
        
        return (proj_location[0], proj_location[1])
    
    def _get_offset_trajectory(self, original_trajectory, offset_distance=0.0):
        if (offset_distance == 0.0):
            return original_trajectory
        
        offset_trajectory = []
        for i in range(0, len(original_trajectory)):
            offset_trajectory.append(self._offset_location(original_trajectory[i], offset_distance))
        
        return offset_trajectory
    
    def _offset_location(self, location, offset_distance=0.0):
        if (offset_distance == 0.0):
            return location
        
        proj_bearing = math.fmod(location.bearing + 90.0, 360.0)
        dest_point = spatialfunclib.destination_point(location.lat, location.lon, proj_bearing, offset_distance)
        return Location(dest_point[0], dest_point[1], location.time, location.speed, location.bearing)
    
    def _edge_bearing(self, edge):
        return spatialfunclib.path_bearing(edge[0].latitude, edge[0].longitude, edge[1].latitude, edge[1].longitude)
    
    def _point_along_line(self, location1, location2, fraction_along):
        return spatialfunclib.point_along_line(location1[0], location1[1], location2[0], location2[1], fraction_along)
    
    def _distance(self, location1, location2):
        return spatialfunclib.haversine_distance(location1[0], location1[1], location2[0], location2[1])
    
    def _get_params(self, curr_location):
        return {'speed': curr_location.speed, 'bearing': curr_location.bearing, 'acceleration': curr_location.acceleration, 'angular_velocity': curr_location.angular_velocity, 'map_in_node_id': curr_location.map_in_node_id, 'map_out_node_id': curr_location.map_out_node_id}

class MapExtrapolatorStraightRoad(MapExtrapolator):
    def _get_alternate_edge(self, curr_edge):
        curr_edge_bearing = self._edge_bearing(curr_edge)
        
        min_bearing_diff = float('infinity')
        min_bearing_diff_node = None
        
        for curr_turn_node in curr_edge[1].out_nodes:
            next_edge_bearing = self._edge_bearing((curr_edge[1], curr_turn_node))
            curr_bearing_diff = spatialfunclib.bearing_difference(curr_edge_bearing, next_edge_bearing)
            
            if (curr_bearing_diff < min_bearing_diff):
                min_bearing_diff = curr_bearing_diff
                min_bearing_diff_node = curr_turn_node
        
        if (min_bearing_diff < 90.0):
            return (curr_edge[1], min_bearing_diff_node)
        else:
            return None

class MapExtrapolatorNMM(MapExtrapolator):
    def __init__(self, map_filename, turn_probs_filename, bbox_name=None, map_object=None, step_mode=0, offset_distance=0.0, prev_trajectory_node_limit=2):
        MapExtrapolator.__init__(self, map_filename, bbox_name, map_object, step_mode, offset_distance)
        self.prev_trajectory_node_limit = prev_trajectory_node_limit
        self.prev_trajectory_nodes = None
        
        self.map.turn_probs = self._load_turn_probs(turn_probs_filename)
    
    def _load_turn_probs(self, turn_probs_filename):
        turn_probs = {} # turn_probs[(prev_node, ..., prev_node, turn_node)] = turn_probability
        
        turn_probs_file = open(turn_probs_filename, 'r')
        
        for turn_prob_record in turn_probs_file:
            turn_prob_record_components = turn_prob_record.strip("\n").split(" ")
            
            if (len(turn_prob_record_components) < (self.prev_trajectory_node_limit + 3)):
                curr_prev_nodes = turn_prob_record_components[:len(turn_prob_record_components) - 1]
                
                if (all(map(lambda x: int(x) in self.map.nodes, curr_prev_nodes)) == True):
                    curr_prev_map_nodes = tuple(map(lambda x: self.map.nodes[int(x)], curr_prev_nodes))
                    curr_turn_prob = float(turn_prob_record_components[-1])
                    
                    turn_probs[curr_prev_map_nodes] = curr_turn_prob
        
        turn_probs_file.close()
        
        return turn_probs
    
    def _get_next_edge(self, curr_edge):
        next_edge = None
        
        while (len(self.prev_trajectory_nodes) > self.prev_trajectory_node_limit):
            self.prev_trajectory_nodes.pop(0)
        
        # prevent U-turns
        turn_nodes = list(curr_edge[1].out_nodes)
        
        if (curr_edge[0] in turn_nodes):
            turn_nodes.remove(curr_edge[0])
        
        if (len(turn_nodes) > 0):
            max_turn_prob = 0.0
            max_turn_prob_nodes = None
            
            for curr_turn_node in turn_nodes:
                curr_turn_probs_tuple = tuple(self.prev_trajectory_nodes + [curr_turn_node])
                
                while ((curr_turn_probs_tuple not in self.map.turn_probs) and (len(curr_turn_probs_tuple) > 2)):
                    curr_turn_probs_tuple = curr_turn_probs_tuple[1:]
                
                if (len(curr_turn_probs_tuple) > 2):
                    curr_turn_prob = self.map.turn_probs[curr_turn_probs_tuple]
                    
                    if (curr_turn_prob > max_turn_prob):
                        max_turn_prob = curr_turn_prob
                        max_turn_prob_nodes = [curr_turn_node]
                    
                    elif ((curr_turn_prob > 0.0) and (curr_turn_prob == max_turn_prob)):
                        max_turn_prob_nodes.append(curr_turn_node)
            
            if (max_turn_prob_nodes is not None):
                next_edge = (curr_edge[1], max_turn_prob_nodes[random.randint(0, len(max_turn_prob_nodes) - 1)])
            else:
                next_edge = self._get_alternate_edge(curr_edge)
        
        if (next_edge is not None):
            self.prev_trajectory_nodes.append(next_edge[1])
        else:
            self.prev_trajectory_nodes.append(None)
        
        return next_edge
    
    def _handle_prev_trajectory_nodes(self, curr_edge, params):
        if (params['map_prev_node_ids'] is not None):
            self.prev_trajectory_nodes = map(lambda x: self.map.nodes[int(x)], params['map_prev_node_ids']) + [curr_edge[1]]
        else:
            self.prev_trajectory_nodes = [curr_edge[0], curr_edge[1]]
    
    def _get_params(self, curr_location):
        return {'speed': curr_location.speed, 'bearing': curr_location.bearing, 'acceleration': curr_location.acceleration, 'angular_velocity': curr_location.angular_velocity, 'map_in_node_id': curr_location.map_in_node_id, 'map_out_node_id': curr_location.map_out_node_id, 'map_prev_node_ids': curr_location.map_prev_node_ids}

class MapExtrapolatorNMMStraightRoad(MapExtrapolatorNMM):
    def _get_alternate_edge(self, curr_edge):
        curr_edge_bearing = self._edge_bearing(curr_edge)
        
        min_bearing_diff = float('infinity')
        min_bearing_diff_node = None
        
        for curr_turn_node in curr_edge[1].out_nodes:
            next_edge_bearing = self._edge_bearing((curr_edge[1], curr_turn_node))
            curr_bearing_diff = spatialfunclib.bearing_difference(curr_edge_bearing, next_edge_bearing)
            
            if (curr_bearing_diff < min_bearing_diff):
                min_bearing_diff = curr_bearing_diff
                min_bearing_diff_node = curr_turn_node
        
        if (min_bearing_diff < 90.0):
            return (curr_edge[1], min_bearing_diff_node)
        else:
            return None

class UnifiedExtrapolator(Extrapolator):
    def __init__(self, map_filename, map_generic_turn_probs_filename, map_trace_turn_probs_filename, classifier_path, mode="e", max_error_target=None):
        Extrapolator.__init__(self)
        self.prev_location_params = None
        self.prev_location_params_time_limit = 15.0
        self.classifier, self.classifier_thresholds = self._get_classifier(classifier_path, mode)
        self.mode = mode
        self.max_error_target = max_error_target
        
        self.extrapolators = {}
        self.extrapolators[0] = ConstantLocationExtrapolator()
        self.extrapolators[1] = ConstantVelocityExtrapolator()
        self.extrapolators[2] = ConstantAccelerationExtrapolator()
        self.extrapolators[3] = ConstantDecelerationExtrapolator()
        
        if (map_filename is not None):
            self.map = self._get_street_map(map_filename)
            
            # stop at intersection
            self.extrapolators[4] = MapExtrapolator(None, None, self.map)
            
            # travel along in straight direction
            self.extrapolators[5] = MapExtrapolatorStraightRoad(None, None, self.map)
            
            if (map_generic_turn_probs_filename is not None):
                # generic turn proportions
                self.extrapolators[6] = MapExtrapolatorNMM(None, map_generic_turn_probs_filename, None, self.map)
                
                # generic turn proportions w/straight road
                self.extrapolators[7] = MapExtrapolatorNMMStraightRoad(None, map_generic_turn_probs_filename, None, self.map)
            
            # trace-based turn proportions
            self.extrapolators[8] = MapExtrapolatorNMM(None, map_trace_turn_probs_filename, None, self.map)
            
            # trace-based turn proportions w/straight road
            self.extrapolators[9] = MapExtrapolatorNMMStraightRoad(None, map_trace_turn_probs_filename, None, self.map)
            
            # trace-based turn proportions (10th-order Markov Model)
            self.extrapolators[10] = MapExtrapolatorNMM(None, map_trace_turn_probs_filename, None, self.map, prev_trajectory_node_limit=11)
            
            # trace-based turn proportions w/straight road (10th-order Markov Model)
            self.extrapolators[11] = MapExtrapolatorNMMStraightRoad(None, map_trace_turn_probs_filename, None, self.map, prev_trajectory_node_limit=11)
    
    def _get_classifier(self, classifier_path, mode):
        classifier = None
        
        if (mode == "e" or mode == "dx"):
            classifier = {}
            
            decision_tree_filenames = filter(lambda x: x.startswith("oracle_tree_" + mode) and x.endswith(".pkl"), os.listdir(classifier_path))
            
            if (len(decision_tree_filenames) != 14):
                print "ERROR!! Not exactly 14 decision trees found! count: " + str(len(decision_tree_filenames))
                exit()
            
            for decision_tree_filename in decision_tree_filenames:
                threshold = decision_tree_filename.split("_")[2]
                pickle_extension_index = threshold.rfind(".pkl")
                
                if (pickle_extension_index != -1):
                    threshold = threshold[:pickle_extension_index]
                
                if (mode == "e" and threshold[0] == mode):
                    threshold = int(threshold[1:])
                elif (mode == "dx" and threshold[:2] == mode):
                    threshold = int(threshold[2:])
                else:
                    print "ERROR!! Reading wrong mode file! file: " + str(threshold[0]) + ", run mode: " + str(mode)
                    exit()
                
                decision_tree_file = open(classifier_path + "/" + decision_tree_filename, 'r')
                classifier[threshold] = pickle.load(decision_tree_file)
                decision_tree_file.close()
        
        elif (mode == "table"):
            classifier = {}
            
            table_filename = filter(lambda x: x.startswith("table_based_extrapolator_values_") and x.endswith(".txt"), os.listdir(classifier_path))
            
            if (len(table_filename) != 1):
                print "ERROR!! Not exactly 1 table file! count: " + str(len(table_filename))
                exit()
            
            table_file = open(classifier_path + "/" + table_filename[0], 'r')
            
            for table_data in table_file:
                table_data_components = table_data.strip("\n").split(" ")
                
                curr_threshold = int(table_data_components[0])
                curr_extrapolator_mode = int(table_data_components[1])
                
                classifier[curr_threshold] = curr_extrapolator_mode
            
            table_file.close()
        
        classifier_thresholds = classifier.keys()
        classifier_thresholds.sort()
        
        if (mode == "dx"):
            classifier_thresholds.insert(0, -1)
        
        return classifier, classifier_thresholds
    
    def _get_street_map(self, map_filename):
        street_map = StreetMap()
        street_map.load_pickle(map_filename)
        return street_map
    
    def init_location_params(self, curr_location):
        self.prev_location_params = []
        return self.get_location_params(curr_location)
    
    def get_location_params(self, curr_location):
        if (self.mode == "table"):
            return (curr_location, self._get_params(curr_location))
        
        else:
            while ((len(self.prev_location_params) > 0) and ((curr_location.time - self.prev_location_params[0][0].time) > self.prev_location_params_time_limit)):
                self.prev_location_params.pop(0)
            
            curr_location_params = self._get_best_location_params(curr_location, map(lambda x: x[0], self.prev_location_params))
            
            self.prev_location_params.append([curr_location, curr_location_params])
            
            return tuple(self.prev_location_params[-1])
    
    def get_trajectory(self, (location, params), time_offsets, max_error_threshold=None):
        # for extrapolator testbenching
        if (max_error_threshold is None):
            max_error_threshold = self.max_error_target
        
        if (self.mode == "e" or self.mode == "table"):
            max_error_threshold = min(self.classifier_thresholds, key=lambda x: abs(x - max_error_threshold))
        
        if (self.mode == "e"):
            predicted_extrapolator_mode = self.classifier[max_error_threshold].predict(params['feature_vector'])[0]
            return self.extrapolators[predicted_extrapolator_mode].get_trajectory((location, params), time_offsets)
        
        elif (self.mode == "dx"):
            location_trajectory = []
            
            for i in range(1, len(self.classifier_thresholds)):
                curr_time_offsets = filter(lambda x: x > self.classifier_thresholds[i - 1] and x <= self.classifier_thresholds[i], time_offsets)
                
                if (len(curr_time_offsets) > 0):
                    predicted_extrapolator_mode = self.classifier[self.classifier_thresholds[i]].predict(params['feature_vector'])[0]
                    location_trajectory.extend(self.extrapolators[predicted_extrapolator_mode].get_trajectory((location, params), curr_time_offsets))
            
            extra_time_offsets = filter(lambda x: x > self.classifier_thresholds[-1], time_offsets)
            
            if (len(extra_time_offsets) > 0):
                predicted_extrapolator_mode = self.classifier[self.classifier_thresholds[-1]].predict(params['feature_vector'])[0]
                location_trajectory.extend(self.extrapolators[predicted_extrapolator_mode].get_trajectory((location, params), extra_time_offsets))
            
            return location_trajectory
        
        elif (self.mode == "table"):
            predicted_extrapolator_mode = self.classifier[max_error_threshold]
            return self.extrapolators[predicted_extrapolator_mode].get_trajectory((location, params), time_offsets)
    
    def _get_best_location_params(self, curr_location, prev_locations):
        best_location_params = self._get_params(curr_location)
        
        curr_feature_vector = self._get_feature_vector(curr_location, prev_locations)
        best_location_params['feature_vector'] = curr_feature_vector
        
        return best_location_params
    
    def _get_feature_vector(self, curr_location, prev_locations):
        num_prev_locations = len(prev_locations)
        
        if ((curr_location.map_in_node_id is not None) and (curr_location.map_out_node_id is not None)):
            curr_location_map_edge = (self.map.nodes[int(curr_location.map_in_node_id)], self.map.nodes[int(curr_location.map_out_node_id)])
            curr_location_map_location = self._snap_location_to_edge(curr_location, curr_location_map_edge)
            curr_location_distance_to_map_location = spatialfunclib.haversine_distance(curr_location.lat, curr_location.lon, curr_location_map_location[0], curr_location_map_location[1])
        else:
            curr_location_distance_to_map_location = -1.0
        
        if (num_prev_locations > 0):
            prev_locations_mean_speed = float(sum(map(lambda x: x.speed, prev_locations))) / num_prev_locations
            prev_locations_mean_acceleration = float(sum(map(lambda x: x.acceleration, prev_locations))) / num_prev_locations
            
            curr_location_mean_speed_delta = curr_location.speed - prev_locations_mean_speed
            curr_location_mean_acceleration_delta = curr_location.acceleration - prev_locations_mean_acceleration
            
            prev_locations_mean_latitude = float(sum(map(lambda x: x.lat, prev_locations))) / num_prev_locations
            prev_locations_mean_longitude = float(sum(map(lambda x: x.lon, prev_locations))) / num_prev_locations
            
            curr_location_distance_to_mean_center = spatialfunclib.haversine_distance(curr_location.lat, curr_location.lon, prev_locations_mean_latitude, prev_locations_mean_longitude)
            curr_location_distance_to_prev_location = spatialfunclib.haversine_distance(curr_location.lat, curr_location.lon, prev_locations[-1].lat, prev_locations[-1].lon)
        else:
            prev_locations_mean_speed = -1.0
            curr_location_mean_speed_delta = -1.0
            prev_locations_mean_acceleration = -1.0
            curr_location_mean_acceleration_delta = -1.0
            curr_location_distance_to_mean_center = -1.0
            curr_location_distance_to_prev_location = -1.0
        
        return [curr_location_distance_to_map_location, prev_locations_mean_speed, curr_location.speed, curr_location_mean_speed_delta, prev_locations_mean_acceleration, curr_location.acceleration, curr_location_mean_acceleration_delta, curr_location_distance_to_mean_center, curr_location_distance_to_prev_location]
    
    def _snap_location_to_edge(self, location, edge):
        (proj_location, proj_fraction, _) = spatialfunclib.projection_onto_line(edge[0].latitude, edge[0].longitude, edge[1].latitude, edge[1].longitude, location.lat, location.lon)
        
        if (proj_fraction > 1.0):
            proj_location = (edge[1].latitude, edge[1].longitude)
        elif (proj_fraction < 0.0):
            proj_location = (edge[0].latitude, edge[0].longitude)
        
        return (proj_location[0], proj_location[1])
    
    def _get_params(self, curr_location):
        return {'speed': curr_location.speed, 'bearing': curr_location.bearing, 'acceleration': curr_location.acceleration, 'angular_velocity': curr_location.angular_velocity, 'map_in_node_id': curr_location.map_in_node_id, 'map_out_node_id': curr_location.map_out_node_id, 'map_prev_node_ids': curr_location.map_prev_node_ids}
