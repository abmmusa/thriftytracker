from multilevel_tree import MultilevelDecisionTreeClassifier
import cPickle as pickle
from sklearn import tree
import sys

class OracleTreePickler:
    def __init__(self):
        pass
    
    def create(self, input_filename, output_filename, top_level_tree_max_depth, subordinate_tree_max_depth):
        features, classes = self._get_features_and_classes(input_filename)
        
        top_level_tree_features, top_level_tree_classes, subordinate_features_and_classes = self._remap_and_partition_features_and_classes(features, classes)
        
        mlt = MultilevelDecisionTreeClassifier(top_level_tree_max_depth, subordinate_tree_max_depth)
        mlt.fit_top_level_tree(top_level_tree_features, top_level_tree_classes)
        
        for top_level_class in subordinate_features_and_classes:
            subordinate_features, subordinate_classes = map(lambda x: x[0], subordinate_features_and_classes[top_level_class]), map(lambda x: x[1], subordinate_features_and_classes[top_level_class])
            mlt.fit_subordinate_tree(top_level_class, subordinate_features, subordinate_classes)
        
        tree_pickle_file = open(output_filename, 'w')
        pickle.dump(mlt, tree_pickle_file)
        tree_pickle_file.close()
    
    def _remap_and_partition_features_and_classes(self, features, classes):
        top_level_tree_classes = list(classes)
        subordinate_features_and_classes = {0:[], 1:[]}
        
        for i in range(0, len(classes)):
            
            if (classes[i] >= 0 and classes[i] <= 3):
                top_level_tree_classes[i] = 0
                subordinate_features_and_classes[0].append((features[i], classes[i]))
            
            elif (classes[i] >= 4 and classes[i] <= 11):
                top_level_tree_classes[i] = 1
                subordinate_features_and_classes[1].append((features[i], classes[i]))
        
        return features, top_level_tree_classes, subordinate_features_and_classes
    
    def _get_features_and_classes(self, input_filename):
        fc_file = open(input_filename, 'r')
        
        features = []
        classes = []
        
        for sample in fc_file:
            sample_components = sample.strip("\n").split(" ")
            
            features.append(map(lambda x: float(x), sample_components[:-1]))
            classes.append(int(sample_components[-1]))
        
        fc_file.close()
        
        return features, classes

import sys, getopt
if __name__ == "__main__":
    input_filename = "oracle_training_data_e25_for_split_0.txt"
    output_filename = "oracle_tree_e25_for_split_0.pkl"
    top_level_tree_max_depth = 5
    subordinate_tree_max_depth = 5
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:t:s:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-t":
            top_level_tree_max_depth = int(a)
        elif o == "-s":
            subordinate_tree_max_depth = int(a)
        elif o == "-h":
            print "Usage: python oracle_tree_pickles.py [-i <input_filename>] [-o <output_filename>] [-t <top_level_tree_max_depth>] [-s <subordinate_tree_max_depth>] [-h]"
            exit()
    
    otp = OracleTreePickler()
    otp.create(input_filename, output_filename, top_level_tree_max_depth, subordinate_tree_max_depth)
