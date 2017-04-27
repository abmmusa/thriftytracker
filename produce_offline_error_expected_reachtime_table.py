import pickle, getopt, sys


def get_expected_reachtime_for_error(time_error_table, error):
    time_count=[(time,count) for ((time,e),count) in time_error_table.items() if e==error]
    total_count = sum(map(lambda (time,count):count, time_count))
        
    return sum( map(lambda(time,count):time*(float(count)/float(total_count)), time_count) )
        

def write_all_expected_reachtimes(time_error_table, output_file):
    if not time_error_table:
        return

    errors = sorted(list(set([error for (time, error) in time_error_table.keys()])))
    for e in errors:
        expected_time_e = get_expected_reachtime_for_error(time_error_table, e)
        output_file.write(str(e)+" "+str(expected_time_e)+"\n")


def write_all_expected_reachtimes_pickle(time_error_table, output_file):
    if not time_error_table:
        return


    expected_times = {}
    errors = sorted(list(set([error for (time, error) in time_error_table.keys()])))
    for e in errors:
        expected_time_e = get_expected_reachtime_for_error(time_error_table, e)
        expected_times[e] = expected_time_e

    pickle.dump(expected_times, output_file)





usage="Usage: python produce_offline_error_expected_reachtime_table -i <expected time error pickle file> -o <expected time data file> -p <expected time pickle file> [-h]"

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


