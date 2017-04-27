class Location:
    def __init__(self, lat=None, lon=None, time=None, speed=None, bearing=None):
        self.lat = lat
        self.lon = lon
        self.time = time
        self.speed = speed
        self.bearing = bearing
    
    def load_raw_location(self, raw_location):
        raw_location_components = raw_location.strip("\n").split(" ")
        
        # we are guaranteed to have these parameters
        self.lat = float(raw_location_components[0])
        self.lon = float(raw_location_components[1])
        self.time = float(raw_location_components[2])
        
        # we are not guaranteed to have these parameters
        if (raw_location_components[3] != "None"): self.speed = float(raw_location_components[3])
        if (raw_location_components[4] != "None"): self.bearing = float(raw_location_components[4])
    
    def __str__(self):
        return str(self.lat) + " " + str(self.lon) + " " + str(self.time) + " " + str(self.speed) + " " + str(self.bearing)

class LocationWithEstimatedValues(Location):
    def __init__(self, lat=None, lon=None, time=None, speed=None, bearing=None, acceleration=None, angular_velocity=None):
        Location.__init__(self, lat, lon, time, speed, bearing)
        self.acceleration = acceleration
        self.angular_velocity = angular_velocity
    
    def load_raw_location(self, raw_location):
        Location.load_raw_location(self, raw_location)
        
        raw_location_components = raw_location.strip("\n").split(" ")
        if (raw_location_components[5] != "None"): self.acceleration = float(raw_location_components[5])
        if (raw_location_components[6] != "None"): self.angular_velocity = float(raw_location_components[6])
    
    def __str__(self):
        return Location.__str__(self) + " " + str(self.acceleration) + " " + str(self.angular_velocity)

class MapMatchedLocationWithEstimatedValues(LocationWithEstimatedValues):
    def __init__(self, lat=None, lon=None, time=None, speed=None, bearing=None, acceleration=None, angular_velocity=None, map_in_node_id=None, map_out_node_id=None, map_prev_node_ids=None):
        LocationWithEstimatedValues.__init__(self, lat, lon, time, speed, bearing, acceleration, angular_velocity)
        self.map_in_node_id = map_in_node_id
        self.map_out_node_id = map_out_node_id
        self.map_prev_node_ids = map_prev_node_ids
    
    def load_raw_location(self, raw_location):
        LocationWithEstimatedValues.load_raw_location(self, raw_location)
        
        raw_location_components = raw_location.strip("\n").split(" ")
        if (raw_location_components[7] != "None"): self.map_in_node_id = str(raw_location_components[7])
        if (raw_location_components[8] != "None"): self.map_out_node_id = str(raw_location_components[8])
        if (raw_location_components[9] != "None"): self.map_prev_node_ids = str(raw_location_components[9]).split(",")
    
    def __str__(self):
        if (self.map_prev_node_ids is None):
            return LocationWithEstimatedValues.__str__(self) + " " + str(self.map_in_node_id) + " " + str(self.map_out_node_id) + " " + str(self.map_prev_node_ids)
        else:
            return LocationWithEstimatedValues.__str__(self) + " " + str(self.map_in_node_id) + " " + str(self.map_out_node_id) + " " + str(",".join(self.map_prev_node_ids))
