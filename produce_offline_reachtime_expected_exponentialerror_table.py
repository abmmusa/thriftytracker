import pickle, getopt, sys
import math

# TODO: write_reachtime_error_table() similar to produce_offline_reachtime_expected_error_table.py for -o option


MAX_BUCKETS=35 #keep synced with produce_offline_reachtime_exponentialerror_table.py


def write_reachtime_exponentialerror_table(time_error_table, output_file):
    if not time_error_table:
        return
    
    for time in range(0, len(time_error_table)):
        for bucket in range(0, MAX_BUCKETS):
            #error=error_upper_bounds[bucket] 
            count = time_error_table[time][bucket]
            #output_file.write(str(time)+" "+str(error)+" "+str(count)+"\n")
            output_file.write(str(time+1)+" "+str(bucket)+" "+str(count)+"\n")

        output_file.write("\n")



def get_error_upper_bounds():
    error_upper_bounds=sorted(list(set([round(math.pow(2,i)**(1.0/2.0)) for i in range(0, MAX_BUCKETS-1)])))
    error_upper_bounds.insert(0, 0.0)

    return error_upper_bounds


def get_expected_error_for_time(time_error_table, time):
    count_for_time = time_error_table[time]
    total_count = sum(count_for_time)

    if total_count == 0:
        #print time, time_error_table[time]
        return -1000.0 # this can only happen in very unusual case and we will see it the plots

    #expected_error = 0.0
    #for i in range(0, len(count_for_time)-1): # NOTE: ignoring the last bucket up to infinity
    #    # get middle value of error bucket from the bucket number
    #    error = (error_upper_bounds[i] + error_upper_bounds[i+1])/2
    #    expected_error += error*float(count_for_time[i])/float(total_count)

    expected_bucket = -1
    for bucket in range(0, len(count_for_time)-1): # NOTE: ignoring the last bucket up to infinity
        expected_bucket += bucket*float(count_for_time[bucket])/float(total_count)

    expected_bucket_int = int(math.ceil(expected_bucket))
    print time, expected_bucket_int, error_upper_bounds[expected_bucket_int] 

    expected_error = -1.0
    if expected_bucket_int == 0:
        expected_error = 0.0
    else:
        expected_error = error_upper_bounds[expected_bucket_int] 
        
    return expected_error
        

def write_all_expected_errors(time_error_table, output_file):
    if not time_error_table:
        return

    for i in range(0, len(time_error_table)):
        expected_error_time = get_expected_error_for_time(time_error_table, i)
        time = i+1
        output_file.write(str(time)+" "+str(expected_error_time)+"\n")



def write_all_expected_errors_pickle(time_error_table, output_file):
    if not time_error_table:
        return

    expected_errors = []
    for i in range(0, len(time_error_table)):
        expected_error_time = get_expected_error_for_time(time_error_table, i)
        time = i+1
        expected_errors.append(expected_error_time)

    pickle.dump(expected_errors, output_file)

    



usage="Usage: python produce_offline_reachtime_expected_exponentialerror_table -i <input_file> -o <output_file> -e <expected_error_file> -p <pickle_file_for_expected_error> [-h]"

input_file = ""
output_file = ""
output_file_expected_error = ""
output_file_pickle_expected_error = ""

try:
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:e:p:h")
except:
    print usage 

for o,a in opts:
    if o == "-i":
        input_file = str(a)
    elif o == "-o":
        output_file = str(a)
    elif o == "-e":
        output_file_expected_error = str(a)
    elif o == "-p":
        output_file_pickle_expected_error = str(a)
    elif o == "-h":
            print usage 
            exit()
    


error_upper_bounds = get_error_upper_bounds()
#print error_upper_bounds


f = open(input_file, "rb")
time_error_table = pickle.load(f)
f.close()

#print time_error_table

if output_file != "":
    fo = open(output_file, "w")
    write_reachtime_exponentialerror_table(time_error_table, fo)
    fo.close()

if output_file_expected_error != "":
    fe = open(output_file_expected_error, "w")
    write_all_expected_errors(time_error_table, fe)
    fe.close()

if output_file_pickle_expected_error != "":
    fp = open(output_file_pickle_expected_error, "w")
    write_all_expected_errors_pickle(time_error_table, fp)
    fp.close()



