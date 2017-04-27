from sklearn import tree
import gzip
import sys

import cPickle as pickle

class MachineLearningTestbench:
    def __init__(self):
        pass
    
    def evaluate_one(self, training_data_filename, testing_data_filename, output_folder, dt_max_depth=5):
        training_data_mode = training_data_filename[(training_data_filename.rfind("_") + 1) : training_data_filename.rfind(".")]
        #print "training_data_mode: " + str(training_data_mode)
        
        results_file = open(str(output_folder) + "/ml_testbench_results_" + str(training_data_mode) + "_dt" + str(dt_max_depth) + ".txt", 'w')
        output_file = gzip.open(str(output_folder) + "/ml_testbench_output_" + str(training_data_mode) + "_dt" + str(dt_max_depth) + ".txt.gz", 'w')
        
        training_features, training_classes = self._get_features_and_classes(training_data_filename)
        testing_features, testing_classes = self._get_features_and_classes(testing_data_filename)
        
        self._evaluate(dt_max_depth, training_features, training_classes, testing_features, testing_classes, results_file, output_file)
        
        results_file.write("\n")
        results_file.close()
        output_file.close()
    
    def evaluate_all(self, input_folder="oracle_training_data/osm2/all/subjects_8_63/", output_folder="oracle_training_data/osm2/all/", mode="e25", dt_max_depth=5):
        results_filename = str(output_folder) + "/ml_testbench_results_" + str(mode) + "_dt" + str(dt_max_depth) + ".txt"
        output_filename = str(output_folder) + "/ml_testbench_output_" + str(mode) + "_dt" + str(dt_max_depth) + ".txt"
        
        results_file = open(results_filename, 'w')
        #output_file = open(str(output_folder) + "/ml_testbench_output_" + str(mode) + "_dt" + str(dt_max_depth) + ".txt", 'w')
        
        for i in range(8, 63):
            training_range = range(8, i + 1)
            testing_range = range(i + 1, 64)
            
            #print "training range: " + str(training_range[0]) + " - " + str(training_range[-1])
            #print "testing range: " + str(testing_range[0]) + " - " + str(testing_range[-1])
            
            all_training_features = []
            all_training_classes = []
            
            for j in training_range:
                curr_training_features, curr_training_classes = self._get_features_and_classes(str(input_folder) + "/oracle_training_data_" + str(mode) + "_i" + str(j) + ".txt")
                
                all_training_features.extend(curr_training_features)
                all_training_classes.extend(curr_training_classes)
            
            all_testing_features = []
            all_testing_classes = []
            
            for j in testing_range:
                curr_testing_features, curr_testing_classes = self._get_features_and_classes(str(input_folder) + "/oracle_training_data_" + str(mode) + "_i" + str(j) + ".txt")
                
                all_testing_features.extend(curr_testing_features)
                all_testing_classes.extend(curr_testing_classes)
            
            #print "training set: " + str(len(all_training_features)) + " samples."
            #print "testing set: " + str(len(all_testing_features)) + " samples."
            
            self._evaluate(dt_max_depth, all_training_features, all_training_classes, all_testing_features, all_testing_classes, results_file)
            
            results_file.close()
            results_file = open(results_filename, 'a')
        
        results_file.write("\n")
        results_file.close()
        #output_file.close()
    
    def _evaluate(self, dt_max_depth, training_features, training_classes, testing_features, testing_classes, results_file, output_file=None):
        clf = tree.DecisionTreeClassifier(max_depth=dt_max_depth)
        
        #mlt_file = open("oracle_training_data/osm2/all/subjects_8_15/oracle_multilevel_tree_e25.pkl", 'r')
        #mlt = pickle.load(mlt_file)
        #mlt_file.close()
        
        trained_clf = clf.fit(training_features, training_classes)
        testing_class_predictions = trained_clf.predict(testing_features)
        #testing_class_predictions = mlt.predict(testing_features)
        
        num_correct_testing_class_predictions = 0
        
        for i in range(0, len(testing_classes)):
            if (output_file is not None):
                output_file.write(str(" ".join(map(lambda x: str(x), testing_features[i]))) + " " + str(testing_classes[i]) + " " + str(testing_class_predictions[i]) + "\n")
            
            if (testing_classes[i] == testing_class_predictions[i]):
                num_correct_testing_class_predictions += 1
        
        testing_class_prediction_accuracy = (num_correct_testing_class_predictions / float(len(testing_features)))
        
        results_file.write("%.10f " % testing_class_prediction_accuracy)
    
    def _get_features_and_classes(self, dataset_filename):
        dataset = open(dataset_filename, 'r')
        
        features = []
        classes = []
        
        for sample in dataset:
            sample_components = sample.strip("\n").split(" ")
            
            features.append(map(lambda x: float(x), sample_components[:-1]))
            classes.append(int(sample_components[-1]))
        
        dataset.close()
        
        return features, classes

import sys, getopt
if __name__ == "__main__":
    training_data_filename = "oracle_training_data/osm2/all/subjects_8_15/oracle_training_data_e25.txt"
    testing_data_filename = "oracle_training_data/osm2/all/subjects_16_63/oracle_training_data_e25.txt"
    output_folder = "oracle_training_data/osm2/all/"
    dt_max_depth = 5
    
    (opts, args) = getopt.getopt(sys.argv[1:],"r:s:o:d:h")
    
    for o,a in opts:
        if o == "-r":
            training_data_filename = str(a)
        elif o == "-s":
            testing_data_filename = str(a)
        elif o == "-o":
            output_folder = str(a)
        elif o == "-d":
            dt_max_depth = int(a)
        elif o == "-h":
            print "Usage: python ml_testbench.py [-r <training_data_filename>] [-s <testing_data_filename>] [-o <output_folder>] [-d <dt_max_depth>] [-h]"
            exit()
    
    #print "training_data_filename: " + str(training_data_filename)
    #print "testing_data_filename: " + str(testing_data_filename)
    #print "output_folder: " + str(output_folder)
    #print "dt_max_depth: " + str(dt_max_depth) + "\n"
    
    mlt = MachineLearningTestbench()
    mlt.evaluate_one(training_data_filename, testing_data_filename, output_folder, dt_max_depth)
