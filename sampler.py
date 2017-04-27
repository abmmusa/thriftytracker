from pylibs import spatialfunclib
import math
import pickle
from gps_compressor import GPSCompressor
#from gps_compressor import TDTR, TDTR_window_sized

MAX_HISTORY=1800

ENABLE_ONLINE_TABLE = False #need to change at evaluator.py too (bad!)


debug=False

class Sampler:
    def __init__(self, server, extrapolator, offline_expected_error_file, expected_error_table=None): 
        self.server = server
        self.extrapolator = extrapolator
        
        #self.time_error_table_offline = self.load_time_error_table_offline(offline_table_file)
        if expected_error_table == None:
            self.time_expected_error_offline = self.load_time_expected_error_offline(offline_expected_error_file)
        else:
            self.time_expected_error_offline = expected_error_table

        #delay window; list of (location, extrapolation_parameters)
        self.delay_window = []
        self.server_loc_param = None

        #double in size of delay window; list of (location, extrapolation_parameters)
        self.estimation_window = []
        
        self.time_error_table = {}
        
        self.current_time = None

        self.start_time = None

    def cleanup_last_window(self):
        return 
    
    def load_time_error_table_offline(self, offline_table_file):
        if(offline_table_file == None):
            return None
        else:
            f = open(offline_table_file, "rb")
            return pickle.load(f)


    def load_time_expected_error_offline(self, offline_expected_error_file):

        if(offline_expected_error_file == None):
            return None
        else:
            f = open(offline_expected_error_file, "rb")
            offline_table = pickle.load(f)
            return offline_table

         
        

    def init_location(self, curr_loc_param):
        #self.cleanup_last_window()

        self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time

        self.estimation_window = [curr_loc_param]

        self.time_error_table = {}

        self.start_time = self.current_time


    def update(self, curr_loc_param):
        self.current_time += 1

        if curr_loc_param is not None:
            self.delay_window.append(curr_loc_param)

            if ENABLE_ONLINE_TABLE:
                self.update_time_error_table(curr_loc_param)
        
        self.transmit_locations()

    def update_time_error_table(self, curr_loc_param):
        (curr_loc, curr_param) = curr_loc_param

        if(curr_loc.time - self.estimation_window[0][0].time <= 2*int(self.delay_threshold)):
            self.estimation_window.append(curr_loc_param)

        else: 
            #make room for curr_loc_param in the estimation window
            while( self.estimation_window and (curr_loc.time - self.estimation_window[0][0].time >= 2*int(self.delay_threshold)) ): 
                del self.estimation_window[0]
                
            # put the curr_loc_param in the estimation window now
            self.estimation_window.append(curr_loc_param)

            
        for (loc, param) in self.estimation_window:
            #print loc, param
            time_interval = curr_loc.time - loc.time
            if time_interval == 0:
                continue

            extrapolated_trajectory = self.extrapolator.get_trajectory((loc, param), [time_interval])
            extrapolation_error = round(self._distance(loc, extrapolated_trajectory[0]))
            
            try:
                self.time_error_table[time_interval, extrapolation_error] += 1
            except:
                self.time_error_table[time_interval, extrapolation_error] = 1


    # computes from time_error_offline_table
    # def get_expected_error_for_timerange(self, starttime, endtime):
    #     expected_total_error=0.0
    #     for t in range(starttime, endtime+1):
    #         error_count=[(error,count) for ((time,error),count) in self.time_error_table_offline.items() if time==t]
    #         total_count = sum(map(lambda (error,count):count, error_count))
            
    #         expected_total_error += sum( map(lambda(error,count):error*(float(count)/float(total_count)), error_count) )

    #     return expected_total_error


    # computes from time_error_offline_table
    # def get_expected_error_for_timelist(self, timelist):
    #     expected_total_error=0.0
    #     for t in timelist:
    #         error_count=[(error,count) for ((time,error),count) in self.time_error_table_offline.items() if time==t]
    #         total_count = sum(map(lambda (error,count):count, error_count))
            
    #         expected_total_error += sum( map(lambda(error,count):error*(float(count)/float(total_count)), error_count) )
            
    #     return expected_total_error



    # computes from time and expected_error offline data
    def get_expected_error_for_timelist(self, timelist):
        expected_total_error=0.0
        for t in timelist:
            try:
                expected_total_error += self.time_expected_error_offline[t]
            except:
                expected_total_error += 0.0

        return expected_total_error

    def get_mean_expected_error_for_timelist(self, timelist):
        expected_total_error=0.0
        for t in timelist:
            try:
                expected_total_error += self.time_expected_error_offline[t]
            except:
                expected_total_error += 0.0

        return expected_total_error/len(timelist)  


    def transmit_locations(self, output_file):
        return NotImplemented
    
    def _flush_delay_window(self):
        self.delay_window = []
    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)

    def write_time_error_table(self, output_file):
        if not self.time_error_table:
            return

        #all times after removing duplicate times
        times = list(set([time for (time, error) in self.time_error_table.keys()]))

        for t in times:
            error_count_t=[(error,count) for ((time,error),count) in self.time_error_table.items() if time==t]
            for (error,count) in error_count_t:
                output_file.write(str(t)+" "+str(error)+" "+str(count)+"\n")

            output_file.write("\n")
            


    def write_time_error_table_with_bucket(self, output_file):
        if not self.time_error_table:
            return

        times = sorted(list(set([time for (time, error) in self.time_error_table.keys()])))


        buckets=range(50, 1050, 50)
        #print buckets

        for t in times:
            count_in_buckets = dict((bucket, 0) for bucket in buckets)
            
            error_count_t=[(error,count) for ((time,error),count) in self.time_error_table.items() if time==t]
            for (error,count) in error_count_t:
                for bucket in buckets:
                    if error < bucket:
                        count_in_buckets[bucket] += count
                        break

            sorted_result = sorted(count_in_buckets.items(), key = lambda k:k[0])

            for (bucket, count) in sorted_result:
                output_file.write(str(int(t))+" "+str(bucket)+" "+str(count)+"\n")

            output_file.write("\n")


    def get_extrapolation_errors(self, server_loc_param, loc_param_window):
        time_offsets = map(lambda loc_param: (loc_param[0].time - server_loc_param[0].time), loc_param_window)

        extrapolated_trajectory = self.extrapolator.get_trajectory(server_loc_param, time_offsets)
        extrapolation_errors = []
        for i in range(0, len(loc_param_window)):
            extrapolation_errors.append(self._distance(loc_param_window[i][0], extrapolated_trajectory[i]))

        return extrapolation_errors


#
# stripped down version of ErrorDelaySampler. used by error-budget sampler
#
class ErrorDelaySamplerMeta(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, expected_error_table, error_threshold=0.0, delay_threshold=100.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file, expected_error_table)
        self.error_threshold = error_threshold
        self.delay_threshold = delay_threshold

        
    # override 
    def init_location(self, curr_loc_param):
        self.delay_window = [curr_loc_param]
        #self.server_loc_param = None
        self.server_loc_param = curr_loc_param
        self.current_time = curr_loc_param[0].time


    # overridden to return some value
    def update(self, curr_loc_param):
        self.current_time += 1

        if curr_loc_param is not None:
            self.delay_window.append(curr_loc_param)

        return self.transmit_locations()


    def transmit_locations(self):
        if not self.delay_window: #empty window, nothing to do
            return None

        if (self.current_time - self.delay_window[0][0].time <= self.delay_threshold): #fill the delay window if within threshold
            return None

        else: # need to process the delay window
            # print len(self.delay_window)
            if (self.server_loc_param is None): # the very first window
                #return self.delay_window
                self.server_loc_param = self.server.update_locations(self.delay_window)       
                #if debug: print "first window transmission..."
                delay_window = self.delay_window
                self._flush_delay_window()
                return delay_window
            
            #print "none inside error delay:", self.delay_window
            extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)

            indices_for_error_over_threshold = filter(lambda (index, error): error>self.error_threshold, list(enumerate(extrapolation_errors)))
            #print indices_for_error_over_threshold

            first_index_for_error_over_threshold = None
            if len(indices_for_error_over_threshold) > 0: 
                (first_index_for_error_over_threshold, _) = indices_for_error_over_threshold[0]
                #print first_index_for_error_over_threshold, len(self.delay_window)
                

                if(first_index_for_error_over_threshold == 0): # we need to transmit this window immediately 
                    #self.server_loc_param = self.server.update_locations(self.delay_window)
                    if debug: print "transmitting as fist loc in the window has high error $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
                    #self._flush_delay_window()
                    #return self.server_loc_param
                    return self.delay_window

                else: # we need to estimate if we should send this window or some future window containing the error that is over threshold
                    subwindow = self.delay_window[0:first_index_for_error_over_threshold]
                    #print map(lambda loc_param: loc_param[0].time - self.server_loc_param[0].time, subwindow)
                    #print self.server_loc_param[0].time

                    subwindow_errors = self.get_extrapolation_errors(self.server_loc_param, subwindow)

                    for i in range(1, len(subwindow)):
                        sub_subwindow = subwindow[0:i]
                        
                        sub_subwindow_error = sum(subwindow_errors[0:i])
                        
                        window_time = self.delay_window[-1][0].time - self.delay_window[0][0].time
                        # print window_time
                        sub_subwindow_time_offsets = map(lambda loc_param: (loc_param[0].time - self.server_loc_param[0].time + window_time), sub_subwindow)
                        #print sub_subwindow_time_offsets
                        sub_subwindow_expected_error = self.get_expected_error_for_timelist(sub_subwindow_time_offsets)

                        if(sub_subwindow_error < sub_subwindow_expected_error): 
                            # some sub_subwindow error is below expected error.
                            # so we can drop the first sample at delay window and move on...
                            #print "dropping first sample in the window"
                            del self.delay_window[0]
                            return None
                    
                    # we are here means all sub_subwindow errors are over corresponding expected errors
                    # so we should transmit current window
                    #if debug: print "transmitting as all sub_subwindow errors over expected..."
                    #self.server_loc_param = self.server.update_locations(self.delay_window)
                    #self._flush_delay_window()
                    #return self.server_loc_param
                    return self.delay_window
                        
            else: #low error for the whole window; nothing to transmit
                #if debug: print "low error... not transmitting"
                self._flush_delay_window()
            



# ID 0
class ErrorBudgetSampler(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, delays_file, error_threshold=0.0, budget_threshold=9999.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file)
        self.error_threshold = error_threshold
        self.budget_threshold = budget_threshold

        self.server = server
        self.extrapolator = extrapolator
        self.offline_table_file = offline_table_file


        #TODO: don't print delays from here. tx it to the server during loc_param update and log from there
        self.delays_file = delays_file

        # given budget (messages/sec)
        self.given_budget = 1.0/self.budget_threshold

        # time period over which we want spend the savings or recover the deficit 
        # TODO: should we spend the savings slowly and recover the deficit quickly?
        self.alpha = float(1.0/(3*self.budget_threshold)) #(1/sec)

        # what is the current budget (message/sec)
        self.current_budget = self.given_budget

        # how much savings or deficit we have (messages)
        self.messages_inhand = 0.0

        self.current_delay = None
        self.error_delay_sampler = None
        self.new_error_delay_sampler_init_location_done = False


    # override 
    def init_location(self, curr_loc_param):
        #self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time

        self.current_delay = 0.0
        self.error_delay_sampler = ErrorDelaySamplerMeta(self.server, self.extrapolator, self.offline_table_file, self.time_expected_error_offline, self.error_threshold, self.current_delay)

        self.error_delay_sampler.init_location(curr_loc_param)
        self.new_error_delay_sampler_init_location_done = True
        
        # always transmit the first location here as initital delay is zero anyway
        self.server_loc_param = self.server.update_locations([curr_loc_param])  

    # overriding update from Sampler as we don't need to call transmit location.
    # also we don't have samples all the time to add to the delay window
    def update(self, curr_loc_param):
        self.current_time += 1

        if self.new_error_delay_sampler_init_location_done == False:
            if curr_loc_param is not None:
                #print "init of error delay sampler"
                self.error_delay_sampler.init_location(curr_loc_param)
                self.new_error_delay_sampler_init_location_done = True

                # update the budget. By transmitting the first window, we are in deficit
                #self.current_budget = self.given_budget - self.alpha * 1.0

                return
        
        else:
            tx_window = self.error_delay_sampler.update(curr_loc_param)
            #print tx_window

            if tx_window is not None: # error_delay_sampler has transmitted a window, so we need to update current budget
                # update for the first time
                #if self.server_loc_param is None:
                #    self.server_loc_param = self.server.update_locations(tx_window)       
                #    return

                # get the current budget
                self.current_budget = self.get_updated_budget(tx_window[-1])
                #print self.current_budget, len(tx_window)
                
                # initialize error_delay sampler with new budget (corresponding delay)
                
                if self.current_budget >= 1.0:
                    self.current_delay = 0.0
                else:
                    self.current_delay = 1.0/self.current_budget
                #print "current delay", self.current_delay
                self.error_delay_sampler = ErrorDelaySamplerMeta(self.server, self.extrapolator, self.offline_table_file, self.time_expected_error_offline, self.error_threshold, self.current_delay)
            
                #print "created new error_delay samper"

                self.new_error_delay_sampler_init_location_done = False

                # update the server_loc_param after getting the budget as budget computation uses old window
                #print tx_window
                
                self.server_loc_param = self.server.update_locations(tx_window)       
            
        #print self.current_budget
        #print self.current_delay
        self.delays_file.write(str(self.current_delay)+"\n")

    def get_updated_budget(self, tx_loc_param):
        # compute the new budget
        #print tx_loc_param, self.server_loc_param
        timegap_from_last_tx = tx_loc_param[0].time - self.server_loc_param[0].time
        messages_from_last_tx = timegap_from_last_tx/self.budget_threshold
        #print "message from last tx: ", messages_from_last_tx
        
        
        if messages_from_last_tx > 1.0: # we are having savings
            self.current_budget = self.current_budget + self.alpha * (messages_from_last_tx - 1.0)
            #self.current_budget = self.given_budget
        else: # we are having deficit or we are meeting budget
            self.current_budget = self.current_budget - self.alpha * (1.0 - messages_from_last_tx)

        #print self.current_budget
        return self.current_budget




    def load_time_error_table_offline(self, offline_table_file):
       if(offline_table_file == None):
           return None
       else:
           f = open(offline_table_file, "rb")
           return pickle.load(f)
       

    def get_prob_of_error_at_time(self, given_error, given_time):

        error_count_t=[(error,count) for ((time,error),count) in self.time_error_table_offline.items() if time==given_time]
        #print error_count_t        

        errors_counts_upto_error = filter( lambda (error,count): error<=given_error, error_count_t )
        total_count_upto_error = sum( map(lambda (error,count):count, errors_counts_upto_error) )

        total_count_all_errors = sum( map(lambda (error,count):count, error_count_t) )


        return float(total_count_upto_error)/float(total_count_all_errors)

        #print errors_counts_upto_error
        #print total_count_upto_error
        #print total_count_all_errors
                                     

    def cleanup_last_window(self):
        #TODO: decide when to send
        if(self.delay_window):
            self.server_loc_param = self.server.update_locations(self.delay_window)
            self._flush_delay_window()




# ID 1
class ErrorDelaySampler(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, error_threshold=0.0, delay_threshold=100.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file)
        self.error_threshold = error_threshold
        self.delay_threshold = delay_threshold
    

    def cleanup_last_window(self):
        if not self.delay_window:
            return

        extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)
        indices_for_error_over_threshold = filter(lambda (index, error): error>self.error_threshold, list(enumerate(extrapolation_errors)))

        if len(indices_for_error_over_threshold) > 0: # transmit if any sample causing error over threshold in the last window
            self.server_loc_param = self.server.update_locations(self.delay_window)
            self._flush_delay_window()


    def transmit_locations(self):
        if not self.delay_window: #empty window, nothing to do
            return

        if (self.current_time - self.delay_window[0][0].time <= self.delay_threshold): #fill the delay window if within threshold
            return

        else: # need to process the delay window

            if (self.server_loc_param is None): # the very first window
                self.server_loc_param = self.server.update_locations(self.delay_window)       
                if debug: print "first window transmission..."
                self._flush_delay_window()
                return

            extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)

            indices_for_error_over_threshold = filter(lambda (index, error): error>self.error_threshold, list(enumerate(extrapolation_errors)))
            #print indices_for_error_over_threshold

            first_index_for_error_over_threshold = None
            if len(indices_for_error_over_threshold) > 0: 
                (first_index_for_error_over_threshold, _) = indices_for_error_over_threshold[0]

                if(first_index_for_error_over_threshold == 0): # we need to transmit this window immediately 
                    self.server_loc_param = self.server.update_locations(self.delay_window)
                    if debug: print "transmitting as fist loc in the window has high error $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
                    self._flush_delay_window()
                    return 

                else: # we need to estimate if we should send this window or some future window containing the error that is over threshold
                    subwindow = self.delay_window[0:first_index_for_error_over_threshold]
                    #print map(lambda loc_param: loc_param[0].time - self.server_loc_param[0].time, subwindow)
                    #print self.server_loc_param[0].time

                    subwindow_errors = self.get_extrapolation_errors(self.server_loc_param, subwindow)

                    for i in range(1, len(subwindow)):
                        sub_subwindow = subwindow[0:i]
                        
                        sub_subwindow_error = sum(subwindow_errors[0:i])
                        
                        window_time = self.delay_window[-1][0].time - self.delay_window[0][0].time
                        # print window_time
                        sub_subwindow_time_offsets = map(lambda loc_param: (loc_param[0].time - self.server_loc_param[0].time + window_time), sub_subwindow)
                        #print sub_subwindow_time_offsets
                        sub_subwindow_expected_error = self.get_expected_error_for_timelist(sub_subwindow_time_offsets)

                        if(sub_subwindow_error < sub_subwindow_expected_error): 
                            # some sub_subwindow error is below expected error.
                            # so we can drop the first sample at delay window and move on...
                            if debug: print "dropping first sample in the window"
                            del self.delay_window[0]
                            return
                    
                    # we are here means all sub_subwindow errors are over corresponding expected errors
                    # so we should transmit current window
                    if debug: print "transmitting as all sub_subwindow errors over expected..."
                    self.server_loc_param = self.server.update_locations(self.delay_window)
                    self._flush_delay_window()


            else: #low error for the whole window; nothing to transmit
                if debug: print "low error... not transmitting"
                self._flush_delay_window()
            
# debug2=False
# debug2_cleanup=False
# # ID 2
# class BudgetDelaySampler(Sampler):
#     def __init__(self, server, extrapolator, offline_table_file, budget_threshold=9999.0, delay_threshold=30.0):
#         Sampler.__init__(self, server, extrapolator, offline_table_file)

#         self.budget_threshold = budget_threshold #sec
#         self.delay_threshold = delay_threshold #sec
        
#         # TODO: we need to adjust for per-sample interval and delay window size is not equal to the delay threshold
#         # if samples are not 1s apart
#         self.given_budget = self.get_tx_bytes(self.delay_threshold)/self.budget_threshold #bytes/sec [LONG TERM]
#         #print self.given_budget

#         # time period over which we want spend the savings or recover the deficit 
#         #self.alpha = float(1.0/(10.0*(1/self.given_budget)) #(unit: 1/sec)
#         self.alpha = float(1.0/1200)

#         # what is the current budget (unit: message/sec)
#         self.current_budget = self.given_budget #[SHORT TERM]

#         # self.budget_in_hand = 0.0 #bytes/sec

#         self.duration_upto_now = 0.0
#         self.bytes_transmitted = 0.0

#         self.prev_time = None

#     def init_location(self, curr_loc_param):
#         #self.cleanup_last_window()
        
#         self.delay_window = [curr_loc_param]
#         self.server_loc_param = None
#         self.current_time = curr_loc_param[0].time

#         self.estimation_window = [curr_loc_param]

#         self.time_error_table = {}

#         self.start_time = self.current_time

#         self.prev_time = None
        

        
#         # NOTE: uncomment to start budget calculation seperately for new trip and don't count budget in the case of not sending in cleaup_last_window()
#         # self.current_budget = self.given_budget
#         #self.budget_in_hand = 0.0


#     #def update_budget(self):
#     #    self.current_budget = self.given_budget + self.alpha * (self.given_budget*self.duration_upto_now - self.bytes_transmitted)


#     def get_tx_bytes(self, window_size):
#         return math.ceil( (32+window_size*12+10)/42 )*42



#     # def cleanup_last_window(self):
#     #     # transmit only if we have budget
#     #     if debug2_cleanup:
#     #         print self.budget_in_hand

#     #     if self.delay_window:
#     #         end_time = self.delay_window[-1][0].time
#     #         duration = end_time - self.start_time
            
#     #         timegap_from_last_tx = self.delay_window[-1][0].time - self.server_loc_param[0].time
#     #         messages_from_last_tx = timegap_from_last_tx/self.budget_threshold
            

#     #         if ( (self.current_budget + self.alpha * (self.budget_in_hand + messages_from_last_tx - 1.0)) >= self.given_budget ): # we have budget to send               
#     #             if debug2:
#     #                 print "last tx..."

#     #             self.server_loc_param = self.server.update_locations(self.delay_window)
#     #             self._flush_delay_window()

#     #             # update the budget in hand and current budget (as propagated to future trips)
#     #             budget_in_hand_from_last_tx = messages_from_last_tx - 1.0
#     #             self.update_budget(budget_in_hand_from_last_tx)

#     #             if debug2:
#     #                 print "timegap_last_tx:", str(timegap_from_last_tx).rjust(6), "message_last_tx:", str(messages_from_last_tx).rjust(15),\
#     #                     "budget_in_hand:", str(self.budget_in_hand).rjust(15), "current_budget:", str(self.current_budget).rjust(15), " ", str(1.0/self.current_budget).rjust(15)
#     #                 print duration, "start:", self.start_time, "end:", end_time, "CLEANUP LAST WINDOW"
#     #                 print "\n"


#     #         else: # we dont't have budget to tx this last window, but still we need to update the current budget for future
#     #             budget_in_hand_from_last_tx = messages_from_last_tx # we just add what ever savings/deficit we have. NOT substract -1 as we didn't transmit
#     #             self.update_budget(budget_in_hand_from_last_tx)
                

#     def transmit_locations(self):
#         if (self.prev_time is not None):
#             self.duration_upto_now += (self.current_time - self.prev_time)
        
#         self.prev_time = self.current_time

#         #print self.duration_upto_now

#         if not self.delay_window: #empty window, nothing to do
#             return

#         if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
#             return

#         else: # need to process the delay window
#             delay_window_locations = map(lambda (loc,param):loc, self.delay_window)

#             #compressed_window=TDTR(delay_window_locations, 20.0)
#             compressed_window=TDTR_window_sized(delay_window_locations, 4)
#             print len(delay_window_locations), len(compressed_window)
#             print map(lambda loc:loc.time, delay_window_locations)
#             print map(lambda loc:loc.time, compressed_window)
#             print "\n"

#             if (self.server_loc_param is None): # the very first window
#                 self.server_loc_param = self.server.update_locations(self.delay_window)       
#                 self._flush_delay_window()

#                 #update the budget. By transmitting the first window, we are in deficit of 1 message
#                 #self.duration_upto_now += self.delay_window[-1][0].time - self.start_time
#                 #self.bytes_transmitted += self.get_tx_bytes(len(self.delay_window))
#                 #self.current_budget = self.given_budget + self.alpha * (self.given_budget*self.duration_upto_now - self.bytes_transmitted)

#                 return
    
            
#             #print self.server_loc_param[0].time, map(lambda loc_param: loc_param[0].time-self.server_loc_param[0].time, self.delay_window)

#             messages_from_last_tx = None

#             extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)

#             #total_extrapolation_error_for_window = sum(extrapolation_errors)
#             total_extrapolation_error_for_window = sum(extrapolation_errors)/len(extrapolation_errors)
            
#             delay_window_time_len = self.delay_window[-1][0].time - self.delay_window[0][0].time

#             # 1.0/self.current_budget is budget_period in terms of seconds. 
#             # So if we have savings we look ahead for expected error and 
#             # if we have deficit the we look late
#             expected_window_time_offsets = range(int(1.0/self.current_budget), int(1.0/self.current_budget + delay_window_time_len + 1))

#             #print self.server_loc_param[0].time, self.current_time, self.delay_threshold, map(lambda loc_param: loc_param[0].time, self.delay_window)
            
#             time_offsets = map(lambda loc_param: (loc_param[0].time - self.server_loc_param[0].time), self.delay_window)
#             #print "time_offsets:", time_offsets, "expt_offsets:", expected_window_time_offsets
            
#             #expected_error = self.get_expected_error_for_timelist(expected_window_time_offsets)                
#             expected_error = self.get_mean_expected_error_for_timelist(expected_window_time_offsets)                
            
#             #print total_extrapolation_error_for_window, expected_error, 1.0/self.current_budget
            

#             if(total_extrapolation_error_for_window > expected_error): # we are sending one message 
#                 if debug: print "tx as error over expected"
                
#                 timegap_from_last_tx = self.delay_window[-1][0].time - self.server_loc_param[0].time
#                 messages_from_last_tx = timegap_from_last_tx/self.budget_threshold

#                 #print "tx as error over expected ", timegap_from_last_tx, messages_from_last_tx
                
#                 budget_in_hand_from_last_tx = messages_from_last_tx-1.0
#                 #self.update_budget(budget_in_hand_from_last_tx)
                
#                 if debug2:
#                     print "timegap_last_tx:", str(timegap_from_last_tx).rjust(6), "message_last_tx:", str(messages_from_last_tx).rjust(15), \
#                         "budget_in_hand:", str(self.budget_in_hand).rjust(15), "current_budget:", str(self.current_budget).rjust(15), " ", str(1.0/self.current_budget).rjust(15)

                    
#                 self.server_loc_param = self.server.update_locations(self.delay_window)
#                 self._flush_delay_window()

#             else:
#                 if debug: print "no tx"

#                 #self._flush_delay_window()
#                 del self.delay_window[0]



class ChangeBasedSampler(Sampler):
    def __init__(self, server, extrapolator, change_threshold):
        Sampler.__init__(self, server, extrapolator, None)
        self.change_threshold = float(change_threshold)


# ID 3
#strawman sampler for comarping with the error-delay sampler.
class LocationChangeBasedSampler(ChangeBasedSampler):
    # default: 15 meters
    def __init__(self, server, extrapolator, change_threshold=15.0):
        ChangeBasedSampler.__init__(self, server, extrapolator, change_threshold)
    
    def init_location(self, curr_loc_param):
        self.server_loc_param = self.server.update_locations( [curr_loc_param] )
    
    def update(self, curr_loc_param):
        if curr_loc_param is not None:
            self.transmit_locations(curr_loc_param)    
    
    def transmit_locations(self, curr_loc_param):
        (curr_loc, _) = curr_loc_param
        (last_loc, _) = self.server_loc_param
        
        if (self._distance(curr_loc, last_loc) >= self.change_threshold):
            self.server_loc_param = self.server.update_locations( [curr_loc_param] )

# ID 4
class TimeChangeBasedSampler(ChangeBasedSampler):
    # default: 10 seconds
    def __init__(self, location_transmitter, extrapolator, change_threshold=10.0):
        ChangeBasedSampler.__init__(self, location_transmitter, extrapolator, change_threshold)
        
        self.last_loc_param = None
        self.time_in_hand = 0.0
    
    def init_location(self, curr_loc_param):
        if self.server_loc_param is not None:
            self.time_in_hand = (self.last_loc_param[0].time - self.server_loc_param[0].time)
            #print self.time_in_hand

        self.server_loc_param = self.server.update_locations( [curr_loc_param] )

        self.last_loc_param = curr_loc_param

    def update(self, curr_loc_param):
        if curr_loc_param is not None:
            self.transmit_locations(curr_loc_param)    
            self.last_loc_param = curr_loc_param
    
    def transmit_locations(self, curr_loc_param):
        (curr_loc, _) = curr_loc_param
        (last_tx_loc, _) = self.server_loc_param

        
        if ((curr_loc.time - last_tx_loc.time) >= self.change_threshold + self.time_in_hand):
            #print "tx....................."
            #print curr_loc.time- last_tx_loc.time, self.time_in_hand
            self.server_loc_param = self.server.update_locations( [curr_loc_param] )
            self.time_in_hand = 0.0





            
debug2=False
debug2_cleanup=False
# ID 2
class BudgetDelaySampler(Sampler):
    def __init__(self, server, extrapolator, offline_table_file, budget_threshold=9999.0, delay_threshold=30.0):
        Sampler.__init__(self, server, extrapolator, offline_table_file)
        self.budget_threshold = budget_threshold #1 message in how many seconds
        self.delay_threshold = delay_threshold 

        # given budget (unit: messages/sec)
        self.given_budget = 1.0/self.budget_threshold

        # time period over which we want spend the savings or recover the deficit 
        self.alpha = float(1.0/(10.0*self.budget_threshold)) #(unit: 1/sec)
        #self.alpha = float(1.0/500)

        # what is the current budget (unit: message/sec)
        self.current_budget = self.given_budget

        self.budget_in_hand = 0.0


    def init_location(self, curr_loc_param):
        #self.cleanup_last_window()
        
        self.delay_window = [curr_loc_param]
        self.server_loc_param = None
        self.current_time = curr_loc_param[0].time

        self.estimation_window = [curr_loc_param]

        self.time_error_table = {}

        self.start_time = self.current_time

        
        # NOTE: uncomment to start budget calculation seperately for new trip and don't count budget in the case of not sending in cleaup_last_window()
        # self.current_budget = self.given_budget
        #self.budget_in_hand = 0.0


    def update_budget(self, budget_in_hand_from_last_tx):
          self.budget_in_hand += budget_in_hand_from_last_tx

          self.current_budget = self.given_budget + self.alpha * self.budget_in_hand
          
          if ((1.0/self.current_budget) > (MAX_HISTORY-self.delay_threshold)) or self.current_budget<0.0:
              self.current_budget = 1.0/(MAX_HISTORY-self.delay_threshold)


    def cleanup_last_window(self):
        # transmit only if we have budget
        if debug2_cleanup:
            print self.budget_in_hand

        if self.delay_window:
            end_time = self.delay_window[-1][0].time
            duration = end_time - self.start_time
            
            timegap_from_last_tx = self.delay_window[-1][0].time - self.server_loc_param[0].time
            messages_from_last_tx = timegap_from_last_tx/self.budget_threshold
            

            if ( (self.current_budget + self.alpha * (self.budget_in_hand + messages_from_last_tx - 1.0)) >= self.given_budget ): # we have budget to send               
                if debug2:
                    print "last tx..."

                self.server_loc_param = self.server.update_locations(self.delay_window)
                self._flush_delay_window()

                # update the budget in hand and current budget (as propagated to future trips)
                budget_in_hand_from_last_tx = messages_from_last_tx - 1.0
                self.update_budget(budget_in_hand_from_last_tx)

                if debug2:
                    print "timegap_last_tx:", str(timegap_from_last_tx).rjust(6), "message_last_tx:", str(messages_from_last_tx).rjust(15),\
                        "budget_in_hand:", str(self.budget_in_hand).rjust(15), "current_budget:", str(self.current_budget).rjust(15), " ", str(1.0/self.current_budget).rjust(15)
                    print duration, "start:", self.start_time, "end:", end_time, "CLEANUP LAST WINDOW"
                    print "\n"


            else: # we dont't have budget to tx this last window, but still we need to update the current budget for future
                budget_in_hand_from_last_tx = messages_from_last_tx # we just add what ever savings/deficit we have. NOT substract -1 as we didn't transmit
                self.update_budget(budget_in_hand_from_last_tx)
                
            


    def transmit_locations(self):
        if not self.delay_window: #empty window, nothing to do
            return

        if (self.current_time - self.delay_window[0][0].time < self.delay_threshold): #fill the delay window if within threshold
            return

        else: # need to process the delay window

            if (self.server_loc_param is None): # the very first window
                self.server_loc_param = self.server.update_locations(self.delay_window)       
                self._flush_delay_window()

                #update the budget. By transmitting the first window, we are in deficit of 1 message
                budget_in_hand_from_last_tx = -1.0
                self.update_budget(budget_in_hand_from_last_tx)

                #if debug2:
                #    print "timegap_last_tx:", str(0).rjust(6), "message_last_tx:", str(-1).rjust(15), "budget_in_hand:", str(self.budget_in_hand).rjust(15), \
                #        "current_budget:", str(self.current_budget).rjust(15),  str(1.0/self.current_budget).rjust(15)

                return
    
            
            #print self.server_loc_param[0].time, map(lambda loc_param: loc_param[0].time-self.server_loc_param[0].time, self.delay_window)

            messages_from_last_tx = None

            extrapolation_errors = self.get_extrapolation_errors(self.server_loc_param, self.delay_window)

            #total_extrapolation_error_for_window = sum(extrapolation_errors)
            total_extrapolation_error_for_window = sum(extrapolation_errors)/len(extrapolation_errors)
            
            delay_window_time_len = self.delay_window[-1][0].time - self.delay_window[0][0].time

            # 1.0/self.current_budget is budget_period in terms of seconds. 
            # So if we have savings we look ahead for expected error and 
            # if we have deficit the we look late
            expected_window_time_offsets = range(int(1.0/self.current_budget), int(1.0/self.current_budget + delay_window_time_len + 1))

            #print self.server_loc_param[0].time, self.current_time, self.delay_threshold, map(lambda loc_param: loc_param[0].time, self.delay_window)
            
            time_offsets = map(lambda loc_param: (loc_param[0].time - self.server_loc_param[0].time), self.delay_window)
            #print "time_offsets:", time_offsets, "expt_offsets:", expected_window_time_offsets
            
            #expected_error = self.get_expected_error_for_timelist(expected_window_time_offsets)                
            expected_error = self.get_mean_expected_error_for_timelist(expected_window_time_offsets)                
            
            #print total_extrapolation_error_for_window, expected_error, 1.0/self.current_budget
            

            if(total_extrapolation_error_for_window > expected_error): # we are sending one message 
                if debug: print "tx as error over expected"
                
                timegap_from_last_tx = self.delay_window[-1][0].time - self.server_loc_param[0].time
                messages_from_last_tx = timegap_from_last_tx/self.budget_threshold

                #print "tx as error over expected ", timegap_from_last_tx, messages_from_last_tx
                
                budget_in_hand_from_last_tx = messages_from_last_tx-1.0
                self.update_budget(budget_in_hand_from_last_tx)
                
                if debug2:
                    print "timegap_last_tx:", str(timegap_from_last_tx).rjust(6), "message_last_tx:", str(messages_from_last_tx).rjust(15), \
                        "budget_in_hand:", str(self.budget_in_hand).rjust(15), "current_budget:", str(self.current_budget).rjust(15), " ", str(1.0/self.current_budget).rjust(15)

                    
                self.server_loc_param = self.server.update_locations(self.delay_window)
                self._flush_delay_window()

            else:
                if debug: print "no tx"

                #self._flush_delay_window()
                del self.delay_window[0]

