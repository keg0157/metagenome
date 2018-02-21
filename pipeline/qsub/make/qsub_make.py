#!/usr/bin/python
# coding: UTF-8

# python qsub_make.py sh_script sample_list

import sys
import os
f = open(sys.argv[1],"r")
contents = f.read()
f.close

F = open(sys.argv[2],"r")
sample_list=F.read().split("\n")
for sample_name in sample_list:
    if not os.path.exists("./Shell_puts/"):
        os.mkdir("./Shell_puts/")
    F = open("./Shell_puts/" + sample_name + ".sh" ,"w")
    F.write(contents.replace("DDDDD",sample_name))
    F.close() 
