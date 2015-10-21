import sys
import re

def readFileAsDict(fileNm):
	dic=dict()
	with open(fileNm) as f:
		for line in f:
			items = re.split('\s+', line.rstrip())
			if(len(items) != 2):
				continue
			dic[items[0]]= items[1]	
	return dic
