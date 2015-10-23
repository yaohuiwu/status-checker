#!/usr/bin/python

import sys
import re
import fileUtil
from config import log

if(len(sys.argv) < 3):
	print 'usage: host.py <src hosts file> <target hosts file>'
	sys.exit(1)

srcFile=sys.argv[1]
destFile=sys.argv[2]

#print "comparing file " +  srcFile + " with " + destFile


hMap=fileUtil.readFileAsDict(destFile)
cfgMap=fileUtil.readFileAsDict(srcFile)

#print hMap
errorCount=0

for k in cfgMap.keys():
	if(k in hMap and cfgMap[k] == hMap[k]):
		continue
	else:
		logging.error('ip host map %s -> %s not found in %s', k, cfgMap[k], destFile)
		errorCount+=1

guessHost='localhost'
if(destFile.endswith('.hosts')):
	guessHost=destFile[0:destFile.index('.hosts')]

if(errorCount == 0):
	log.info('host file on %s : ok', guessHost)
else:
	log.error('host file on %s : error', guessHost)
