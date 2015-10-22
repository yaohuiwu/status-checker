#!/usr/bin/python

import ConfigParser, os, re

config = ConfigParser.SafeConfigParser()
with open('config.ini') as f:
	config.readfp(f)

coprocessors=re.split('\s*,\s*', config.get('Coprocessors','coprocessors'))
tables=re.split('\s*,\s*',config.get('Audit Tables','tables'))
print coprocessors
print tables
