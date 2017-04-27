#!/bin/bash

python generate_test_trace.py > traces/simulation/trace.txt
gzip traces/simulation/trace.txt