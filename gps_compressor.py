from pylibs import spatialfunclib
from location import LocationWithEstimatedValues

debug = False
debug_fast = False

class GPSCompressor:
    def __init__(self):
        pass

    def get_sed(self, segment, loc):
        (start_lat, start_lon, start_time) = (segment[0].lat, segment[0].lon, segment[0].time)
        (end_lat, end_lon, end_time) = (segment[-1].lat, segment[-1].lon, segment[-1].time)
        time_total=end_time - start_time

        (current_lat, current_lon, current_time) = (loc.lat, loc.lon, loc.time)

        time_interval = current_time - start_time 
    
        f = float(time_interval)/float(time_total)

        interpolated_lat = end_lat*f + start_lat*(1-f)
        interpolated_lon = end_lon*f + start_lon*(1-f)

        sed = spatialfunclib.distance(current_lat, current_lon, interpolated_lat, interpolated_lon)

        return sed



    # returns the value of max sed
    def max_sed(self, segment):
        if segment is None:
            return None

        max_sed=float("-inf")
        index = None

        for i in range(1, len(segment) - 1):
            sed = self.get_sed(segment, segment[i])

            if sed > max_sed:
                max_sed = sed
                index = i
        

        return (max_sed, index)
        

    def get_interpolated_location(self, segment, loc):
        #print map(lambda x:x.time, segment)
        (start_lat, start_lon, start_time) = (segment[0].lat, segment[0].lon, segment[0].time)
        (end_lat, end_lon, end_time) = (segment[-1].lat, segment[-1].lon, segment[-1].time)
        time_total=end_time - start_time

        (current_lat, current_lon, current_time) = (loc.lat, loc.lon, loc.time)

        time_interval = current_time - start_time 
    
        f = float(time_interval)/float(time_total)

        interpolated_lat = end_lat*f + start_lat*(1-f)
        interpolated_lon = end_lon*f + start_lon*(1-f)

        interpolated_loc = LocationWithEstimatedValues()
        interpolated_loc.lat = interpolated_lat
        interpolated_loc.lon = interpolated_lon
        interpolated_loc.time = current_time

        return interpolated_loc



     #top-down time-ratio algorithm that uses SED (synchronous error distance)
    def TDTR(self, segment, epsilon):
        (dmax, index) = self.max_sed(segment)
    
        if (dmax >= epsilon):
            #print "index", index, segment[index].time
            rec_results1 = self.TDTR(segment[0:index+1], epsilon)
            rec_results2 = self.TDTR(segment[index:], epsilon)
        
            smoothed_segment = rec_results1
            smoothed_segment.extend(rec_results2[1:])

            #print "if", map(lambda loc:loc.time, smoothed_segment)
        else:
            smoothed_segment = [segment[0], segment[-1]]
            #print "else", map(lambda loc:loc.time, smoothed_segment)

        return smoothed_segment



    def TDTR_error_bounded(self, segment, epsilon):
        if len(segment) < 2:
            return [0]

        compressed_segment = self.TDTR(segment, epsilon)

        # find and return compressed window indices
        compressed_indices=[]
        for i in range(0, len(segment)):
            for comp_loc in compressed_segment:
                if (comp_loc.time == segment[i].time):
                    compressed_indices.append(i)

        if debug:
            print compressed_indices

        return compressed_indices





    # TD-TR algorithm that terminates when certain compressed window size is reached.
    # At each step the sample causing the most error is added taken until total taken samples
    # reach the window size bound. And to make the decision of which sample to take, all edges 
    # are considered
    def TDTR_window_sized(self, segment, window_size):
        
        if len(segment) <= window_size: # nothing to compress
            #return segment
            all_indices = [index for index in range(0, len(segment))]
            return all_indices

        original_segment = segment
        segments=[segment]

        for i in range(0, window_size-2):

            (dmax, index) = (float("-inf"), None)
            segment_index = None
            total_segments = len(segments)

            if debug:
                print "total segments ", total_segments

            # find the sample that is causing max sed
            for i in range(0, total_segments):
                current_segment = segments[i]

                if debug:
                    print "current segment", map(lambda loc:loc.time, current_segment)

                (dmax_current, index_current) = self.max_sed(current_segment) 

                if dmax_current > dmax:
                    dmax = dmax_current
                    index = index_current
                    segment_index = i


            segments_new = []
            # prepend segments before splitted segment
            for i in range(0, segment_index):
                segments_new.append(segments[i])
                
            # two splitted segments from original segment
            splitted_segment = segments[segment_index]
            segments_new.append(splitted_segment[0:index+1])
            segments_new.append(splitted_segment[index:])

            # append segments after splitted segment
            for i in range(segment_index+1, total_segments):
                segments_new.append(segments[i])

            segments = list(segments_new)

            if debug:
                print "segments new", [map(lambda loc:loc.time, segment) for segment in segments]         


        # now find the compressed samples
        compressed_segment = []

        compressed_segment.append(segments[0][0])
        for i in range(0, len(segments)):
            current_segment = segments[i]
            compressed_segment.append(current_segment[-1])

        if debug:
            print "compressed segment", map(lambda loc:loc.time, compressed_segment)



        #UNCOMMENT to send comprssed segment rather than compressed window
        #return compressed_segment


        # find and return compressed window indices
        compressed_indices=[]
        for i in range(0, len(original_segment)):
            for comp_loc in compressed_segment:
                if (comp_loc.time == original_segment[i].time):
                    compressed_indices.append(i)

        if debug:
            print compressed_indices

        return compressed_indices


    #
    # fast version of TDTR_window_size
    #
    def TDTR_window_sized_fast(self, segment, window_size):
        if debug_fast: print "\n"
        
        if len(segment) <= window_size: # nothing to compress
            #return segment
            all_indices = [index for index in range(0, len(segment))]
            return all_indices


        # the chace below is to use fast lookup of already computed/known max sed 
        # so that we don't need to compute again.
        # key = (segment_start_time, segment_end_time)
        # value = (max_sed, index_of_sample_having_max_sed)
        segment_maxsed_cache = {}

        original_segment = segment
        segments=[segment]

        for i in range(0, window_size-2):

            (dmax, index) = (float("-inf"), None)
            segment_index = None
            total_segments = len(segments)

            if debug_fast:
                print "total segments ", total_segments

            # find the sample that is causing max sed
            for i in range(0, total_segments):
                current_segment = segments[i]

                if debug_fast:
                    print "current segment", map(lambda loc:loc.time, current_segment)

                (dmax_current, index_current) = (None, None)
                cache_key = (current_segment[0].time, current_segment[-1].time)
                if segment_maxsed_cache.has_key(cache_key):
                    (dmax_current, index_current) = segment_maxsed_cache[cache_key]
                else:
                    (dmax_current, index_current) = self.max_sed(current_segment) 
                    segment_maxsed_cache[cache_key] = (dmax_current, index_current)

                if dmax_current > dmax:
                    dmax = dmax_current
                    index = index_current
                    segment_index = i


            segments_new = []
            # prepend segments before splitted segment
            for i in range(0, segment_index):
                segments_new.append(segments[i])
                
            # two splitted segments from original segment
            splitted_segment = segments[segment_index]
            segments_new.append(splitted_segment[0:index+1])
            segments_new.append(splitted_segment[index:])

            # append segments after splitted segment
            for i in range(segment_index+1, total_segments):
                segments_new.append(segments[i])

            segments = list(segments_new)

            if debug_fast:
                print "segments new", [map(lambda loc:loc.time, segment) for segment in segments]         


        # now find the compressed samples
        compressed_segment = []

        compressed_segment.append(segments[0][0])
        for i in range(0, len(segments)):
            current_segment = segments[i]
            compressed_segment.append(current_segment[-1])

        if debug_fast:
            print "compressed segment", map(lambda loc:loc.time, compressed_segment)



        #UNCOMMENT to send comprssed segment rather than compressed indices
        #return compressed_segment


        # find and return compressed window indices
        compressed_indices=[]
        for i in range(0, len(original_segment)):
            for comp_loc in compressed_segment:
                if (comp_loc.time == original_segment[i].time):
                    compressed_indices.append(i)

        if debug_fast:
            print compressed_indices

        return compressed_indices




    def get_compression_error(self, uncompressed_segment, compressed_segment):
        # find the indices in the 
        compressed_indices=[]

        for i in range(0, len(uncompressed_segment)):
            for comp_loc in compressed_segment:
                if (comp_loc.time == uncompressed_segment[i].time):
                    compressed_indices.append(i)

        # print compressed_indices

        compressor_error = 0.0
        for i in range(0, len(compressed_indices)-1):
            edge_start_index = compressed_indices[i]
            edge_end_index = compressed_indices[i+1]

            #print edge_start_index, edge_end_index

            for j in range(edge_start_index, edge_end_index + 1):
                sed = self.get_sed(uncompressed_segment[edge_start_index:(edge_end_index+1)], uncompressed_segment[j])
                compressor_error += sed

        return compressor_error


    def get_compression_error_list(self, uncompressed_segment, compressed_segment):
        # find the indices in the 
        compressed_indices=[]
        compression_errors = []


        for i in range(0, len(uncompressed_segment)):
            for comp_loc in compressed_segment:
                if (comp_loc.time == uncompressed_segment[i].time):
                    compressed_indices.append(i)

        compressed_indices = sorted(list(set(compressed_indices)))

        for i in range(0, len(compressed_indices)-1):
            edge_start_index = compressed_indices[i]
            edge_end_index = compressed_indices[i+1]

            #print edge_start_index, edge_end_index

            for j in range(edge_start_index, edge_end_index + 1):
                sed = self.get_sed(uncompressed_segment[edge_start_index:(edge_end_index+1)], uncompressed_segment[j])
                #compressor_error += sed
                compression_errors.append(sed)

        if not compression_errors:
            return [0.0]
        
        return compression_errors




    # return segment with original compressed locations and interpolated locations
    def get_interpolated_segment(self, uncompressed_segment, compressed_segment):
        #print "unc inside get_interpolated_segment", map(lambda x:x.time, uncompressed_segment), len(uncompressed_segment)
        #print "com inside get_interpolated_segment", map(lambda x:x.time, compressed_segment), len(compressed_segment)
        compressed_indices=[]

        for i in range(0, len(uncompressed_segment)):
            for comp_loc in compressed_segment:
                if (comp_loc.time == uncompressed_segment[i].time):
                    compressed_indices.append(i)

        #print "gps_comp.py compressed indices", compressed_indices

        interpolated_segment = []
        for i in range(0, len(compressed_indices)-1):
            edge_start_index = compressed_indices[i]
            edge_end_index = compressed_indices[i+1]

            interpolated_segment.append(uncompressed_segment[edge_start_index])

            for j in range(edge_start_index+1, edge_end_index):
                interpolated_loc = self.get_interpolated_location(uncompressed_segment[edge_start_index:(edge_end_index+1)], uncompressed_segment[j])
                interpolated_segment.append(interpolated_loc)

        interpolated_segment.append(uncompressed_segment[-1])

        return interpolated_segment

