import pickle, getopt, sys
from exponential_error_buckets import ExponentialErrorBuckets
import math

MAX_BUCKETS=35 # keep synced with produce_offline_reachtime_exponentialerror_table.py
MAX_BUDGET_INTERVAL=850
MIN_TX_BYTES=84

exp_error_buckets = ExponentialErrorBuckets()

def get_tx_bytes(window_size):
    header_size = 32
    timestamp_size = 4 #4 byte timestamp of the first sample in the window
    payload_size = 9 #one byte differential time from timestamp. So delay can go up to 256 
    const = 10

    return math.ceil( (header_size + timestamp_size + window_size*payload_size + const)/42.0 )*42.0


def get_expected_error_for_budget(table, budget):
    count = table[budget]
    total_count = sum(count)

    # print budget, count


    if total_count == 0:
        return 0.0

    expected_error=0.0
    
    for i in range(0, len(table[budget])-1):
        #bucket=i+1
        bucket = i

        (error_range_start, error_range_end) = exp_error_buckets.get_error_range_from_bucket(bucket)
        middle_of_error_bucket = (error_range_start + error_range_end)/2
        
        expected_error += middle_of_error_bucket*(float(count[i])/float(total_count))

    return expected_error



def get_interpolated_tx_bytes(delay, budget_interval):
    #print MIN_TX_BYTES + (get_tx_bytes(delay) - MIN_TX_BYTES)*(float(MAX_BUDGET_INTERVAL-budget_interval)/float(MAX_BUDGET_INTERVAL))
    return MIN_TX_BYTES + (get_tx_bytes(delay) - MIN_TX_BYTES)*(float(MAX_BUDGET_INTERVAL-budget_interval)/float(MAX_BUDGET_INTERVAL))

    



def write_all_expected_errors_pickle(table, output_file, output_file_bytessec, delay):
    if not table:
        return

    expected_buckets = []
    expected_buckets_bytessec = []
    for budget in range(1, MAX_BUDGET_INTERVAL):
        expected_error = 0.0
        #budget_bytes_sec = get_tx_bytes(delay)/budget

        #if budget > delay:
        #    expected_error = get_expected_error_for_budget(table, budget-1)
        #    #budget_bytes_sec = get_interpolated_tx_bytes(delay, budget-1)/(budget)
        #    budget_bytes_sec = 84.0/(budget)

        expected_error = get_expected_error_for_budget(table, budget-1)
        #budget_bytes_sec = get_tx_bytes(delay)/(budget+1)
        budget_bytes_sec = 84.0/budget
        #print budget, budget_bytes_sec, expected_error

        expected_buckets.append(expected_error)
        expected_buckets_bytessec.append((budget_bytes_sec,expected_error))
        

    pickle.dump(expected_buckets, output_file)
    pickle.dump(expected_buckets_bytessec, output_file_bytessec)


    return (expected_buckets, expected_buckets_bytessec)


def write_all_expected_errors(table, table_bytessec, output_file, output_file_bytessec):
    if not table or not table_bytessec:
        return


    for i in range(0, len(table)):
        budget=i
        expected_error = table[i]
        output_file.write(str(budget)+" "+str(expected_error)+"\n")

    for i in range(0, len(table_bytessec)):
        budget=table_bytessec[i][0]
        expected_error = table_bytessec[i][1]
        output_file_bytessec.write(str(budget)+" "+str(expected_error)+"\n")





usage="Usage: python produce_offline_exponentialerror_expected_budget_table -i <expected budget exponential error pickle file> -o <expected budget data file> -p <expected budget pickle file> [-h]"

input_file = ""
output_file = ""
output_file_pickle = ""

output_file_bytessec = ""
output_file_bytessec_pickle = ""

delay = ""

try:
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:b:p:q:d:h")
except:
    print usage 

for o,a in opts:
    if o == "-i":
        input_file = str(a)
    elif o == "-o":
        output_file = str(a)
    elif o == "-b":
        output_file_bytessec = str(a)
    elif o == "-p":
        output_file_pickle = str(a)
    elif o == "-q":
        output_file_bytessec_pickle = str(a)
    elif o == '-d':
        delay = int(a)
    elif o == "-h":
        print usage 
        exit()
    



f = open(input_file, "rb")
error_budget_table = pickle.load(f)
f.close()





if output_file_pickle != "":
    fp = open(output_file_pickle, "w")
    fp_bytessec = open(output_file_bytessec_pickle, "w")
    tables = write_all_expected_errors_pickle(error_budget_table, fp, fp_bytessec, delay)
    fp.close()
    fp_bytessec.close()


if output_file != "":
    fo = open(output_file, "w")
    fo_bytessec = open(output_file_bytessec, "w")
    write_all_expected_errors(tables[0], tables[1], fo, fo_bytessec)
    fo.close()
    fo_bytessec.close()

