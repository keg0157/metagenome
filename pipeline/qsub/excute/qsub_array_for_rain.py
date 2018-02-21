#!/usr/bin/env python
# -*- coding: utf-8 -*-
#usage:python qsub_array.py *.sh qsub_option

import sys
import os
import os.path

class Work:
	def __init__(self):
		if len(sys.argv) == 1:
			print "usage: "
			print "qsub_array.py xx.sh options"
			sys.exit()
		else:
			self.run_script = sys.argv[1]
			self.options = sys.argv[2:]
			self.cwd = os.getcwd().split("/MD")[1]
			self.scripts = []
	
	def run(self):
		self.make_directories()
		self.make_scripts()
		self.make_array_jobs()
		self.submit_jobs()

	def make_directories(self):
		if not os.path.isdir(self.cwd + "/Log"):
			os.mkdir(self.cwd + "/Log" )
		if not os.path.isdir(self.cwd + "/submit_jobs"):	
			os.mkdir(self.cwd + "/submit_jobs" )

	def make_scripts(self):
		i = 0
		for line in open(self.run_script):
			script_file = self.cwd + "/submit_jobs/" + str(i).zfill(5) + ".sh"
			outrun_script = open(script_file,"w")
			outrun_script.write(line.split("/MD")[0] + line.split("/MD")[1])
			i += 1 
			self.scripts.append(script_file)
			os.chmod(script_file, 0777)
	
	def make_array_jobs(self):
		outfile = open(self.cwd + "/job_array.sh","w" )
		outfile.write("#!/bin/sh" + "\n")
		outfile.write("#$ -S /bin/bash" + "\n")
		outfile.write("#$ -t 1-{0}".format(len(self.scripts)) + "\n")
		outfile.write("#$ -e {0}/Log".format(self.cwd) + "\n")
		outfile.write("#$ -o {0}/Log".format(self.cwd) + "\n")
		outfile.write("#$ -N {0}".format(os.path.basename(self.run_script)) + "\n")
		#outfile.write("\#$ -tc 50)

		outfile.write("case $SGE_TASK_ID in" + "\n")
		i = 0
		for line in self.scripts:
			outfile.write(str(i + 1) + ")"+ "\n")
			outfile.write(line.rstrip() + ";;"+ "\n")
			i += 1
		outfile.write("esac")
		outfile.close()

	def submit_jobs(self):
		#os.system("qsub " + self.cwd + "/job_array.sh " + " ".join(self.options))
		os.system("qsub " + " ".join(self.options) + " " + self.cwd + "/job_array.sh ")
		
		
work = Work()
work.run()

