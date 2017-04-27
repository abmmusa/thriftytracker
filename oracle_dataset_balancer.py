import sys
import random

random.seed(1391638495)

oracle_data_filename = str(sys.argv[1])
print "oracle_data_filename: " + str(oracle_data_filename)

oracle_data = open(oracle_data_filename, 'r')

samples = {}

for sample in oracle_data:
    sample_class = sample.strip("\n").split(" ")[-1]
    
    if (sample_class not in samples):
        samples[sample_class] = []
    
    samples[sample_class].append(sample) #_components)

oracle_data.close()

max_class_size = -1
max_class_label = None

for sample_key in samples:
    curr_class_size = len(samples[sample_key])
    
    if (curr_class_size > max_class_size):
        max_class_size = curr_class_size
        max_class_label = sample_key

print "max_class_size: " + str(max_class_size)
print "max_class_label: " + str(max_class_label) + "\n"

for sample_key in samples:
    curr_class_size = len(samples[sample_key])
    print "inital class_size: " + str(curr_class_size)
    
    while (curr_class_size < max_class_size):
        samples[sample_key].append(samples[sample_key][random.randint(0, curr_class_size - 1)])
        curr_class_size += 1
    
    print "final class_size: " + str(len(samples[sample_key])) + "\n"

balanced_oracle_data = open(str(oracle_data_filename[:oracle_data_filename.rfind(".")]) + "_balanced.txt", 'w')

for sample_key in samples:
    for sample in samples[sample_key]:
        balanced_oracle_data.write(sample)

balanced_oracle_data.close()
