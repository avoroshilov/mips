#!/usr/bin/python

import sys
import random
import shutil

def id_generator(size=8, chars="0123456789abcdef"):
	return ''.join(random.choice(chars) for _ in range(size))

data_memory_out = "./data/data_memory.txt"
data_memory_gold = "./data/data_memory_gold.txt"

if len(sys.argv) < 3:
	print "Wrong arguments number.\nUsage:\n%s <entry_numbers> <rand/zero/seq>" % sys.argv[0]
	exit(1)
else:
	if ((sys.argv[2] != "zero") and (sys.argv[2] != "rand") and (sys.argv[2] != "seq")):
		print "Wrong argument %s. Should be \"rand\" or \"zero\"" % sys.argv[2]
		exit(1)
	f = open(data_memory_out, "w")
	for i in xrange(int(sys.argv[1])):
		if sys.argv[2] == "zero":
			f.write("00000000\n")
		elif sys.argv[2] == "rand":
			f.write("%s\n" % id_generator())
		else:
			f.write("%s\n" % (str(i).zfill(8)))
	f.close()
	shutil.copyfile(data_memory_out, data_memory_gold)
	exit(0)
