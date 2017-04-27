from pybrain.datasets import SupervisedDataSet
from pybrain.supervised.trainers import BackpropTrainer
from pybrain.structure import LinearLayer, SigmoidLayer, TanhLayer, SoftmaxLayer
from neural_network import NeuralNetwork
import cPickle as pickle
import warnings

class OracleNeuralNetworkPickler:
    def __init__(self):
        warnings.filterwarnings('error')
    
    def create(self, input_filename, output_filename, num_training_epochs, hidden_layer_multiplier, hidden_layer_type, out_layer_type):
        #print "num_training_epochs: " + str(num_training_epochs)
        #print "hidden_layer_multiplier: " + str(hidden_layer_multiplier)
        #print "hidden_layer_type: " + str(hidden_layer_type)
        #print "out_layer_type: " + str(out_layer_type)
        
        supervised_dataset = self._get_supervised_dataset(input_filename)
        #print "len(supervised_dataset): " + str(len(supervised_dataset['input']))
        
        if (hidden_layer_type == 0):
            hidden_layer = LinearLayer
        elif (hidden_layer_type == 1):
            hidden_layer = SigmoidLayer
        elif (hidden_layer_type == 2):
            hidden_layer = TanhLayer
        elif (hidden_layer_type == 3):
            hidden_layer = SoftmaxLayer
        else:
            print "ERROR!! Invalid hidden_layer_type: " + str(hidden_layer_type)
            exit()
        
        if (out_layer_type == 0):
            out_layer = LinearLayer
        elif (out_layer_type == 1):
            out_layer = SigmoidLayer
        elif (out_layer_type == 2):
            out_layer = TanhLayer
        elif (out_layer_type == 3):
            out_layer = SoftmaxLayer
        else:
            print "ERROR!! Invalid out_layer_type: " + str(out_layer_type)
            exit()
        
        try:
            neural_network = NeuralNetwork(supervised_dataset.indim, (supervised_dataset.indim * hidden_layer_multiplier), supervised_dataset.outdim, hidden_layer, out_layer)
            
            trainer = BackpropTrainer(neural_network, supervised_dataset) #, verbose=True)
            trainer.trainEpochs(num_training_epochs)
        except Exception as e:
            print "ERROR!! Exception thrown during Neural Network building and training: " + str(e)
            print ""
            print "debug information"
            print "-----------------"
            print "hidden_layer_type: " + str(hidden_layer_type)
            print "out_layer_type: " + str(out_layer_type)
            exit()
        
        #print "training input: " + str(supervised_dataset['input'][0])
        #print "training target: " + str(supervised_dataset['target'][0])
        
        #predicted_target = neural_network.activate(supervised_dataset['input'][0])
        #print "predicted target: " + str(predicted_target)
        
        #predicted_class = neural_network.predict(supervised_dataset['input'][0])
        #print "predicted class: " + str(predicted_class)
        
        neural_network_pickle_file = open(output_filename, 'w')
        pickle.dump(neural_network, neural_network_pickle_file)
        neural_network_pickle_file.close()
    
    def _get_supervised_dataset(self, input_filename):
        fc_file = open(input_filename, 'r')
        
        supervised_dataset = None
        
        for sample in fc_file:
            sample_components = sample.strip("\n").split(" ")
            class_values = map(lambda x: [int(x[0]), float(x[1])], map(lambda y: y.split(","), sample_components[6:]))
            
            max_extrapolator_index = max(map(lambda x: x[0], class_values))
            class_distribution = [0.0] * (max_extrapolator_index + 1)
            
            for i in range(0, len(class_values)):
                class_distribution[class_values[i][0]] = class_values[i][1]
            
            if (supervised_dataset is None):
                supervised_dataset = SupervisedDataSet(6, len(class_distribution))
            
            supervised_dataset.addSample(map(lambda x: float(x), sample_components[:6]), class_distribution)
        
        fc_file.close()
        
        return supervised_dataset

import sys, getopt
if __name__ == "__main__":
    input_filename = "oracle_training_data_e25.txt"
    output_filename = "oracle_neural_network_e25.pkl"
    num_training_epochs = 20
    hidden_layer_multiplier = 2
    hidden_layer_type = 1
    out_layer_type = 0
    
    (opts, args) = getopt.getopt(sys.argv[1:],"i:o:e:m:t:u:h")
    
    for o,a in opts:
        if o == "-i":
            input_filename = str(a)
        elif o == "-o":
            output_filename = str(a)
        elif o == "-e":
            num_training_epochs = int(a)
        elif o == "-m":
            hidden_layer_multiplier = int(a)
        elif o == "-t":
            hidden_layer_type = int(a)
        elif o == "-u":
            out_layer_type = int(a)
        elif o == "-h":
            print "Usage: python oracle_neural_network_pickler.py [-i <input_filename>] [-o <output_filename>] [-e <num_training_epochs>] [-m <hidden_layer_multiplier>] [-t <hidden_layer_type>] [-u <out_layer_type>] [-h]"
            exit()
    
    onnp = OracleNeuralNetworkPickler()
    onnp.create(input_filename, output_filename, num_training_epochs, hidden_layer_multiplier, hidden_layer_type, out_layer_type)
