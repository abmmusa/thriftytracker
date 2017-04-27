import os, pickle, math

MAX_BUCKETS=35  #keep synched in other places


class ExponentialErrorBuckets:
    def __init__(self):
        self.error_upper_bounds = self.get_error_upper_bounds()


    def get_error_upper_bounds(self):
        error_upper_bounds=sorted(list(set([round(math.pow(2,i)**(1.0/2.0)) for i in range(0, MAX_BUCKETS-1)])))
        error_upper_bounds.insert(0, 0.0)
        #print error_upper_bounds, len(error_upper_bounds)
        return error_upper_bounds


    def get_bucket_from_error(self, error):
        if error == 0.0:
            return 0

        for i in range(0, len(self.error_upper_bounds)-1):
            if error>self.error_upper_bounds[i] and error<=self.error_upper_bounds[i+1]:
                return i+1

        # all error values greater than the max error in the error_upper_bounds goes to the last bucket
        return MAX_BUCKETS-1


    def get_error_range_from_bucket(self, bucket_no):
        if bucket_no > MAX_BUCKETS-1:
            return None

        if bucket_no == 0:
            return (0.0, 0.0)

        if bucket_no == MAX_BUCKETS-1:
            return (self.error_upper_bounds[MAX_BUCKETS-1], float('inf'))
        
        return (self.error_upper_bounds[bucket_no-1], self.error_upper_bounds[bucket_no])

