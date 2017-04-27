import os
import gzip
from glob import glob
import math

debug = False


class TableCreator:
    def __init__(self, offline_extrapolator_table, offline_compression_table):
        self.extrapolator_table = self.load_offline_table_txt(offline_extrapolator_table)
        self.compression_table = self.load_offline_table_txt(offline_compression_table)

    
    def load_offline_table_txt(self, offline_table_file):

        if(offline_table_file == None):
            return None
        else:
            f = open(offline_table_file, "r")
            offline_table = f.readlines()
            
            offline_table_list = []
            
            for line in offline_table:
                data=line.rstrip("\n").split(" ")
                data_float = map(lambda x: float(x), data)
                
                offline_table_list.append(tuple(data_float))
                
            #print offline_table_list
            return offline_table_list
    


    def get_interpolated_value(self, x1, x2, y1, y2, x):
        return y1 + (y2 - y1)*((x-x1)/(x2-x1))



    def run(self, output_filename):
        if output_filename == None:
            return

        output_file=open(output_filename, 'w')

        for i in range(len(self.extrapolator_table)):
            duration, error = self.extrapolator_table[i]

            for i in range(len(self.compression_table)):
                if error < self.compression_table[i][0]:
                    break

            
            cost_first = self.compression_table[i-1][4]
            cost_second = self.compression_table[i][4]
                
            error_first = self.compression_table[i-1][0]
            error_second = self.compression_table[i][0]
            
        
            expected_cost = self.get_interpolated_value(error_first, error_second, cost_first, cost_second, error)
            #error_first + (error_second - error_first)*((t-time_first)/(time_second-time_first))

            output_file.write(str(error)+" "+str(duration)+" "+str(expected_cost)+"\n")


        output_file.close()



    def write_list_to_file(self, lst, output_file):
        for element in lst:
            max_error, mean_error = element
            output_file.write(str(max_error)+" "+str(mean_error)+"\n")



 

import sys, getopt

if __name__ == "__main__":
    
    extrapolator_filename = ""
    compressor_filename = ""
    output_filename = ""

    
    (opts, args) = getopt.getopt(sys.argv[1:],"e:c:o:h")
    
    for o,a in opts:
        if o == "-e":
            extrapolator_filename = str(a)
        elif o == "-c":
            compressor_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-h":
            print "Usage: python produce_extrapolator_compressor_table [-e extrapolator_file_name] [-c compressor_file_name] [-o output_file_name] [-h]"
            exit()
            
    if extrapolator_filename == "" or compressor_filename == "" or output_filename=="":
        print "Usage: python produce_extrapolator_compressor_table [-e extrapolator_file_name] [-c compressor_file_name] [-o output_file_name] [-h]"
        exit()
    
    
    tableCreator = TableCreator(extrapolator_filename, compressor_filename)
    
    tableCreator.run(output_filename)
    
    
