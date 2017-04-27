import getopt, sys, pickle

# NOT used currently
# removes hump by liner interpolaiton towards 0
def get_table_dict_hump_removed(table):
    if not table:
        return 

    table_dict = {}
    i = len(table) - 1
    while (i > 0):
        if table[i] < 0:
            i -= 1
            continue

        if table[i-1] < table[i]:
            #print i, table[i]
            table_dict[i] = table[i]
            i -= 1
        else:
            #print i, table[i]
            table_dict[i] = table[i]

            del_reachtime = table[i] - 0.0
            del_bucket = i 
            for j in range(i-1, -1, -1):
                bucketgap = i - j
                reachtime_interpolated = table[i] - (float(bucketgap)/float(del_bucket))*del_reachtime
                
                if reachtime_interpolated > table[j]:
                    break;

                #print j, reachtime_interpolated
                table_dict[j] = reachtime_interpolated

            i = j 
    
    return table_dict


# Remove hump by exponential interpolation
# ref(logarithming interpolation): http://www.cmu.edu/biolphys/deserno/pdf/log_interpol.pdf
def get_table_dict_hump_removed_exponential(table):
    if not table:
        return 

    table_dict = {}
    i = len(table) - 1
    while (i > 0):
        if table[i] < 0:
            i -= 1
            continue

        if table[i-1] < table[i]:
            #print "a", i, table[i]
   
            table_dict[i] = table[i]
            i -= 1
        else:
            #print "b", i, table[i]
            table_dict[i] = table[i]

            del_reachtime = table[i] - 0.0
            del_bucket = i 
            for j in range(i-1, -1, -1):
                bucketgap = del_bucket - j
                f = float(bucketgap)/float(del_bucket)
                reachtime_interpolated = (table[i]**(1-f))*(1**f)
                #reachtime_interpolated = table[i] - (float(bucketgap)/float(del_bucket))*del_reachtime
                
                if reachtime_interpolated > table[j]:
                    break;

                #print "c", j, reachtime_interpolated
                table_dict[j] = reachtime_interpolated

            i = j 
    
    #print table_dict
    return table_dict



def write_all_expected_reachtimes_wo_hump(table, output_file):
    if not table:
        return 

    table_dict = get_table_dict_hump_removed_exponential(table)
    output_file.write(str(0)+" "+str(0.0)+"\n")
    for bucket in sorted(table_dict.keys()):
        output_file.write(str(bucket+1)+" "+str(table_dict[bucket])+"\n")



def write_all_expected_reachtimes_pickle_wo_hump(table, output_file):
    if not table:
        return
    
    #table_dict = get_table_dict_hump_removed(table)
    table_dict = get_table_dict_hump_removed_exponential(table)
    hump_removed_table = []
    hump_removed_table.append(0.0)
    for bucket in sorted(table_dict.keys()):
        hump_removed_table.append(table_dict[bucket])

    pickle.dump(hump_removed_table, output_file)
    


usage="Usage: python produce_offline_exponentialerror_expected_reachtime_table_wo_hump.py -i <expected reachtime exponentialerror pickle file> -o <expected reachtimetime wo hump data file> -p <expected reachtime wo hump pickle file> [-h]"

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
expected_exponential_reachtime_table = pickle.load(f)
f.close()


if output_file != "":
    fo = open(output_file, "w")
    write_all_expected_reachtimes_wo_hump(expected_exponential_reachtime_table, fo)
    fo.close()

if output_file_pickle != "":
    fp = open(output_file_pickle, "w")
    write_all_expected_reachtimes_pickle_wo_hump(expected_exponential_reachtime_table, fp)
    fp.close()

