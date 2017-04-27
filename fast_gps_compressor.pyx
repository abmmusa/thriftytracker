import cython
from location import LocationWithEstimatedValues
from libc.math cimport sin, cos, sqrt, atan2
import math

AUTHOR = "BITS Networked System Laboratory"

cdef double distance(double a_lat, double a_lon, double b_lat, double b_lon):
    cdef double dLat, dLon, a, c, d
    
    if (a_lat == b_lat and a_lon == b_lon):
        return 0.0
    
    dLat = math.radians(b_lat - a_lat)
    dLon = math.radians(b_lon - a_lon)
    
    a = sin(dLat/2.0) * sin(dLat/2.0) + cos(math.radians(a_lat)) * cos(math.radians(b_lat)) * sin(dLon/2.0) * sin(dLon/2.0)
    
    c = 2.0 * atan2(sqrt(a), sqrt(1 - a))
    d = 6371000.0 * c
    
    return d

@cython.boundscheck(False)
@cython.wraparound(False)
cdef double get_sed(list segment, object loc):
    cdef double start_lat, start_lon, start_time
    cdef double end_lat, end_lon, end_time
    cdef double time_total
    
    cdef int segment_last_index
    segment_last_index = len(segment) - 1
    
    (start_lat, start_lon, start_time) = (segment[0].lat, segment[0].lon, segment[0].time)
    (end_lat, end_lon, end_time) = (segment[segment_last_index].lat, segment[segment_last_index].lon, segment[segment_last_index].time)
    time_total = end_time - start_time
    
    cdef double current_lat, current_lon, current_time
    (current_lat, current_lon, current_time) = (loc.lat, loc.lon, loc.time)
    
    cdef double time_interval
    time_interval = current_time - start_time 
    
    cdef double f
    if (time_interval == 0.0):
        f = 0.0
    else:
        f = time_interval / time_total
    
    cdef double interpolated_lat, interpolated_lon
    interpolated_lat = end_lat*f + start_lat*(1-f)
    interpolated_lon = end_lon*f + start_lon*(1-f)
    
    cdef double sed
    sed = distance(current_lat, current_lon, interpolated_lat, interpolated_lon)
    
    return sed

@cython.boundscheck(False)
cdef max_sed(list segment, int segment_len):
    if (segment_len == 0):
        return 0
    
    cdef double sed, max_sed
    cdef int index
    
    max_sed = -99999.0
    index = -1
    
    cdef int i
    for i in range(1, segment_len - 1):
        sed = get_sed(segment, segment[i])
        
        if sed > max_sed:
            max_sed = sed
            index = i
    
    return (max_sed, index)

# TD-TR algorithm that terminates when certain compressed window size is reached.
# At each step the sample causing the most error is added taken until total taken samples
# reach the window size bound. And to make the decision of which sample to take, all edges 
# are considered
@cython.boundscheck(False)
@cython.wraparound(False)
cpdef list TDTR_window_sized(list segment, int window_size):
    cdef list all_indices
    cdef int segment_len, current_segment_len
    cdef int i, j
    
    segment_len = len(segment)
    all_indices = []
    
    if (segment_len <= window_size): # nothing to compress
        for i in range(0, segment_len):
            all_indices.append(i)
        
        return all_indices
    
    cdef list original_segment, segments
    original_segment = segment
    segments = [segment]
    
    cdef double dmax, dmax_current
    cdef int index, index_current
    cdef int segment_index
    cdef list segments_new, splitted_segment, current_segment
    cdef int total_segments
    
    for i in range(0, window_size - 2):
        dmax = -99999.0
        index = 99999
        
        segment_index = 99999
        total_segments = len(segments)
        
        # find the sample that is causing max sed
        for j in range(0, total_segments):
            current_segment = segments[j]
            current_segment_len = len(current_segment)
            
            (dmax_current, index_current) = max_sed(current_segment, current_segment_len)
            
            if dmax_current > dmax:
                dmax = dmax_current
                index = index_current
                segment_index = j
        
        segments_new = []
        # prepend segments before splitted segment
        for j in range(0, segment_index):
            segments_new.append(segments[j])
        
        # two splitted segments from original segment
        splitted_segment = segments[segment_index]
        segments_new.append(splitted_segment[0:index+1])
        segments_new.append(splitted_segment[index:])
        
        # append segments after splitted segment
        for j in range(segment_index+1, total_segments):
            segments_new.append(segments[j])
        
        segments = list(segments_new)
    
    cdef list compressed_segment
    cdef int segments_len, current_segment_last_index
    
    # now find the compressed samples
    compressed_segment = []
    segments_len = len(segments)
    
    compressed_segment.append(segments[0][0])
    for i in range(0, segments_len):
        current_segment = segments[i]
        current_segment_last_index = len(current_segment) - 1
        compressed_segment.append(current_segment[current_segment_last_index])
    
    # find and return compressed window indices
    cdef list compressed_indices
    cdef object comp_loc
    cdef int original_segment_len
    
    compressed_indices = []
    original_segment_len = len(original_segment)
    
    for i in range(0, original_segment_len):
        for comp_loc in compressed_segment:
            if (comp_loc.time == original_segment[i].time):
                compressed_indices.append(i)
    
    return compressed_indices

#
# fast version of TDTR_window_size
#
@cython.boundscheck(False)
@cython.wraparound(False)
cpdef list TDTR_window_sized_fast(list segment, int window_size):
    cdef list all_indices
    cdef int segment_len, current_segment_len
    cdef int i, j
    
    segment_len = len(segment)
    all_indices = []
    
    if (segment_len <= window_size): # nothing to compress
        for i in range(0, segment_len):
            all_indices.append(i)
        
        return all_indices
    
    # the chace below is to use fast lookup of already computed/known max sed 
    # so that we don't need to compute again.
    # key = (segment_start_time, segment_end_time)
    # value = (max_sed, index_of_sample_having_max_sed)
    cdef dict segment_maxsed_cache
    segment_maxsed_cache = {}
    
    cdef list original_segment, segments
    original_segment = segment
    segments = [segment]
    
    cdef double dmax, dmax_current
    cdef int index, index_current
    cdef int segment_index
    cdef list segments_new, splitted_segment, current_segment
    cdef int total_segments
    cdef tuple cache_key
    
    for i in range(0, window_size - 2):
        dmax = -99999.0
        index = 99999
        
        segment_index = 99999
        total_segments = len(segments)
        
        # find the sample that is causing max sed
        for j in range(0, total_segments):
            current_segment = segments[j]
            current_segment_len = len(current_segment)
            
            dmax_current = -99999.0
            index_current = 99999
            
            cache_key = (current_segment[0].time, current_segment[current_segment_len - 1].time)
            
            if segment_maxsed_cache.has_key(cache_key):
                (dmax_current, index_current) = segment_maxsed_cache[cache_key]
            else:
                (dmax_current, index_current) = max_sed(current_segment, current_segment_len)
                segment_maxsed_cache[cache_key] = (dmax_current, index_current)
            
            if dmax_current > dmax:
                dmax = dmax_current
                index = index_current
                segment_index = j
        
        segments_new = []
        # prepend segments before splitted segment
        for j in range(0, segment_index):
            segments_new.append(segments[j])
        
        # two splitted segments from original segment
        splitted_segment = segments[segment_index]
        segments_new.append(splitted_segment[0:index+1])
        segments_new.append(splitted_segment[index:])
        
        # append segments after splitted segment
        for j in range(segment_index+1, total_segments):
            segments_new.append(segments[j])
        
        segments = list(segments_new)
    
    cdef list compressed_segment
    cdef int segments_len, current_segment_last_index
    
    # now find the compressed samples
    compressed_segment = []
    segments_len = len(segments)
    
    compressed_segment.append(segments[0][0])
    for i in range(0, segments_len):
        current_segment = segments[i]
        current_segment_last_index = len(current_segment) - 1
        compressed_segment.append(current_segment[current_segment_last_index])
    
    # find and return compressed window indices
    cdef list compressed_indices
    cdef object comp_loc
    cdef int original_segment_len
    
    compressed_indices = []
    original_segment_len = len(original_segment)
    
    for i in range(0, original_segment_len):
        for comp_loc in compressed_segment:
            if (comp_loc.time == original_segment[i].time):
                compressed_indices.append(i)
    
    return compressed_indices

@cython.boundscheck(False)
cpdef double get_compression_error(list uncompressed_segment, list compressed_segment):
    cdef list compressed_indices
    compressed_indices = []
    
    cdef int i, j
    cdef object comp_loc
    cdef int uncompressed_segment_len
    
    uncompressed_segment_len = len(uncompressed_segment)
    
    for i in range(0, uncompressed_segment_len):
        for comp_loc in compressed_segment:
            if (comp_loc.time == uncompressed_segment[i].time):
                compressed_indices.append(i)
    
    cdef double compressor_error, sed
    cdef int compressed_indices_len, edge_start_index, edge_end_index
    
    compressor_error = 0.0
    compressed_indices_len = len(compressed_indices)
    
    for i in range(0, compressed_indices_len - 1):
        edge_start_index = compressed_indices[i]
        edge_end_index = compressed_indices[i + 1]
        
        for j in range(edge_start_index, edge_end_index + 1):
            sed = get_sed(uncompressed_segment[edge_start_index:(edge_end_index + 1)], uncompressed_segment[j])
            compressor_error += sed
    
    return compressor_error
