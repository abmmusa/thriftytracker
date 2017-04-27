#!/bin/bash

#get kml files
scp words3:sensys13/kml_files/* kml_files/

#get splitted files
scp words3:sensys13/splitted_traces/* splitted_traces/

#get time_error_table_offline
scp words3:sensys13/time_error_table_offline/* time_error_table_offline/
