#!/usr/bin/python

import sys
import re

# $1 csv like file 
source_file=sys.argv[1]
column_num=int(sys.argv[2])

columns=[]

with open(source_file) as f:
	for line in f:
		rows=re.split('\s+', line)
		if(column_num < len(rows)):
			columns.append(re.split('\s+', line)[column_num])

print ' '.join(columns)
