#python /home/masuda/script/make_ko_module_pathway_table.py sample_list `pwd` 
import sys
import os
import datetime

dictionary_ko = dict()
dictionary_modu = dict()
dictionary_path = dict()
allko = dict()
allmodu = dict()
allpath = dict()
result_ko = ""
result_modu = ""
result_path = ""
count = 0
sample_list = []
sample_input = open(sys.argv[1],"r")
dirname = sys.argv[2]

for LINE in sample_input:
    sample = LINE.rstrip()
    sample_list.append(sample)
    result_ko += "\t" + sample
    result_modu += "\t" + sample
    result_path += "\t" + sample
    dictionary_ko[sample] = {}
    dictionary_modu[sample] = {}
    dictionary_path[sample] = {}
    input = open(dirname + "/" + sample + "/" + "ghostx.res.parsed.id40.sc70.cov80.KO","r")
    for line in input:
        ko = line.split("\t")[0]
        dictionary_ko[sample][ko] = line.split("\t")[1][:-1]
        if allko.has_key(ko) == False:
           allko[ko] = ko
    
    input = open(dirname + "/" + sample + "/" + "ghostx.res.parsed.id40.sc70.cov80.Module","r")
    for line in input:
        modu = line.split("\t")[0]
        dictionary_modu[sample][modu] = line.split("\t")[1][:-1]
        if allmodu.has_key(modu) == False:
           allmodu[modu] = modu

    input = open(dirname + "/" + sample + "/" + "ghostx.res.parsed.id40.sc70.cov80.Pathway","r")
    for line in input:
        path = line.split("\t")[0]
        dictionary_path[sample][path] = line.split("\t")[1][:-1]
        if allpath.has_key(path) == False:
           allpath[path] = path

result_ko += "\n"
result_modu += "\n"
result_path += "\n"

for row in allko:
    result_ko += row
    for sample in sample_list:
        if dictionary_ko[sample].has_key(row) == True:
            result_ko += "\t" + dictionary_ko[sample][row]
        else:
            result_ko += "\t" + "0"
    result_ko += "\n"
    
for row in allmodu:
    result_modu += row
    for sample in sample_list:
        if dictionary_modu[sample].has_key(row) == True:
            result_modu += "\t" + dictionary_modu[sample][row]
        else:
            result_modu += "\t" + "0"
    result_modu += "\n"
    
for row in allpath:
    result_path += row
    for sample in sample_list:
        if dictionary_path[sample].has_key(row) == True:
            result_path += "\t" + dictionary_path[sample][row]
        else:
            result_path += "\t" + "0"
    result_path += "\n"

output_ko = open(dirname + "/" + "ko_table" + "_" + str(datetime.date.today()).replace("-","_"),"w")    
output_modu = open(dirname + "/" + "modu_table" + "_" + str(datetime.date.today()).replace("-","_"),"w")    
output_path = open(dirname + "/" + "path_table" + "_" + str(datetime.date.today()).replace("-","_"),"w")    

output_ko.write(result_ko)
output_modu.write(result_modu)
output_path.write(result_path)

