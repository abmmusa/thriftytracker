import pickle, getopt, sys

MAX_BUCKETS=35 # keep synced with produce_offline_reachtime_exponentialerror_table.py

def get_expected_reachtime_for_errorbucket(time_error_table, errorbucket):
    count_for_errorbucket = [counts[errorbucket] for counts in time_error_table]
    total_count = sum(count_for_errorbucket)

    if total_count == 0:
        #print errorbucket
        return -100

    #print errorbucket, count_for_errorbucket
    expected_time=0.0
    for i in range(0, len(time_error_table)):
        time=i+1
        expected_time += time*(float(count_for_errorbucket[i])/float(total_count))

    #print errorbucket, expected_time
    return expected_time


def write_all_expected_reachtimes(time_error_table, output_file):
    if not time_error_table:
        return

    for bucket in range(0, MAX_BUCKETS):
        expected_time_bucket = get_expected_reachtime_for_errorbucket(time_error_table, bucket)
        output_file.write(str(bucket)+" "+str(expected_time_bucket)+"\n")


def write_all_expected_reachtimes_pickle(time_error_table, output_file):
    if not time_error_table:
        return

    expected_times = []
    for bucket in range(0, MAX_BUCKETS):
        expected_time_bucket = get_expected_reachtime_for_errorbucket(time_error_table, bucket)
        expected_times.append(expected_time_bucket)

    pickle.dump(expected_times, output_file)





usage="Usage: python produce_offline_exponentialerror_expected_reachtime_table -i <expected reach time exponential error pickle file> -o <expected reachtimetime data file> -p <expected reachtime pickle file> [-h]"

input_file = ""
output_file = ""
output_file_pickle = ""


try:
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:p:h")
except:
    print usage 

for o,a in opts:
    if o == "-i":
        input_file = str(a)
    elif o == "-o":
        output_file = str(a)
    elif o == "-p":
        output_file_pickle = str(a)
    elif o == "-h":
            print usage 
            exit()
    



f = open(input_file, "rb")
expected_error_table = pickle.load(f)
f.close()


if output_file != "":
    fo = open(output_file, "w")
    write_all_expected_reachtimes(expected_error_table, fo)
    fo.close()

if output_file_pickle != "":
    fp = open(output_file_pickle, "w")
    write_all_expected_reachtimes_pickle(expected_error_table, fp)
    fp.close()


