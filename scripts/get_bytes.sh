#!/bin/bash
header_size=32
payload_size=8
const=10
timestamp_size=4


cat | awk '{print (int( ((h+$1*p+c+t)/42) + 1))*42}' h=$header_size p=$payload_size c=$const t=$timestamp_size