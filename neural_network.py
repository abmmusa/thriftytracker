from pybrain.structure import FeedForwardNetwork
from pybrain.structure import LinearLayer, SigmoidLayer
from pybrain.structure import FullConnection

class NeuralNetwork(FeedForwardNetwork):
    def __init__(self, in_layer_dim, hidden_layer_dim, out_layer_dim, hidden_layer_type=SigmoidLayer, out_layer_type=LinearLayer):
        FeedForwardNetwork.__init__(self)
        
        in_layer = LinearLayer(in_layer_dim)
        hidden_layer = hidden_layer_type(hidden_layer_dim)
        out_layer = out_layer_type(out_layer_dim)
        
        self.addInputModule(in_layer)
        self.addModule(hidden_layer)
        self.addOutputModule(out_layer)
        
        in_to_hidden = FullConnection(in_layer, hidden_layer)
        hidden_to_out = FullConnection(hidden_layer, out_layer)
        
        self.addConnection(in_to_hidden)
        self.addConnection(hidden_to_out)
        
        self.sortModules()
    
    def predict(self, feature_vectors):
        # if singleton feature vector has not been wrapped in a list (i.e., [0,1,2] instead of [[0,1,2]]), wrap it
        if (isinstance(feature_vectors[0], list) is False):
            feature_vectors = [feature_vectors]
        
        predicted_classes = []
        
        for feature_vector in feature_vectors:
            predicted_target = self.activate(feature_vector)
            
            max_prob_value = predicted_target[0]
            max_prob_class = 0
            
            for i in range(1, len(predicted_target)):
                if ((i == 6) or (i == 7)):
                    continue
                
                if (predicted_target[i] >= max_prob_value):
                    max_prob_value = predicted_target[i]
                    max_prob_class = i
            
            predicted_classes.append(max_prob_class)
        
        return predicted_classes
