#python id_stage.py ko_table_nonmerge Correspondence_table.txt
import sys
import re
dictionary ={}
array=[]
put=""
tmp=""
X = 0
f = open(sys.argv[1],"r")
F = open(sys.argv[2],"r")
o = open(sys.argv[1]+"_stage","w")
for line in F:
    if line.split("\t")[0] != "":
        dictionary[line.split("\t")[0]] = line.split("\t")[1][:-1]

for line in f:
    tmp = line  
    if X == 0:
        for key in dictionary:
            if key in tmp:
                tmp2 = tmp.replace(key,dictionary[key])
                tmp = tmp2
        X = 1
        put += tmp
        continue
    put += line

o.write(put)
