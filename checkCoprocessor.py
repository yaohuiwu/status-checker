#!/usr/bin/python

import sys
import logging
import re
import xml.etree.ElementTree as ET

if(len(sys.argv) < 2):
	print 'usage: checkCoprocessor.py <src hosts file> <target hosts file>'
	sys.exit(1)

srcFile=sys.argv[1]

# check if coprocessor configed
tree = ET.parse(srcFile)
root = tree.getroot()
classes=[]
for prop in root:
	nameTxt=prop[0].text
	if(nameTxt == 'hbase.coprocessor.region.classes'):
		classes=re.split('\s*,\s*', prop[1].text)
		break

print 'find {0} coprocessors: {1}'.format(len(classes), classes)
