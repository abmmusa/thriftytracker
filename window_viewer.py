import gzip

class WindowViewer:
    def __init__(self):
        pass
    
    def view(self, sample_time_tables_path, parameter_key, trace_id, extrapolator_indices):
        e_keys = extrapolator_indices
        e_keys.sort()
        
        eval_files = {}
        for extrapolator_index in extrapolator_indices:
            eval_files[extrapolator_index] = gzip.open(sample_time_tables_path + "/sample_time_table_x" + str(extrapolator_index) + "_" + parameter_key + "_i" + str(trace_id) + ".txt.gz", 'rb')
        
        record_count = 0
        curr_record = {}
        for curr_record[e_keys[0]] in eval_files[e_keys[0]]:
            for i in range(1, len(e_keys)):
                curr_record[e_keys[i]] = eval_files[e_keys[i]].readline()
            
            curr_record_id = {}
            curr_record_duration = {}
            
            for i in range(0, len(e_keys)):
                curr_record_components = curr_record[e_keys[i]].strip("\n").split(" ")
                curr_record_id[e_keys[i]], curr_record_duration[e_keys[i]] = str(curr_record_components[0]), float(curr_record_components[3])
            
            if (len(set(curr_record_id.values())) > 1):
                print "ERROR!! Record ID mismatch!!"
                exit()
            
            sys.stdout.write(str(record_count))
            
            for i in range(0, len(e_keys)):
                sys.stdout.write(" " + str(curr_record_duration[e_keys[i]]))
            
            sys.stdout.write("\n")
            record_count += 1
        
        for extrapolator_index in extrapolator_indices:
            eval_files[extrapolator_index].close()

import sys, getopt, os
if __name__ == "__main__":
    sample_time_tables_path = "extrapolator_testbench_output_uic_c1/split_0/"
    parameter_key = "e25"
    trace_id = "0"
    
    (opts, args) = getopt.getopt(sys.argv[1:],"s:p:i:h")
    
    for o,a in opts:
        if o == "-s":
            sample_time_tables_path = str(a)
        elif o == "-p":
            parameter_key = str(a)
        elif o == "-i":
            trace_id = str(a)
        elif o == "-h":
            print "Usage: python window_viewer.py [-s <sample_time_tables_path>] [-p <parameter_key>] [-i <trace_id>] [-h]"
            exit()
    
    all_sample_time_table_filenames = filter(lambda x: x.startswith("sample_time_table_x") and ("_" + parameter_key + "_" in x) and x.endswith("_i" + trace_id + ".txt.gz"), os.listdir(sample_time_tables_path))
    #print "all_sample_time_table_filenames: " + str(all_sample_time_table_filenames)
    
    all_extrapolator_indices = filter(lambda x: x < 12, list(set(map(lambda x: int(x.split("_")[3][1:]), all_sample_time_table_filenames))))
    #print "all_extrapolator_indices: " + str(all_extrapolator_indices)
    
    wv = WindowViewer()
    wv.view(sample_time_tables_path, parameter_key, trace_id, all_extrapolator_indices)
