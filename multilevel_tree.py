import cPickle as pickle
from sklearn import tree

class MultilevelDecisionTreeClassifier:
    def __init__(self, top_level_tree_max_depth=5, subordinate_tree_max_depth=5):
        self.top_level_tree_max_depth = top_level_tree_max_depth
        self.subordinate_tree_max_depth = subordinate_tree_max_depth
        
        self.top_level_tree = tree.DecisionTreeClassifier(max_depth=self.top_level_tree_max_depth)
        self.subordinate_trees = {}
    
    def fit_top_level_tree(self, features, classes):
        self.top_level_tree.fit(features, classes)
        
        for top_level_class in set(classes):
            self.subordinate_trees[top_level_class] = tree.DecisionTreeClassifier(max_depth=self.subordinate_tree_max_depth)
    
    def fit_subordinate_tree(self, top_level_class, features, classes):
        self.subordinate_trees[top_level_class].fit(features, classes)
    
    def predict(self, feature_vectors):
        # if singleton feature vector has not been wrapped in a list (i.e., [0,1,2] instead of [[0,1,2]]), wrap it
        if (isinstance(feature_vectors[0], list) is False):
            feature_vectors = [feature_vectors]
        
        predicted_classes = []
        
        for feature_vector in feature_vectors:
            top_level_class = self.top_level_tree.predict(feature_vector)[0]
            predicted_classes.append(self.subordinate_trees[top_level_class].predict(feature_vector)[0])
        
        return predicted_classes

import sys, getopt
if __name__ == "__main__":
    mlt = MultilevelDecisionTreeClassifier()
