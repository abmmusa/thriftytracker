import os
import gzip
from location import LocationWithEstimatedValues
from pylibs import spatialfunclib
from glob import glob
import pickle


debug = False

BUCKET_SIZE=50

class TimeErrorTableCreator:
    def __init__(self, window_size = 600):
        self.estimation_window = []
        self.window_size = window_size #seconds
        self.time_error_table = {}

    
    def run(self, trace_dir, extrapolator):
        
        files=[]
        for path,_,_ in os.walk(trace_dir):
            files.extend(glob(os.path.join(path,"*.txt.gz")))

        for f in files:
            print f

            trace_file = gzip.open(f, 'rb')

            trace = trace_file.readlines()

            #print trace
            need_init = True
            self.estimation_window = []
 
            for raw_location in trace:
                if (raw_location == "\n"):
                    need_init = True
                    #print f
                
                else:
                    curr_location = LocationWithEstimatedValues()
                    curr_location.load_raw_location(raw_location)
                
                    if (need_init is True):
                        self.estimation_window = [extrapolator.init_location_params(curr_location)]
                        need_init = False                
                    else:
                        #sampler.update(extrapolator.get_location_params(curr_location))
                        self.update_time_error_table(extrapolator.get_location_params(curr_location), extrapolator)

        
    def update_time_error_table(self, curr_loc_param, extrapolator):
        (curr_loc, curr_param) = curr_loc_param

        if(curr_loc.time - self.estimation_window[0][0].time <= self.window_size):
            self.estimation_window.append(curr_loc_param)
            #print "append", curr_loc.time

        else: 
            # make room for curr_loc_param in the estimation window
            while( self.estimation_window and (curr_loc.time - self.estimation_window[0][0].time >= self.window_size) ): 
                del self.estimation_window[0]
                
            # put the curr_loc_param in the estimation window now
            self.estimation_window.append(curr_loc_param)
            #print "append after room maked", curr_loc.time

            for (loc, param) in self.estimation_window:
                #print loc, param
                time_interval = curr_loc.time - loc.time
                if time_interval == 0:
                    continue

                extrapolated_trajectory = extrapolator.get_trajectory((loc, param), [time_interval])
                extrapolation_error = self._distance(curr_loc, extrapolated_trajectory[0])
            

                # converts to nearest bucket size (e.g: 20 to 0, 30 to 50 etc for bucket size of 50)
                extrapolation_error_bucketized = round(extrapolation_error/BUCKET_SIZE)*BUCKET_SIZE

                #print loc.time, time_interval, extrapolation_error, extrapolation_error_bucketized
            

                try:
                    self.time_error_table[time_interval, extrapolation_error_bucketized] += 1
                except:
                    self.time_error_table[time_interval, extrapolation_error_bucketized] = 1


    #bucketting not needed now as already doing during addition to the table
    # NOT USED CURRENTLY
    def write_time_error_table_with_bucket(self, output_file):
        if not self.time_error_table:
            print "no values in time error table!"
            return

        times = sorted(list(set([time for (time, error) in self.time_error_table.keys()])))

        buckets=range(50, 5050, 50)
        #print buckets

        for t in times:
            count_in_buckets = dict((bucket, 0) for bucket in buckets)
            
            error_count_t=[(error,count) for ((time,error),count) in self.time_error_table.items() if time==t]
            for (error,count) in error_count_t:
                for bucket in buckets:
                    if error < bucket:
                        count_in_buckets[bucket] += count
                        break

            sorted_result = sorted(count_in_buckets.items(), key = lambda k:k[0])

            for (bucket, count) in sorted_result:
                output_file.write(str(int(t))+" "+str(bucket)+" "+str(count)+"\n")

            output_file.write("\n")


    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)


import sys, getopt
from extrapolator import ConstantLocationExtrapolator, ConstantVelocityExtrapolator

if __name__ == "__main__":
    
    input_directory = "."
    output_directory = "time_error_table_offline"
    output_filename = "default"
    window_size = int(600)
    
    extrapolator_index=0

    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:x:w:h")
    
    for o,a in opts:
        if o == "-i":
            input_directory = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-x":
            extrapolator_index = int(a)
        elif o == "-w":
            window_size = int(a)
        elif o == "-h":
            print "Usage: python produce_offline_time_error_table [-i input_directory] [-o output_file_name] [-x extrapolator_index] [-w window_size] [-h]"
            exit()
    
    if(extrapolator_index == 0):
        extrapolator = ConstantLocationExtrapolator()
    elif(extrapolator_index == 1):
        print "const velocity extra"
        extrapolator = ConstantVelocityExtrapolator()
        
    timeErrorTableCreator = TimeErrorTableCreator(window_size)
    timeErrorTableCreator.run(input_directory, extrapolator)

    #print timeErrorTableCreator.time_error_table

    output_file=open(output_directory+"/"+output_filename, 'wb')
    pickle.dump(timeErrorTableCreator.time_error_table, output_file)
    output_file.close()

    #output_file=open(output_directory+"/"+output_filename, 'w')
    #timeErrorTableCreator.write_time_error_table_with_bucket(output_file)

