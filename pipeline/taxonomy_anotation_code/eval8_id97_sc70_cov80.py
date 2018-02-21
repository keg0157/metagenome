#python eval8_id97_sc70_cov80.py *vit16s.LTP *fasta.vit16s.ssu 

import sys 
vit_res = open(sys.argv[1],"r")
fasta = open(sys.argv[2],"r")
output = open(sys.argv[1]+".id97.sc70.cov80","w")


result=""
fasta_dict={}
silva_dict={}
cul_check_dict={}

for line in fasta:
    if line.startswith(">"):
        name = line[1:][:-1]
    else:
        fasta_dict[name] = len(line) -1


for line in vit_res:
    print line.split("\t")[1]
    name = line.split("\t")[0]
    hits = line.split("\t")[1]
    ID = line.split("\t")[2]
    evalue = float(line.split("\t")[10])
    score = float(line.split("\t")[11])
    hit_length = int(line.split("\t")[7]) - int(line.split("\t")[6])
    all_length = fasta_dict[name]
    if hit_length / float(all_length) > 0.8 and ID > 97 and score > 70 and evalue < 1e-8:
        result += line
       
output.write(result)
