import random
import sys

class LinePicker:
    def __init__(self):
        random.seed(1399491371)
    
    def pick(self, input_filename, requested_num_lines):
        input_file = open(input_filename, 'r')
        input_file_all_lines = input_file.readlines()
        input_file.close()
        
        input_file_num_all_lines = len(input_file_all_lines)
        #print "input_file_all_lines: " + str(input_file_num_all_lines)
        
        line_num_list = []
        
        while (len(line_num_list) < requested_num_lines):
            new_line_num = random.randrange(0, input_file_num_all_lines)
            
            if (new_line_num not in line_num_list):
                line_num_list.append(new_line_num)
        
        line_num_list.sort()
        #print "line_num_list: " + str(len(line_num_list))
        #print "line_num_list: " + str(line_num_list[:10])
        
        for line_num in line_num_list:
            sys.stdout.write(input_file_all_lines[line_num])
        
        sys.stdout.flush()

import sys, getopt
if __name__ == "__main__":
    input_filename = "oracle_training_data_e25.txt"
    requested_num_lines = 100
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:n:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-n":
            requested_num_lines = int(a)
        elif o == "-h":
            print "Usage: python line_picker.py [-i <input_filename>] [-n <requested_num_lines>] [-h]"
            exit()
    
    lp = LinePicker()
    lp.pick(input_filename, requested_num_lines)
