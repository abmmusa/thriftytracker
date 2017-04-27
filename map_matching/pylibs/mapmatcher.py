from viterbi import Viterbi
from rtree import Rtree

class MapMatcher(GPSMatcher):
    def __init__(self, hmm, emission_probability=None, EMISSION_SIGMA=75, STEP=0.1, constraint_length=10):        

        def default_emission_probability(edge, coord):
            if(state=='unknown'):
                return EMISSION_UNKNOWN
            distance = distance_to_segment(edge,coord)
            if(int(distance) >= 3 * EMISSION_SIGMA):
                return 0            
            return emission_probabilities[distance/STEP]

        if emission_probability == None:
            # precompute probability table
            emission_probabilities = map(lambda x: complementary_normal_distribution_cdf(x,0,EMISSION_SIGMA), 
                                         range(0,int(3.0*EMISSION_SIGMA/STEP)))
            emission_probability = default_emission_probability
        
    def hmm_from_map(self, road_map):
        pass
