#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

#define EARTH_RADIUS 6371000.0 // meters

struct tripHeader
{
    uint64_t tripId;
    uint64_t locationRecordCount;
    uint32_t sumSampleInterval;
    uint32_t minSampleInterval;
    uint32_t maxSampleInterval;
    uint8_t padding[4];
} __attribute__((packed));

struct locationRecord
{
    uint32_t probeDataProvider;
    uint64_t probeId;
    uint32_t sampleDate;
    int32_t latitude;
    int32_t longitude;
    int16_t heading;
    int16_t speed;
    uint8_t padding[4];
} __attribute__((packed));

double degreesToRadians(double degrees)
{
    return ((degrees * M_PI) / 180.0);
}

double haversineDistanceDoubles(double aLat, double aLon, double bLat, double bLon)
{
    double dLat = degreesToRadians(bLat - aLat);
    double dLon = degreesToRadians(bLon - aLon);
    
    double a = sin(dLat/2.0) * sin(dLat/2.0) + cos(degreesToRadians(aLat)) * cos(degreesToRadians(bLat)) * sin(dLon/2.0) * sin(dLon/2.0);
    double c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a));
    
    return (EARTH_RADIUS * c);
}

double haversineDistance(int32_t aLat, int32_t aLon, int32_t bLat, int32_t bLon)
{
    if ((aLat == bLat) && (aLon == bLon))
    {
	return 0.0;
    }
    
    return haversineDistanceDoubles((((double)aLat) / 10000000), (((double)aLon) / 10000000), (((double)bLat) / 10000000), (((double)bLon) / 10000000));
}

double fmin(double a, double b)
{
    return (a < b) ? a : b;
}

double fmax(double a, double b)
{
    return (a > b) ? a : b;
}

double bearingDifference(double aBearing, double bBearing)
{
    double maxBearing = fmax(aBearing, bBearing);
    double minBearing = fmin(aBearing, bBearing);
    
    return fmin((maxBearing - minBearing), ((360.0 - maxBearing) + minBearing));
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
	printf("usage: nokia_trips_reader tripsFilename\n\n");
	return -1;
    }
    
    char* inputFilename = argv[1];
    FILE *inputFile = fopen(inputFilename, "rb");
    
    if (inputFile != NULL)
    {
	struct tripHeader currTripHeader;
	size_t currTripHeaderReadReturn = fread(&currTripHeader, sizeof(struct tripHeader), 1, inputFile);
	
	while (currTripHeaderReadReturn > 0)
	{
	    struct locationRecord* currTripLocationRecords = malloc(sizeof(struct locationRecord) * currTripHeader.locationRecordCount);
	    fread(currTripLocationRecords, sizeof(struct locationRecord), currTripHeader.locationRecordCount, inputFile);
	    
	    uint64_t i;
	    for (i = 1; i < currTripHeader.locationRecordCount; i++)
	    {
		int32_t timeDelta = currTripLocationRecords[i].sampleDate - currTripLocationRecords[i - 1].sampleDate;
		double distanceDelta = haversineDistance(currTripLocationRecords[i].latitude, currTripLocationRecords[i].longitude, currTripLocationRecords[i - 1].latitude, currTripLocationRecords[i - 1].longitude);
		double speedDelta = (((double)currTripLocationRecords[i].speed) / 10.0) - (((double)currTripLocationRecords[i - 1].speed) / 10.0);
		double accelerationDelta = speedDelta / timeDelta;
		double bearingDelta = bearingDifference((((double)currTripLocationRecords[i].heading) / 10.0), (((double)currTripLocationRecords[i - 1].heading) / 10.0));
		
		printf("%d %ld %ld %d %f %f %f %f %.6f %.6f %.6f %.6f %ld\n", 
		       currTripLocationRecords[i].probeDataProvider, currTripLocationRecords[i].probeId, currTripHeader.tripId, 
		       timeDelta, distanceDelta, speedDelta, accelerationDelta, bearingDelta, 
		       (((double)currTripLocationRecords[i - 1].latitude) / 10000000), (((double)currTripLocationRecords[i - 1].longitude) / 10000000), (((double)currTripLocationRecords[i].latitude) / 10000000), (((double)currTripLocationRecords[i].longitude) / 10000000), 
		       currTripHeader.locationRecordCount);
	    }
	    
	    free(currTripLocationRecords);
	    currTripHeaderReadReturn = fread(&currTripHeader, sizeof(struct tripHeader), 1, inputFile);
	}
	
	fclose(inputFile);
    }
    else if (inputFile == NULL)
    {
	perror(inputFilename);
	return -2;
    }
    
    return 0;
}
