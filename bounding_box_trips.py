import sys

def valid_trip(curr_trip, min_lat, min_lon, max_lat, max_lon):
    for raw_location in curr_trip:
        raw_location_components = raw_location.strip("\n").split(" ")
        
        curr_lat = float(raw_location_components[0])
        curr_lon = float(raw_location_components[1])
        
        #print "raw location: " + str(raw_location)
        #print "curr_lat, curr_lon: " + str(curr_lat) + ", " + str(curr_lon)
        
        if ((curr_lat < min_lat) or (curr_lat > max_lat) or (curr_lon < min_lon) or (curr_lon > max_lon)):
            return False
    
    return True

def print_trip(curr_trip):
    for raw_location in curr_trip:
        sys.stdout.write(raw_location)
    sys.stdout.write("\n")

min_lat = float(sys.argv[1])
min_lon = float(sys.argv[2])

max_lat = float(sys.argv[3])
max_lon = float(sys.argv[4])

#print "bounding box: (%.6f, %.6f), (%.6f, %.6f)" % (min_lat, min_lon, max_lat, max_lon)

curr_trip = []

for raw_location in sys.stdin:
    if (raw_location == "\n"):
        if ((len(curr_trip) > 0) and valid_trip(curr_trip, min_lat, min_lon, max_lat, max_lon)):
            print_trip(curr_trip)
        curr_trip = []
    
    else:
        curr_trip.append(raw_location)

if ((len(curr_trip) > 0) and valid_trip(curr_trip, min_lat, min_lon, max_lat, max_lon)):
    print_trip(curr_trip)
