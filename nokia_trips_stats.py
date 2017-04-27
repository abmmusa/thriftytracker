import sys

curr_trip_time_deltas = []
curr_trip_distance_deltas = []
curr_trip_speed_deltas = []
curr_trip_acceleration_deltas = []
curr_trip_bearing_deltas = []

prev_provider_id = None
prev_probe_id = None
prev_trip_id = None

for trip_sample in sys.stdin:
    curr_provider_id, curr_probe_id, curr_trip_id, time_delta, distance_delta, speed_delta, acceleration_delta, bearing_delta = trip_sample.strip("\n").split(" ")
    
    time_delta = int(time_delta)
    distance_delta = float(distance_delta)
    speed_delta = float(speed_delta)
    acceleration_delta = float(acceleration_delta)
    bearing_delta = float(bearing_delta)
    
    if ((prev_provider_id != None) and (prev_probe_id != None) and (prev_trip_id != None) and 
        ((curr_provider_id != prev_provider_id) or (curr_probe_id != prev_probe_id) or (curr_trip_id != prev_trip_id))):
        
        curr_trip_time_deltas.sort()
        curr_trip_distance_deltas.sort()
        curr_trip_speed_deltas.sort()
        curr_trip_acceleration_deltas.sort()
        curr_trip_bearing_deltas.sort()
        
        sys.stdout.write(str(prev_provider_id) + " " + 
                         str(prev_probe_id) + " " + 
                         str(prev_trip_id) + " " + 
                         str(curr_trip_time_deltas[len(curr_trip_time_deltas) / 2]) + " " + str(sum(curr_trip_time_deltas) / len(curr_trip_time_deltas)) + " " + 
                         str(curr_trip_distance_deltas[len(curr_trip_distance_deltas) / 2]) + " " + str(sum(curr_trip_distance_deltas) / len(curr_trip_distance_deltas)) + " " + 
                         str(curr_trip_speed_deltas[len(curr_trip_speed_deltas) / 2]) + " " + str(sum(curr_trip_speed_deltas) / len(curr_trip_speed_deltas)) + " " + 
                         str(curr_trip_acceleration_deltas[len(curr_trip_acceleration_deltas) / 2]) + " " + str(sum(curr_trip_acceleration_deltas) / len(curr_trip_acceleration_deltas)) + " " + 
                         str(curr_trip_bearing_deltas[len(curr_trip_bearing_deltas) / 2]) + " " + str(sum(curr_trip_bearing_deltas) / len(curr_trip_bearing_deltas)) + "\n")
        sys.stdout.flush()
        
        curr_trip_time_deltas = []
        curr_trip_distance_deltas = []
        curr_trip_speed_deltas = []
        curr_trip_acceleration_deltas = []
        curr_trip_bearing_deltas = []
    
    curr_trip_time_deltas.append(time_delta)
    curr_trip_distance_deltas.append(distance_delta)
    curr_trip_speed_deltas.append(speed_delta)
    curr_trip_acceleration_deltas.append(acceleration_delta)
    curr_trip_bearing_deltas.append(bearing_delta)
    
    prev_provider_id = curr_provider_id
    prev_probe_id = curr_probe_id
    prev_trip_id = curr_trip_id

curr_trip_time_deltas.sort()
curr_trip_distance_deltas.sort()
curr_trip_speed_deltas.sort()
curr_trip_acceleration_deltas.sort()
curr_trip_bearing_deltas.sort()

sys.stdout.write(str(prev_provider_id) + " " + 
                 str(prev_probe_id) + " " + 
                 str(prev_trip_id) + " " + 
                 str(curr_trip_time_deltas[len(curr_trip_time_deltas) / 2]) + " " + str(sum(curr_trip_time_deltas) / len(curr_trip_time_deltas)) + " " + 
                 str(curr_trip_distance_deltas[len(curr_trip_distance_deltas) / 2]) + " " + str(sum(curr_trip_distance_deltas) / len(curr_trip_distance_deltas)) + " " + 
                 str(curr_trip_speed_deltas[len(curr_trip_speed_deltas) / 2]) + " " + str(sum(curr_trip_speed_deltas) / len(curr_trip_speed_deltas)) + " " + 
                 str(curr_trip_acceleration_deltas[len(curr_trip_acceleration_deltas) / 2]) + " " + str(sum(curr_trip_acceleration_deltas) / len(curr_trip_acceleration_deltas)) + " " + 
                 str(curr_trip_bearing_deltas[len(curr_trip_bearing_deltas) / 2]) + " " + str(sum(curr_trip_bearing_deltas) / len(curr_trip_bearing_deltas)) + "\n")
sys.stdout.flush()
