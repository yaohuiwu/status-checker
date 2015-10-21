#!/usr/bin/python

import sys
import logging
import re
import fileUtil

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
		#print 'ok ' + k + '->' + cfgMap[k]	
		print 'ok'
	else:
		logging.error('ip host map %s -> %s not found in %s', k, cfgMap[k], destFile)
		errorCount+=1

if(errorCount == 0):
	print 'HOSTS: ' + destFile + ' is ok'
else:
	print 'error in ' + destFile 
