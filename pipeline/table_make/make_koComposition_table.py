#python /home/masudakeigo/script/make_koComposition_table.py sample_list `pwd`
import sys
import os
import datetime

dictionary = dict()
result = ""
count = 0
sample_input = open(sys.argv[1],"r")
dirname = sys.argv[2]
sample_list = []
allko_sp=dict()

for LINE in sample_input:
	sample = LINE.rstrip()
	sample_list.append(sample)
	result += "\t" + sample
	dictionary[sample] = {}
	inp = open(dirname + "/" + sample + "/" + "ghostx.res.parsed.id40.sc70.cov80.KO_composition","r")
	for line in inp:
		ko_sp = line.split("\t")[0]
		dictionary[sample][ko_sp] = line.split("\t")[1][:-1]
		if allko_sp.has_key(ko_sp) == False:
			allko_sp[ko_sp] = ko_sp
    
result += "\n"

for row in allko_sp:
    result += row
    for sample in sample_list:
        if dictionary[sample].has_key(row) == True:
            result += "\t" + dictionary[sample][row]
        else:
            result += "\t" + "0"
    result += "\n"
    
output = open(dirname + "/" + "koComposition_table" + "_" + str(datetime.date.today()).replace("-","_"),"w")    

output.write(result)

