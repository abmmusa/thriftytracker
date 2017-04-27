import pickle, getopt, sys


def write_reachtime_error_table(time_error_table, output_file):
    if not time_error_table:
        return
    
    #all times after removing duplicate times
    times = sorted(list(set([time for (time, error) in time_error_table.keys()])))

    min_error = min( [error for (time, error) in time_error_table.keys()] )
    max_error = max( [error for (time, error) in time_error_table.keys()] )

    sorted_errors = sorted( set([error for (time, error) in time_error_table.keys()]) )
    error_bucket = sorted_errors[1] - sorted_errors[0]

    print min_error, max_error, error_bucket
    all_errors = map(lambda x:float(x), range(int(min_error), int(max_error+error_bucket), int(error_bucket)))
    #print all_errors


    for t in times:
        error_count_t=dict([(error,count) for ((time,error),count) in time_error_table.items() if time==t])
        
        for error in all_errors:
            if(error_count_t.has_key(error)):
                count = error_count_t[error]
                output_file.write(str(t)+" "+str(error)+" "+str(count)+"\n")
            else:
                output_file.write(str(t)+" "+str(error)+" "+str(0)+"\n")
            

        output_file.write("\n")


def get_expected_error_for_time(time_error_table, time):
    error_count=[(error,count) for ((t,error),count) in time_error_table.items() if t==time]
    total_count = sum(map(lambda (error,count):count, error_count))
        
    return sum( map(lambda(error,count):error*(float(count)/float(total_count)), error_count) )
        

def write_all_expected_errors(time_error_table, output_file):
    if not time_error_table:
        return

    times = sorted(list(set([time for (time, error) in time_error_table.keys()])))
    for t in times:
        expected_error_t = get_expected_error_for_time(time_error_table, t)
        output_file.write(str(t)+" "+str(expected_error_t)+"\n")


def write_all_expected_errors_pickle(time_error_table, output_file):
    if not time_error_table:
        return


    expected_errors = {}
    times = sorted(list(set([time for (time, error) in time_error_table.keys()])))
    for t in times:
        expected_error_t = get_expected_error_for_time(time_error_table, t)
        expected_errors[t] = expected_error_t

    pickle.dump(expected_errors, output_file)




usage="Usage: python produce_offline_reachtime_expected_error_table -i <input_file> -o <output_file> -e <expected_error_file> -p <pickle_file_for_expected_error> [-h]"

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
    



f = open(input_file, "rb")
time_error_table = pickle.load(f)
f.close()

#print time_error_table

if output_file != "":
    fo = open(output_file, "w")
    write_reachtime_error_table(time_error_table, fo)
    fo.close()

if output_file_expected_error != "":
    fe = open(output_file_expected_error, "w")
    write_all_expected_errors(time_error_table, fe)
    fe.close()

if output_file_pickle_expected_error != "":
    fp = open(output_file_pickle_expected_error, "w")
    write_all_expected_errors_pickle(time_error_table, fp)
    fp.close()



