#mapper code
# udacity - intro to Hadoop and MapReduce

import sys

# read standard input line by line
for line in sys.stdin:
	# strip off extra whitespace, split on tab and put the data in an array
	data = line.strip().split("\t")

	if len(data) != 6:
        # Something has gone wrong. Skip this line.
        continue
		
	#assign data
	date, time, store, item, cost, payment = data
	
	#print data to pass to reducers
	print "{0}\t{1}".format(item, cost)
        