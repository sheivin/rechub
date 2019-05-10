'''
Common methods here.
'''

import os
import time
from binascii import hexlify


# return random hash
def get_hash():
	return str(hexlify(os.urandom(16)), 'ascii')

# return timestamp
def get_timestamp():
	return int(round(time.time()))