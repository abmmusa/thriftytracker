import gzip

class OracleX99:
    def __init__(self):
        pass
    
    def create(self, all_extrapolator_indices, all_thresholds, all_unique_ids, input_path, output_path):
        for curr_threshold in all_thresholds:
            
            greaterthan_mode = True
            if (curr_threshold[0] == "d"):
                greaterthan_mode = False
            
            for curr_unique_id in all_unique_ids:
                
                curr_result_files = {}
                for extrapolator_index in all_extrapolator_indices:
                    curr_result_files[extrapolator_index] = gzip.open(input_path + "/sample_time_table_x" + str(extrapolator_index) + "_" + str(curr_threshold) + "_i" + str(curr_unique_id) + ".txt.gz", 'rb')
                
                output_file = gzip.open(output_path + "/sample_time_table_x99_" + str(curr_threshold) + "_i" + str(curr_unique_id) + ".txt.gz", 'wb')
                self._output_best_result_values(curr_result_files, output_file, greaterthan_mode)
                output_file.close()
                
                for extrapolator_index in all_extrapolator_indices:
                    curr_result_files[extrapolator_index].close()
    
    def _output_best_result_values(self, result_files, output_file, greaterthan_mode):
        e_keys_values = map(lambda x: int(x), result_files.keys())
        e_keys_values.sort()
        e_keys = map(lambda x: str(x), e_keys_values)
        
        curr_record = {}
        for curr_record[e_keys[0]] in result_files[e_keys[0]]:
            for i in range(1, len(e_keys)):
                curr_record[e_keys[i]] = result_files[e_keys[i]].readline()
            
            curr_record_id, curr_record_lat, curr_record_lon, curr_record_result_value, _, curr_record_output_count = curr_record[e_keys[0]].strip("\n").split(" ")
            
            curr_record_best_result_value = float(curr_record_result_value)
            curr_record_best_output_count = int(curr_record_output_count)
            curr_record_best_result_e_key = e_keys[0]
            
            for i in range(1, len(e_keys)):
                curr_record_result_value = float(curr_record[e_keys[i]].strip("\n").split(" ")[3])
                curr_record_output_count = int(curr_record[e_keys[i]].strip("\n").split(" ")[5])
                
                if (self._compare_values(curr_record_result_value, curr_record_best_result_value, greaterthan_mode) is True):
                    curr_record_best_result_value = curr_record_result_value
                    curr_record_best_output_count = curr_record_output_count
                    curr_record_best_result_e_key = e_keys[i]
            
            output_file.write(str(curr_record_id) + " " + str(curr_record_lat) + " " + str(curr_record_lon) + " " + str(curr_record_best_result_value) + " 1 " + str(curr_record_best_output_count) + " x" + str(curr_record_best_result_e_key) + "\n")
    
    def _compare_values(self, value1, value2, greaterthan_mode=True):
        if (greaterthan_mode is True):
            if (value1 >= value2):
                return True
        else:
            if (value1 <= value2):
                return True
        
        return False

import sys, getopt, os, gzip
if __name__ == "__main__":
    testbench_input_path = "extrapolator_testbench_output/"
    oracle_output_path = "extrapolator_testbench_output/"
    extrapolator_indices = None
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:x:h")
    
    for o,a in opts:
        if o == "-i":
            testbench_input_path = str(a)
        elif o == "-o":
            oracle_output_path = str(a)
        elif o == "-x":
            extrapolator_indices = str(a)
        elif o == "-h":
            print "Usage: python oracle_x99.py [-i <testbench_input_path>] [-o <oracle_output_path>] [-x <extrapolator_indices>] [-h]"
            exit()
    
    all_filenames = filter(lambda x: x.startswith("sample_time_table_x") and x.endswith(".txt.gz"), os.listdir(testbench_input_path))
    print "all_filenames: " + str(all_filenames)
    
    if (extrapolator_indices is not None):
        all_extrapolator_indices = map(lambda x: int(x), extrapolator_indices.strip("\n").split(","))
    else:
        all_extrapolator_indices = list(set(filter(lambda x: x < 12, map(lambda x: int(x.split("_")[3][1:]), all_filenames))))
    
    all_extrapolator_indices.sort()
    all_extrapolator_indices = map(lambda x: str(x), all_extrapolator_indices)
    print "all_extrapolator_indices: " + str(all_extrapolator_indices)
    
    all_error_thresholds = list(set(filter(lambda x: x[0] == "e", map(lambda x: x.split("_")[4], all_filenames))))
    print "all_error_thresholds: " + str(all_error_thresholds)
    
    #all_duration_thresholds = list(set(filter(lambda x: x[0] == "d", map(lambda x: x.split("_")[4], all_filenames))))
    #print "all_duration_thresholds: " + str(all_duration_thresholds)
    
    all_duration_mean_error_thresholds = list(set(filter(lambda x: x[0:2] == "dm", map(lambda x: x.split("_")[4], all_filenames))))
    print "all_duration_mean_error_thresholds: " + str(all_duration_mean_error_thresholds)
    
    all_duration_max_error_thresholds = list(set(filter(lambda x: x[0:2] == "dx", map(lambda x: x.split("_")[4], all_filenames))))
    print "all_duration_max_error_thresholds: " + str(all_duration_max_error_thresholds)
    
    all_unique_ids = list(set(map(lambda x: x.split("_")[5][1:-7], all_filenames)))
    print "all_unique_ids: " + str(all_unique_ids)
    
    oracle_x99 = OracleX99()
    oracle_x99.create(all_extrapolator_indices, all_error_thresholds, all_unique_ids, testbench_input_path, oracle_output_path)
    #oracle_x99.create(all_extrapolator_indices, all_duration_thresholds, all_unique_ids, testbench_input_path, oracle_output_path)
    oracle_x99.create(all_extrapolator_indices, all_duration_mean_error_thresholds, all_unique_ids, testbench_input_path, oracle_output_path)
    oracle_x99.create(all_extrapolator_indices, all_duration_max_error_thresholds, all_unique_ids, testbench_input_path, oracle_output_path)
