import gzip

class Evaluator:
    def __init__(self):
        pass
    
    def evaluate_all(self, parameter_key, extrapolator_indices, unique_ids, testbench_output_path):
        e_keys = extrapolator_indices
        e_keys.sort()
        
        #valid_record_count = 0
        #win_count = {}
        #
        #for i in range(0, len(e_keys)):
        #    win_count[e_keys[i]] = 0
        
        record_count = 0
        
        win_count = {}
        equal_count = {}
        
        win_count_table = {}
        win_stats_table = {}
        equal_count_table = {}
        
        for i in range(0, len(e_keys)):
            win_count[e_keys[i]] = 0
            equal_count[e_keys[i]] = 0
            
            win_count_table[e_keys[i]] = {}
            win_stats_table[e_keys[i]] = {}
            equal_count_table[e_keys[i]] = {}
            
            for j in range(0, len(e_keys)):
                if (i != j):
                    win_count_table[e_keys[i]][e_keys[j]] = 0
                    win_stats_table[e_keys[i]][e_keys[j]] = []
                    equal_count_table[e_keys[i]][e_keys[j]] = 0
        
        for unique_id in unique_ids:
            for split in range(0, 5):
                eval_files = {}
                
                for extrapolator_index in extrapolator_indices:
                    eval_files[extrapolator_index] = gzip.open(testbench_output_path + "/split_" + str(split) + "/sample_time_table_x" + str(extrapolator_index) + "_" + parameter_key + "_i" + str(unique_id) + ".txt.gz", 'rb')
                
                if (parameter_key[0] == "e"):
                    (win_count, equal_count, record_count) = self.evaluate_error(win_count, equal_count, record_count, e_keys, eval_files)
                    #(win_count_table, win_stats_table, equal_count_table, record_count) = self.evaluate_error_tables(win_count_table, win_stats_table, equal_count_table, record_count, e_keys, eval_files)
                elif (parameter_key[0] == "d"):
                    (win_count_table, win_stats_table, equal_count_table, record_count) = self.evaluate_duration_tables(win_count_table, win_stats_table, equal_count_table, record_count, e_keys, eval_files)
                
                for extrapolator_index in eval_files:
                    eval_files[extrapolator_index].close()
        
        #sys.stdout.write(" " + " ".join(map(lambda x: str(x), e_keys)) + "\n")
        #for i in range(0, len(e_keys)):
        #    sys.stdout.write("%d " % (e_keys[i],))
        #    
        #    for j in range(0, len(e_keys)):
        #        if (i == j):
        #            #sys.stdout.write("0.0000/0.0000/0.0000\t")
        #            sys.stdout.write("0/0/0.0000 ")
        #            #sys.stdout.write("0.0000/0.0000 ")
        #        else:
        #            #sys.stdout.write("%.4f/%.4f/%.4f\t" % ((float(win_count_table[e_keys[i]][e_keys[j]]) / float(record_count)), (float(equal_count_table[e_keys[i]][e_keys[j]]) / float(record_count)), (float(sum(win_stats_table[e_keys[i]][e_keys[j]])) / float(record_count))))
        #            #sys.stdout.write("%.4f/%.4f/%.4f " % ((float(win_count_table[e_keys[i]][e_keys[j]]) / float(record_count)), (float(equal_count_table[e_keys[i]][e_keys[j]]) / float(record_count)), (float(sum(win_stats_table[e_keys[i]][e_keys[j]])) / float(record_count))))
        #            #sys.stdout.write("%.4f/%.4f " % ((float(win_count_table[e_keys[i]][e_keys[j]]) / float(record_count)), (float(sum(win_stats_table[e_keys[i]][e_keys[j]])) / float(record_count))))
        #            sys.stdout.write("%d/%d/%.4f " % (win_count_table[e_keys[i]][e_keys[j]], equal_count_table[e_keys[i]][e_keys[j]], (float(sum(win_stats_table[e_keys[i]][e_keys[j]])) / float(record_count))))
        #    
        #    sys.stdout.write("\n")
        #sys.stdout.write("\n")
        
        for i in range(0, len(e_keys)):
            sys.stdout.write("e" + str(e_keys[i]) + " " + str(win_count[e_keys[i]]) + " " + str(equal_count[e_keys[i]]) + " " + str(record_count) + "\n")
    
    def evaluate_error(self, win_count, equal_count, record_count, e_keys, eval_files):
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
            
            curr_durations = curr_record_duration.values()
            curr_durations.sort(reverse=True)
            #print "\ncurr_durations: " + str(curr_durations)
            
            longest_duration = curr_durations[0]
            #print "longest duration: " + str(longest_duration)
            
            unique_winner = (curr_durations[0] > curr_durations[1])
            #print "unique winner: " + str(unique_winner)
            
            for i in range(0, len(e_keys)):
                if (curr_record_duration[e_keys[i]] == longest_duration):
                    if (unique_winner is True):
                        win_count[e_keys[i]] += 1
                    
                    equal_count[e_keys[i]] += 1
            
            record_count += 1
        
        return (win_count, equal_count, record_count)
    
    def evaluate_error_tables(self, win_count_table, win_stats_table, equal_count_table, record_count, e_keys, eval_files):
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
            
            for i in range(0, len(e_keys)):
                for j in range(0, len(e_keys)):
                    if (i != j):
                        duration_difference = curr_record_duration[e_keys[i]] - curr_record_duration[e_keys[j]]
                        if (duration_difference > 0):
                            win_count_table[e_keys[i]][e_keys[j]] += 1
                            win_stats_table[e_keys[i]][e_keys[j]].append(duration_difference)
                        elif (duration_difference == 0.0):
                            equal_count_table[e_keys[i]][e_keys[j]] += 1
            
            record_count += 1
        
        return (win_count_table, win_stats_table, equal_count_table, record_count)
    
    def evaluate_duration_tables(self, win_count_table, win_stats_table, equal_count_table, record_count, e_keys, eval_files):
        curr_record = {}
        
        for curr_record[e_keys[0]] in eval_files[e_keys[0]]:
            for i in range(1, len(e_keys)):
                curr_record[e_keys[i]] = eval_files[e_keys[i]].readline()
            
            curr_record_id = {}
            curr_record_error = {}
            
            for i in range(0, len(e_keys)):
                curr_record_components = curr_record[e_keys[i]].strip("\n").split(" ")
                curr_record_id[e_keys[i]], curr_record_error[e_keys[i]] = str(curr_record_components[0]), float(curr_record_components[3])
            
            if (len(set(curr_record_id.values())) > 1):
                print "ERROR!! Record ID mismatch!!"
                exit()
            
            for i in range(0, len(e_keys)):
                for j in range(0, len(e_keys)):
                    if (i != j):
                        error_difference = curr_record_error[e_keys[i]] - curr_record_error[e_keys[j]]
                        if (error_difference < 0):
                            win_count_table[e_keys[i]][e_keys[j]] += 1
                            win_stats_table[e_keys[i]][e_keys[j]].append(error_difference)
                        elif (error_difference == 0.0):
                            equal_count_table[e_keys[i]][e_keys[j]] += 1
            
            record_count += 1
        
        return (win_count_table, win_stats_table, equal_count_table, record_count)

import sys, getopt
import os
if __name__ == "__main__":
    parameter_key = "e1"
    testbench_output_path = "extrapolator_testbench_output/"
    
    (opts, args) = getopt.getopt(sys.argv[1:],"p:i:h")
    
    for o,a in opts:
        if o == "-p":
            parameter_key = str(a)
        elif o == "-i":
            testbench_output_path = str(a)
        elif o == "-h":
            print "Usage: python extrapolator_testbench_evaluator.py [-p <parameter_key>] [-i <testbench_output_path>] [-h]\n"
            exit()
    
    all_eval_filenames = filter(lambda x: x.startswith("sample_time_table_x") and ("_" + parameter_key + "_" in x) and x.endswith(".txt.gz"), os.listdir(testbench_output_path + "/split_0/"))
    #print "all eval filenames: " + str(all_eval_filenames)
    
    all_extrapolator_indices = list(set(map(lambda x: int(x.split("_")[3][1:]), all_eval_filenames)))
    #print "all_extrapolator_indices: " + str(all_extrapolator_indices)
    
    all_unique_ids = list(set(map(lambda x: x.split("_")[5][1:-7], all_eval_filenames)))
    #print "all_unique_ids: " + str(all_unique_ids)
    
    e = Evaluator()
    e.evaluate_all(parameter_key, all_extrapolator_indices, all_unique_ids, testbench_output_path)
