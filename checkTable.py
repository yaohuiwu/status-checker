#!/usr/bin/python

import sys
import re
import config
from config import log

# $1 status lines like '2 servers, 0 dead, 8.5000 average load'
# $2 table lines
statusStr=sys.argv[1]
if(statusStr.find('0 dead') != -1):
	log.info('Hbase status ok')
else:
	log.error('Hbase status error')
	#if error found , no table checking will be done.
	sys.exit(1)

tblString=sys.argv[2]
tblList=re.split('\s+', tblString)

errorCount=0
tblNotFound=[]
for tbl in config.tables:
	if(tbl in tblList):
		continue
	else:
		errorCount +=1
		tblNotFound.append(tbl)

if(errorCount == 0):
	log.info('hbase tables ok')
else:
	log.error('tables not found: %s', tblNotFound)
