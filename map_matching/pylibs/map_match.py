#
# Tool for map matching coordinate locations using the Viterbi algorithm.
# Author(s): Tomas Gerlich (tgerli2@uic.edu), James P. Biagioni (jbiagi1@uic.edu)
# Company: University of Illinois at Chicago
# Created: 9/23/11
#

# usage: MapMatch("map_edges.txt","map_edges_connectivity.txt")

from match_lib import *

class MapMatch:
    def __init__(self, edges_filename, edges_connectivity_filename):
        (self.states, self.unknownId) = initializeStatesGeneral(edges_filename)
        self.transitions = initializeTransitionsGeneral(self.states, self.unknownId, edges_connectivity_filename)
    
    def find_most_probable_edge_sequence(self, locations):
        
        # if there are no locations
        if (len(locations) < 1):
            return []
        
        # create storage for observation stream
        observationStream = []
        
        # load raw locations into observation stream
        for location in locations:
            p = timePoint(float(location.time), float(location.latitude), float(location.longitude))
            observationStream.append(p)
        
        # initialize Viterbi algorithm
        VIT_CUTOFF = len(observationStream)
        obsPrev = observationStream[0]
        obsPrevEwma = obsPrev
        obsPrevStopped = obsPrev
        (V, path) = initializeStartProbV(self.states, obsPrev, self.unknownId)
        observationStream.pop(0)
        
        # initialize EWMA angle
        ewmaAngle = -1000
        
        # storage for all observations (real and interpolated)
        all_observations = [[obsPrev.lat, obsPrev.lon, obsPrev.timestamp]]
        
        # iterate through all observations
        for i in range(len(observationStream)):
            
            # grab the current observation
            obsCur = observationStream[i]
            
            # determine observation length EWMA
            obsLenEwma = distanceBetweenGPSPoints(obsPrevEwma.lat, obsPrevEwma.lon, obsCur.lat, obsCur.lon)
            
            # if length is greater than constant value, update EWMA angle
            if(obsLenEwma >= SPACE_BETWEEN_POINTS):
                ewmaAngle = updateEwmaAngle(obsCur, obsPrevEwma, ewmaAngle)
            
            # compute time difference between current and previous observation
            timeDiff = obsCur.timestamp - obsPrev.timestamp
            
            # interpolate points for account for outages in GSM transmissions
            if(timeDiff >= SECONDS_CONNECTION_LOST_LB and timeDiff <= SECONDS_CONNECTION_LOST_UB):
                
                # get interpolated points
                interpolatedPoints = interpolatePointsInTime(obsPrev, obsCur, TIME_INTERVAL_BETWEEN_POINTS)
                interpolatedPoints.pop()
                
                # iterate through all interpolated points
                for seq in range(1, len(interpolatedPoints)):
                    
                    # grab current interpolated point
                    obsCurInter = interpolatedPoints[seq]
                    obsLenInterEwma = distanceBetweenGPSPoints(obsPrevEwma.lat, obsPrevEwma.lon, obsCurInter.lat, obsCurInter.lon)
                    
                    # if distance is greater than constant value, update EWMA angle
                    if(obsLenInterEwma >= SPACE_BETWEEN_POINTS):
                        ewmaAngle = updateEwmaAngle(obsCurInter, obsPrevEwma, ewmaAngle)
                        obsPrevEwma = obsCurInter
                    
                    # increment Viterbi cut-off
                    VIT_CUTOFF += 1
                    
                    # run Viterbi algorithm on current interpolated observation
                    (V, path) = viterbi(V, path, obsCurInter, self.states, self.transitions, self.unknownId, VIT_CUTOFF, ewmaAngle)
                    
                    # store observation
                    all_observations.append([obsCurInter.lat, obsCurInter.lon, obsCurInter.timestamp])
            
            # run Viterbi algorithm on current observation
            (V, path) = viterbi(V, path, obsCur, self.states, self.transitions, self.unknownId, VIT_CUTOFF, ewmaAngle)
            
            # store observation
            all_observations.append([obsCur.lat, obsCur.lon, obsCur.timestamp])
            
            # update previous observation EWMA with current observation
            obsPrevEwma = obsCur
            
            # update previous observation with current observation
            obsPrev = obsCur
        
        # find most probable sequence in Viterbi matrix
        (curMax, indexMax) = findMax(V)
        
        # assert that we have the same number of observations as state emissions
        assert(len(all_observations) == len(path[indexMax]))
        
        # create storage for most probable edge sequence
        most_probable_edge_sequence = []
        
        # iterate through all states in path
        for i in range(0, len(path[indexMax])):
            
            # store state
            most_probable_edge_sequence.append([path[indexMax][i]])
            
            # store observation
            most_probable_edge_sequence[-1].extend(all_observations[i])
        
        # return most probable edge sequence
        return most_probable_edge_sequence
