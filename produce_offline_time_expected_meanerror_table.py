import pickle, getopt, sys



def write_all_expected_meanerrors(expected_error_table, output_file):
    if not expected_error_table:
        return

    times = sorted(expected_error_table.keys())

    for time in times:
        total_expected_error = 0.0
        count = int(0)
        for t in range(1, int(time+1)):
            try:
                expected_error_t = expected_error_table[t]
                total_expected_error += expected_error_t
                count+=1
            except:
                continue
        
        mean_expected_error = total_expected_error/count
        output_file.write(str(t)+" "+str(mean_expected_error)+"\n")



def write_all_expected_meanerrors_pickle(expected_error_table, output_file):
    if not expected_error_table:
        return

    expected_meanerrors = {}

    times = sorted(expected_error_table.keys())

    for time in times:
        total_expected_error = 0.0
        count = int(0)
        for t in range(1, int(time+1)):
            try:
                expected_error_t = expected_error_table[t]
                total_expected_error += expected_error_t
                count+=1
            except:
                continue
        
        mean_expected_error = total_expected_error/count

        expected_meanerrors[time] = mean_expected_error

    pickle.dump(expected_meanerrors, output_file)





usage="Usage: python unpickle_offline_time_error_table -i <expected error pickle file> -o <mean expected error data file> -p <mean expected error pickle file> [-h]"

input_file = ""
output_file = ""
xboutput_file_pickle = ""


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
    write_all_expected_meanerrors(expected_error_table, fo)
    fo.close()

if output_file_pickle != "":
    fp = open(output_file_pickle, "w")
    write_all_expected_meanerrors_pickle(expected_error_table, fp)
    fp.close()


