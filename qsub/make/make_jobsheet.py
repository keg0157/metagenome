# python make_jobsheet.py *.sh(abs) dir(samplename) taskname
import sys
import os

sh = sys.argv[1]
dir = open(sys.argv[2],"r")
if len(sys.argv) == 3:
    output = open(sys.argv[1].rsplit("/",1)[1].rsplit(".sh",1)[0]+"_sheet.sh","w")
if len(sys.argv) == 4:
    output = open(sys.argv[3],"w")

dir_array=[]

for line in dir:
    dirname = line.split("\n")[0]
    if dirname[0] != "/":
        tmp = "/" + dirname
    else:
        tmp = dirname

    if tmp[-1] != "/":
        directory = tmp + "/"
    else:
        directory = tmp
    dir_array.append(os.getcwd() + directory)

for directory in dir_array:
    output.write("sh "+ sh + "\t" + directory + "\n")


