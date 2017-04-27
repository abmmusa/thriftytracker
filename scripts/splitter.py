#split a single file to multiple files using blankline
#Usage: <stdin> | python splitter.py fileprefix

import sys
import os

input_data = (sys.stdin).readlines()

counter=0
content=[]

for data in input_data:
    if (data == "\n"):
        outfilename = sys.argv[1]+"_"+str(counter)
        outfile = open(outfilename, 'w')
        for c in content:
            outfile.write("%s" % c)
        outfile.close()

        content=[]
        counter = counter + 1
    else:
        content.append(data)
