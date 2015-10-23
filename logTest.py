#!/usr/bin/python

import logging
import logging.config

logger = logging.getLogger('my logger')
logger.setLevel(logging.DEBUG)

ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)

logger.info('my name is yaohui wu.')
#print coprocessors
#print tables

logging.config.fileConfig('logging.conf')
mylog=logging.getLogger('statusChecker')

mylog.debug('Hell debug')
