import cPickle as pickle
from sklearn import tree
import sys

class OracleTreePickler:
    def __init__(self):
        pass
    
    def create(self, input_filename, output_filename, tree_max_depth):
        features, classes = self._get_features_and_classes(input_filename)
        
        clf = tree.DecisionTreeClassifier(max_depth=tree_max_depth)
        trained_tree = clf.fit(features, classes)
        
        tree_pickle_file = open(output_filename, 'w')
        pickle.dump(trained_tree, tree_pickle_file)
        tree_pickle_file.close()
    
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
    tree_max_depth = 5
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:d:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-d":
            tree_max_depth = int(a)
        elif o == "-h":
            print "Usage: python oracle_tree_pickles.py [-i <input_filename>] [-o <output_filename>] [-d <tree_max_depth>] [-h]"
            exit()
    
    otp = OracleTreePickler()
    otp.create(input_filename, output_filename, tree_max_depth)
