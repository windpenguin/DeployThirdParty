import getopt
import os
import sys
import glob
import re

rt = ""
src_file = "CMakeListsTemp.txt"
tar_file = "CMakeLists.txt"

def print_usage():
	print('Usage: -r[run time library]')
	
opts,args = getopt.getopt(sys.argv[1:], 'r:', ['help'])
print(opts)
for name, value in opts:
	if name in ['--help']:
		print_usage()
		exit()
	elif name in ['-r']:
		rt = value
		
if rt == "":
	print_usage()
	exit()
	
f_src = open(src_file, "rb")
f_tar = open(tar_file, "wb")
lineno=0
for line in f_src:
	lineno = lineno + 1
	f_tar.write(line)
	
	if lineno == 98:
		f_tar.write("\r\n".encode('ascii'))
		rt_debug = "    SET(CMAKE_CXX_FLAGS_DEBUG \"${{CMAKE_CXX_FLAGS_DEBUG}} /{}d \")\r\n".format(rt)
		rt_release = "    SET(CMAKE_CXX_FLAGS_RELEASE \"${{CMAKE_CXX_FLAGS_RELEASE}} /{} \")\r\n".format(rt)
		f_tar.write(rt_debug.encode('ascii'))
		f_tar.write(rt_release.encode('ascii'))

f_src.close()
f_tar.close()