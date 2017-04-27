#Universal library for map matching
import math
import datetime
import sys
import spatialfunclib
import stdNormCDFLib
from viterbi import Viterbi

EMISSION_SIGMA = 75   #controls emission probabilities and should be dependent on GPS error
                      #units: meters
EMISSION_MEAN = 0  #mean for gaussian distribution used to calculate emission probability

DIRECTION_SIGMA = 30

DIRECTION_MEAN = 0

STEP = 0.1  #controls step size for calculating integral in CDF for emissions

#transition probabilities
FROM_PREVIOUS_TO_SELF = 0.95 #0.98
FROM_SELF_TO_SELF = 0.98
FROM_UNKNOWN_TO_SELF = 0.0000025
FROM_STATES_TO_UNKNOWN = 0.0000025  #0.00000025
FROM_UNKNOWN_TO_UNKNOWN = 0.98 #0.7

#start probabilities
START_PROB = 0.3

emission_unknown_index = int(((1*EMISSION_SIGMA-EMISSION_MEAN)/float(EMISSION_SIGMA)) * (1/stdNormCDFLib.STDNORMCDF_STEP_SIZE)) + int((3 / stdNormCDFLib.STDNORMCDF_STEP_SIZE))
EMISSION_UNKNOWN = 1 - ((stdNormCDFLib.standardNormalCDF[emission_unknown_index] - 0.5)*2)

VIT_CUTOFF_DATABASE = 30  #number of timesteps stored in V matrix for offline matching and
                          #storing to a database
VIT_CUTOFF = 1  #number of timesteps stored in V matrix
DECISION_RATIO = 3  #controls when decisions are certain: if max of V matrix is at least "DECISION_RATIO"
                    #times greater than second highest in V matrix

ALPHA_EWMA = 0.80   #constant for exponentially weighted moving average of bearing
FIVE_METERS_IN_DEG = 0.000045  #degree equvialent of 5 meters
SPACE_BETWEEN_POINTS = 20  #points have to be "SPACE_BETWEEN_POINTS" apart to update long-term average ewmaAngle
TIME_INTERVAL_BETWEEN_POINTS = 2  #interval in seconds for interpolation of points
                                  #to account for outages

SECONDS_CONNECTION_LOST_LB = 2   #lower bound
SECONDS_CONNECTION_LOST_UB = 300 #upper bound

#below is specified a bounding box for bus depot
LEFT_LON_BUS_DEPOT = -87.651261
RIGHT_LON_BUS_DEPOT = -87.649625
TOP_LAT_BUS_DEPOT = 41.864875
BOTTOM_LAT_BUS_DEPOT = 41.863275

#location of bus depot
BUS_DEPOT_LAT = 41.863709
BUS_DEPOT_LON = -87.650160

MAX_STOP_DURATION = 600  #maximum number of seconds a bus can be matched to the same segment before
                         #classifiying it as unknown
MIN_SPACE_BETWEEN_POINTS_IF_BUS_NOT_STOPPED = 100  #minimum number of meters points have to be apart to consider them
                                                  #as associated with a moving bus

probTable = {}

state_spatial_index = Rtree()
bb_distance = 600.0 # meters

# define longitude/latitude offset for bounding box
bb_lon_offset = ((bb_distance / 2.0) / spatialfunclib.METERS_PER_DEGREE_LONGITUDE)
bb_lat_offset = ((bb_distance / 2.0) / spatialfunclib.METERS_PER_DEGREE_LATITUDE)

#object to represent transition edges of a Hidden Markov Model
class transitionEdge:
	def __init__(self,sFrom,sTo,value):
		self.sFrom = sFrom
		self.sTo = sTo
		self.value = value

	def __str__(self):
		return "(from: %d, to: %d, value: %f)" %(self.sFrom, self.sTo, self.value)

#object that represents two coordinates
class point:
	def __init__(self,x,y):
		self.x=x
		self.y=y

	def __str__(self):
		return "(%f,%f)" %(self.x, self.y)

#object that represents a timestamp and two coordinates
class timePoint:
	def __init__(self,timestamp,lat,lon):
		self.timestamp = timestamp
		self.lat = lat
		self.lon = lon

	def __str__(self):
		return "(%f,%.20f,%.20f)" %(self.timestamp,self.lat, self.lon)

#object that represents two timestamps
class timestampInterval:
	def __init__(self,timestampFrom,timestampTo):
		self.timestampFrom=timestampFrom
		self.timestampTo=timestampTo

	def __str__(self):
		return "(%f,%f)" %(self.timestampFrom, self.timestampTo)

#object that stores current information about a bus
class busState:
	def __init__(self,V,path,ewmaAngle,obsPrev,obsPrevEwma,obsPrevStopped,tStep):
		self.V = V
		self.path = path
		self.ewmaAngle = ewmaAngle
		self.obsPrev = obsPrev
		self.obsPrevEwma = obsPrevEwma
		self.obsPrevStopped = obsPrevStopped
		self.tStep = tStep
 
#object that represents states in a Hidden Markov Model
class shapeSegment:
	def __init__(self,uniqId,shapeId,seqNum,lat1,lon1,lat2,lon2,cumDistBeg):
		self.uniqId=uniqId
		self.shapeId=shapeId
		self.seqNum=seqNum
		self.lat1=lat1
		self.lon1=lon1
		self.lat2=lat2
		self.lon2=lon2
		self.cumDistBeg=cumDistBeg
    
	def __str__(self):
		return "%d,%d,%d,%f,%f,%f,%f,%f" %(self.uniqId,self.shapeId, self.seqNum, self.lat1, self.lon1, self.lat2, self.lon2,self.cumDistBeg)


#input is a filename that stores waypoints for routes.
#returns array of internal states for markov model. also
#returns unique state id of the "unknown" state
#inserts states to a spatial index state_spatial_index
#input: shapes filename
#output: states hash map (type shapeSegment), id of unknown state (integer)
def initializeStates(shapes_filename):
	try:		
		shapes = open(shapes_filename,'r')
	except IOError:
		print "Unable to open shapes file. Exiting.\n"
		sys.exit(1)
	
	states = {}
	a=[]
	b=[]

	shapes.readline()  #skips file schema
	data = shapes.readlines()
	id=0
	for i in range(1,len(data)):
		str = data[i-1]
		a = str.rstrip().split(",")
		str = data[i]
		b = str.rstrip().split(",")
		if(a[0]==b[0]): #if same shape_ids
			ss=shapeSegment(id,int(b[0]),int(a[3]),float(a[1]),float(a[2]),float(b[1]),float(b[2]),float(a[4]))
			states[id]=ss
			# insert current state into spatial index
			state_spatial_index.insert(ss.uniqId, (min(ss.lon1, ss.lon2), min(ss.lat1, ss.lat2), max(ss.lon1, ss.lon2), max(ss.lat1, ss.lat2)))
			id=id+1

	unknownId = id   #unknownState id
	unknownState = shapeSegment(unknownId,-1,-1,-1,-1,-1,-1,-1)   #unknown state
	states[id] = unknownState
	shapes.close()
	return states,unknownId

#creates a states hash map from a general file in the following format:
#uniqId,lat1,lon1,lat2,lon2
#inserts states to a spatial index state_spatial_index
def initializeStatesGeneral(shapes_filename):
	try:		
		shapes = open(shapes_filename,'r')
	except IOError:
		print "Unable to open shapes file. Exiting.\n"
		sys.exit(1)
	states = {}
	a=[]
	data = shapes.readlines()
	maxId = 0 
	for i in range(len(data)):
		a = data[i].rstrip().split(",")
		ss=shapeSegment(int(a[0]),-1,-1,float(a[1]),float(a[2]),float(a[3]),float(a[4]),-1)
		states[int(a[0])] = ss
		
		# insert current state into spatial index
		state_spatial_index.insert(ss.uniqId, (min(ss.lon1, ss.lon2), min(ss.lat1, ss.lat2), max(ss.lon1, ss.lon2), max(ss.lat1, ss.lat2)))
		
		if (int(a[0]) > maxId):
		    maxId = int(a[0])
		
	unknownId = maxId + 1   #unknownState id
	unknownState = shapeSegment(unknownId,-1,-1,-1,-1,-1,-1,-1)   #unknown state
	states[unknownId] = unknownState
	shapes.close()
	return states,unknownId

#sets up all transitions between states based on probability constants
#returns a hash map of transitions
#input: states hash map (type shapeSegment), id of unknown state (integer)
#output: hash map of transitions (type transition)
def initializeTransitions(states,unknownId):
    states2 = []
    for s in states.values():
	    states2.append(s)
    states2 = sorted(states2,key = lambda ss: ss.uniqId,reverse=True)

    transition = {}

    lastShapeId=-1
    for ss in states2:
        trans = []
        if (ss.uniqId!=unknownId):
            if(ss.uniqId!=0 and lastShapeId==ss.shapeId):
                temp = transitionEdge(ss.uniqId-1,ss.uniqId,FROM_PREVIOUS_TO_SELF)  #transition from previous state
                trans.append(temp)
            temp = transitionEdge(ss.uniqId,ss.uniqId, FROM_SELF_TO_SELF) #transition to itself
            trans.append(temp)
            temp = transitionEdge(unknownId,ss.uniqId,FROM_UNKNOWN_TO_SELF) #transition from unknown state
            trans.append(temp)
        else:
            for s in states2:
                if(s.uniqId!=unknownId):
                    temp = transitionEdge(s.uniqId,unknownId,FROM_STATES_TO_UNKNOWN)
                    trans.append(temp)
                else:
                    temp = transitionEdge(unknownId,unknownId,FROM_UNKNOWN_TO_UNKNOWN)
                    trans.append(temp)
        transition[ss.uniqId]=trans
        lastShapeId = ss.shapeId

    #last state of a route has transition to the first state of a route
    firstOfShapeId = 0
    for i in range(0,len(states2)):
        if(i==len(states2)-1):
            temp = transitionEdge(states2[i].uniqId,firstOfShapeId,FROM_PREVIOUS_TO_SELF)
            transition[firstOfShapeId].append(temp)
            break
        if(states2[i].shapeId != states2[i+1].shapeId):
            temp = transitionEdge(states2[i].uniqId,firstOfShapeId,FROM_PREVIOUS_TO_SELF)
            transition[firstOfShapeId].append(temp)
            firstOfShapeId = states2[i+1].uniqId

    return transition

#sets up all transitions between states based on probability constants
#returns a hash map of transitions
#input: states hash map (type shapeSegment), id of unknown state (integer),transitions_filename with specified transitions
#in the following format:
#uniqIdToState,uniqIdFromState1,uniqIdFromState2,uniqIdFromState3,...
#output: hash map of transitions (type transition)
def initializeTransitionsGeneral(states,unknownId,transitions_filename):
	try:		
		transitionFile = open(transitions_filename,'r')
	except IOError:
		print "Unable to open transitions file. Exiting.\n"
		sys.exit(1)    
	transition = {}
	transData = transitionFile.readlines()
	for t in transData:
		rec = t.rstrip().split(",")
		trans = []
		for i in range(1,len(rec)):
			temp = transitionEdge(int(rec[i]),int(rec[0]),FROM_PREVIOUS_TO_SELF)  #transition from previous state
		        trans.append(temp)
		temp = transitionEdge(int(rec[0]),int(rec[0]),FROM_SELF_TO_SELF)  #transition to itself
		trans.append(temp)
		temp = transitionEdge(int(unknownId),int(rec[0]),FROM_UNKNOWN_TO_SELF)  #transition from unknown state
		trans.append(temp)
		transition[int(rec[0])] = trans
	trans = []
	for s in states.values():
                if(s.uniqId!=unknownId):
                    temp = transitionEdge(s.uniqId,int(unknownId),FROM_STATES_TO_UNKNOWN)
                    trans.append(temp)
                else:
                    temp = transitionEdge(int(unknownId),int(unknownId),FROM_UNKNOWN_TO_UNKNOWN)
                    trans.append(temp)
	transition[int(unknownId)]=trans
	return transition

#returns a matrix V used for viterbi algorithm with initial
#values determined based on first observation and apriori
#start probability. path is also returned.
#input: states hash map (type shapeSegment), observation (type timePoint), id of the unknown state
#output: V matrix, path matrix
def initializeStartProbV(states,observation,unknownId):
    start_prob={}
    for ss in states.values():
        start_prob[ss.uniqId] = START_PROB
    
    V = [{}]
    path = {}
    
    for ss in states.values():
        V[0][ss.uniqId] = start_prob[ss.uniqId] * ss.emissionProb(observation,unknownId,-1000)
        path[ss.uniqId]=[ss.uniqId]
    
    return V, path

#creates a .kml file that can be opened by Google Earth that shows a stream
#of points with colors denoting decisions made by the map matching algorithm
def createObservKml(kmlFilename,points, colors):
	kml = open(kmlFilename,'w')
	kml.write('<?xml version="1.0" encoding="UTF-8"?>\n<kml xmlns="http://earth.google.com/kml/2.2">\n')
	kml.write('\t<Document>\n')
	for i in range(0,len(colors)):
		kml.write('\t\t<Style id="%d"><IconStyle><color>%s</color><Icon><href>http://maps.google.com/mapfiles/kml/paddle/wht-blank.png</href></Icon></IconStyle></Style>\n' %(i,colors[i]))
	kml.write('\t\t<name>Paths</name>\n')	
	
	for i in range(0,len(points)):
		kml.write('\t\t\t<Placemark><name>%d</name><styleUrl>#%d</styleUrl><Point><coordinates>%.6f,%.6f</coordinates></Point></Placemark>\n' %(i,i,points[i].lon,points[i].lat))
	kml.write('\t</Document>\n')
	kml.write('</kml>')
        return

#returns a color coded in hexadecimal. this color will be used
#for display in Google Earth.
def getColorCode(shapeId):
    if(shapeId == 101): #red
        colorCode = '0000ff'
    elif(shapeId == 102): #purple
        colorCode = 'f020a0'
    elif(shapeId == 103): #blue
        colorCode = 'ff0000'
    elif(shapeId == 104): #yellow 
        colorCode = '00ffff'
    elif(shapeId == 105): #pink
        colorCode = 'CC99FF'
    elif(shapeId == 106): #light blue
        colorCode = 'FFFF99'
    elif(shapeId == 107): #brown
        colorCode = '000099'
    elif(shapeId=='ambiguous'): #grey
        colorCode = 'bebebe'
    elif(shapeId=='unknown'): #black
        colorCode = '000000'
    else: #white
        colorCode = 'ffffff'
    
    return colorCode

#returns an array of maximum probabilities for each shape id. For each entry
#of a particular shape id in matrix V, it finds the current maximum. This value
#is used for classification. The highest the value, the better confidence in the
#classification.
def generateMaximums(V,states,unknownId):
	maximums = []
	uniqShapeIds = []
	t = len(V)-1

	for s in states.values():
		if(s.shapeId not in uniqShapeIds and s.uniqId != unknownId):
			uniqShapeIds.append(s.shapeId)
	for s_id in uniqShapeIds:
		curMax,indexMax = findMaxShape(V,states,s_id,1)
		maximums.append((curMax,s_id))
	maximums.append((V[t][unknownId],-100))
	return maximums



#maxes a decision to which route a bus corresponds given the maximum
#values in the V matrix. (see generateMaximums() above)
def decideShape(maximums):
	greaterThanAll = 1
	
	for i in range(len(maximums)):
		for j in range(len(maximums)):
			if(i==j):
				continue
			other = maximums[j][0]
			if(other == 0):
				other = 0.001
			if(maximums[i][0]/other < DECISION_RATIO):
				greaterThanAll = 0

		if(greaterThanAll==1):
			if(maximums[i][1]==-100):
				return 'unknown'
			else:
				return maximums[i][1]
		greaterThanAll = 1	

	return 'ambiguous'

#returns 'unknown' if it is not possible for the given shapeId
#to operate at the current time according to the schedule. Otherwise
#the input parameter shapeId is unchanged.
def checkTimeSchedule(shapeId, timestamp = -1):
    if(timestamp == -1):
        day = datetime.datetime.now().weekday()   #Monday is 0, Sunday is 6
        hour = datetime.datetime.now().hour  #range(24)
        minute = datetime.datetime.now().minute  #range(60)
    else:
        day = datetime.datetime.fromtimestamp(timestamp).weekday()
        hour = datetime.datetime.fromtimestamp(timestamp).hour
        minute = datetime.datetime.fromtimestamp(timestamp).minute

    if(shapeId == 101):
       	if(day == 5 or day == 6):
            return 'unknown'
       	if((hour >= 18) or (hour <= 6 and minute <= 45) or hour <= 5):
            return 'unknown'
    if(shapeId == 102):
       	if(day >= 0 and day <= 4):
            return 'unknown'
       	if((hour >= 23 and minute > 30) or (hour <= 6 and minute <= 45) or hour <= 5):
            return 'unknown'
    if(shapeId == 103):
       	if(day == 5 or day == 6):
            return 'unknown'
        if((hour >= 23 and minute > 30) or (hour <= 6 and minute <= 45) or hour <= 5 or (hour >= 9 and hour < 14)):
            return 'unknown'
    if(shapeId == 104):
       	if(day == 5 or day == 6):
            return 'unknown'
       	if((hour >= 15 and minute > 45) or hour >= 16 or (hour <= 6 and minute <= 45)):
            return 'unknown'
    if(shapeId == 105):
       	if(day == 5 or day == 6):
            return 'unknown'
       	if((hour >= 23 and minute > 30) or (hour < 18)):
            return 'unknown'
    if(shapeId == 106):
       	if(day == 5 or day == 6):
            return 'unknown'
       	if((hour >= 14 and minute > 35) or hour >= 15 or hour < 9):
            return 'unknown'

    return shapeId

#returns the current maximum at the n(th) layer of the V matrix, counting backwards from the most recent
#layer (e.g. for the last layer in V matrix, the n(th) index would be 1, for the next to last layer it
#would be 2, etc.
#returns also to which index in the table the maximum corresponds
def findMax(V,n=1):
    curMax = -1
    indexMax = -1
    t = len(V)-n

    for i in V[t].keys():
        if(V[t][i] > curMax):
            curMax = V[t][i]
            indexMax = i

    return curMax, indexMax

#finds maximum value in the V matrix for a particular shapeId. parameter n specifies which
#layer of the V matrix to use for these computations. Counting backwards from the last layer,
#n=1 specifies the last layer, n=2 specifies the seconds to last layer, etc.
def findMaxShape(V,states,shapeId,n=1):
	curMax = -1
	indexMax = -1
	t = len(V) - n

	for i in V[t].keys():
		if(V[t][i] > curMax and states[i].shapeId == shapeId):
			curMax = V[t][i]
			indexMax = i

	return curMax, indexMax

#used for debugging, prints values in matrix V that
#are greater than 0. cutoff specifies how many last
#columns of V will be printed. Used for debugging.
def printRelevantV(V,cutoff,states):
    total = 0
    for i in range(len(V)-cutoff,len(V)):
        print "V column: " + str(i+1) 
	for j in V[i].keys():
            if(V[i][j] > 0):
                total += V[i][j]
                print "shape: " + str(states[j].shapeId) + " state: " + str(j) + " likelihood: " + str(V[i][j])
        print "sum of likelihoods: " + str(total) + "\n"
        total = 0
    return

#returns updated exponential moving average of direction of travel.
def updateEwmaAngle(observationCurrent,observationPrevious,ewmaAngle):
	obsLat = observationCurrent.lat-observationPrevious.lat
	obsLon = observationCurrent.lon-observationPrevious.lon
	obsLen = vectorLen(obsLat,obsLon)
	if(obsLen == 0 or obsLat == 0):
		return ewmaAngle
	bearing = spatialfunclib.path_bearing(observationPrevious.lat, observationPrevious.lon, observationCurrent.lat, observationCurrent.lon)
	if(ewmaAngle == -1000):
		return bearing		
	else:
		angleAbs = math.fabs(bearing-ewmaAngle)
		if(angleAbs > 180):
			angleClosest = 360 - angleAbs
		else:
			angleClosest = angleAbs
		if(bearing-ewmaAngle >= 180):
			newEwmaAngle = ewmaAngle - ALPHA_EWMA * (angleClosest)
		elif((bearing-ewmaAngle) >= 0 and (bearing-ewmaAngle) < 180):
			newEwmaAngle = ewmaAngle + ALPHA_EWMA * (angleClosest)
		elif((bearing-ewmaAngle) < 0 and (bearing-ewmaAngle) > -180):
			newEwmaAngle = ewmaAngle - ALPHA_EWMA * (angleClosest)
		elif((bearing-ewmaAngle) < 0 and (bearing-ewmaAngle) <= -180):
			newEwmaAngle = ewmaAngle + ALPHA_EWMA * (angleClosest)
		if(newEwmaAngle > 360):
			newEwmaAngle -= 360
		elif(newEwmaAngle < 0):
			newEwmaAngle += 360
	return newEwmaAngle

#converts a raw trace to a trace with evenly spaced lat,lon points that are
#exactly SPACING meters apart.
#input: shape array with objects of type "point", and spacing constant in meters
#output: array of type "point"
def produceEvenTrace(shapeIn, SPACING):
	shapeOut = []
	obsPrev = shapeIn[0]
	shapeOut.append(obsPrev)
	i = 1
	while(i < len(shapeIn)):
		obsCur = shapeIn[i]
		distance = distanceBetweenGPSPoints(obsPrev.x,obsPrev.y,obsCur.x,obsCur.y)
       		if(distance > SPACING):
			coeff = SPACING / distance
			newLat = obsPrev.x + (obsCur.x-obsPrev.x) * coeff
			newLon = obsPrev.y + (obsCur.y-obsPrev.y) * coeff
			newPoint = point(newLat,newLon)
			shapeOut.append(newPoint)
			obsPrev = newPoint
		else:
			i += 1
	shapeOut.append(shapeIn[len(shapeIn)-1])
	return shapeOut

#returns a uniqId of a state to which a given lat lon pair is closest in terms
#of distance.
#input: states hash map, shape_id, lat, lon
#output: unique id of state (integer)
def bestMatchToRoutes(states,shape_id,lat,lon):
    minList = []
    for ss in states.values():
        if(ss.shapeId==shape_id):
            (dist,uniqId) = (ss.distanceToSegment(ss,lat,lon),ss.uniqId)
            minList.append((dist,uniqId))

    (dist,minId)=min(minList)
    return minId

#returns a dictionary keyed on state uniqId with values that determine
#frequency of how many raw points were closest to that state
#input: states hash map (type shapeSegment), unknownId of unknown state (integer), 
#rawPoints array (type point), shapeId to which the raw points correspond (integer)
#output: histogram stored in a hash map
def produceHistogramOfPoints(states, unknownId, rawPoints, shapeId):
	histogram = {}
	for s in states.values():
		if(s.uniqId != unknownId):
			histogram[s.uniqId] = 0
	for p in rawPoints:
		minId = bestMatchToRoutes(states, shapeId, p.x, p.y)
		histogram[minId] += 1

	return histogram

#interpolates between "fromPoint" (timePoint) and "toPoint" (timePoint) in the time domain
#every "timeInterval" seconds there will be a new point added between "fromPoint" and "toPoint"
#input: fromPoint (timePoint), toPoint(timePoint), timeInterval (seconds)
#output: array of interpolated points "timePointsOut" which includes input points "fromPoint" and
#"toPoint" as endpoints
def interpolatePointsInTime(fromPoint,toPoint,timeInterval):
	timePointsOut = []
	timePointsOut.append(fromPoint)
	timeDiff = toPoint.timestamp - fromPoint.timestamp
	if(timeDiff <= timeInterval or timeDiff <= 0 or timeInterval <= 0):  ##error checking
		timePointsOut.append(toPoint)
		return timePointsOut
	numOfPoints = math.floor(timeDiff / timeInterval)
	distance = distanceBetweenGPSPoints(fromPoint.lat,fromPoint.lon,toPoint.lat,toPoint.lon)
	spaceInterval = distance / numOfPoints
	previousPoint = fromPoint
	while(distance > spaceInterval):
		coeff = spaceInterval / distance
		newLat = previousPoint.lat + (toPoint.lat-previousPoint.lat) * coeff
		newLon = previousPoint.lon + (toPoint.lon-previousPoint.lon) * coeff
		newTimestamp = previousPoint.timestamp + timeInterval
		previousPoint = timePoint(newTimestamp,newLat,newLon)
		timePointsOut.append(previousPoint)
		distance = distanceBetweenGPSPoints(previousPoint.lat,previousPoint.lon,toPoint.lat,toPoint.lon)
		if(distance <= 0):  ##error checking
			break;
	timePointsOut.append(toPoint)
	return timePointsOut 

#interpolates between "fromPoint" (timePoint) and "toPoint" (timePoint) in the space domain
#every "spaceInterval" meters there will be a new point added between "fromPoint" and "toPoint"
#input: fromPoint (timePoint), toPoint(timePoint), spaceInterval (meters)
#output: array of interpolated points "timePointsOut" which includes input points "fromPoint" and
#"toPoint" as endpoints
def interpolatePointsInSpace(fromPoint,toPoint,spaceInterval):
	timePointsOut = []
	timePointsOut.append(fromPoint)
	distance = distanceBetweenGPSPoints(fromPoint.lat,fromPoint.lon,toPoint.lat,toPoint.lon)				    
	if(distance <= spaceInterval or distance <= 0 or spaceInterval <= 0):  #error checking
		timePointsOut.append(toPoint)
		return timePointsOut
	numOfPoints = math.floor(distance / spaceInterval) + 1
	timeDiff = toPoint.timestamp - fromPoint.timestamp
	timeInterval = timeDiff / numOfPoints
	previousPoint = fromPoint
	while(distance > spaceInterval):
		coeff = spaceInterval / distance
		newLat = previousPoint.lat + (toPoint.lat-previousPoint.lat) * coeff
		newLon = previousPoint.lon + (toPoint.lon-previousPoint.lon) * coeff
		newTimestamp = previousPoint.timestamp + timeInterval
		previousPoint = timePoint(newTimestamp,newLat,newLon)
		timePointsOut.append(previousPoint)
		distance = distanceBetweenGPSPoints(previousPoint.lat,previousPoint.lon,toPoint.lat,toPoint.lon)
		if(distance <= 0):  ##error checking
			break;
	timePointsOut.append(toPoint)
	return timePointsOut 

#returns True if "observation" (type timePoint) is within a bounding box of bus depot
#returns False otherwise
def isAtBusDepot(observation):
	if(observation.lon >= LEFT_LON_BUS_DEPOT and observation.lon <= RIGHT_LON_BUS_DEPOT):
		if(observation.lat <= TOP_LAT_BUS_DEPOT and observation.lat >= BOTTOM_LAT_BUS_DEPOT):
			return True
	return False

