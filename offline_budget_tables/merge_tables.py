import sys, getopt, os
from glob import glob
import pickle

MAX_BUCKETS=35 # keep synced with produce_offline_reachtime_exponentialerror_table.py

debug=True

class TableMerger:
    def __init__(self):
        self.time_error_table = None # NOTE: row 0 is for budget interval 1 and so on...
        
    def init_time_error_table(self, size):
        time_error_table = [[0 for x in range(MAX_BUCKETS)] for x in range(size)]
        self.time_error_table = time_error_table
    

    def run(self, tables_dir):
        files=[]
        
        if (tables_dir == "None"):
            return
        elif (tables_dir.endswith(".pkl")):
            files = [tables_dir]
        else:
            for path,_,_ in os.walk(tables_dir):
                files.extend(glob(os.path.join(path,"*.pkl")))
        
        table_init_done=False
        for f in files:
            if (debug):
                print f
            
            table_data = pickle.load(open(f))
            
            if not table_init_done:
                self.init_time_error_table(len(table_data))
                table_init_done = True


            for i in range(len(table_data)):
                for j in range(MAX_BUCKETS):
                    self.time_error_table[i][j] += table_data[i][j]
                
            


if __name__ == "__main__":
    
    input_directory = ""
    output_filename = ""
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:w:h:")
    
    for o,a in opts:
        if o == "-i":
            input_directory = str(a)
        elif o == "-o":
            output_filename = str(a)
            time_error_table_pickle_filename = str(a)
        elif o == "-h":
            print "Usage: python merge_tables.py [-i input_directory] [-o output_file_name] [-h]"
            exit()
    
    if input_directory == "" or output_filename=="":
        print "Usage: python merge_tables.py [-i input_directory] [-o output_file_name] [-h]"
        exit()
    
    
    output_file = open(output_filename, 'wb')
    
    tableMerger = TableMerger()
    tableMerger.run(input_directory)

    pickle.dump(tableMerger.time_error_table, output_file)
    output_file.close()
