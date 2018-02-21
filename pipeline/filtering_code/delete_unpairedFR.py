#python delete_unpairidFR.py *1.fastq.N.rem.trim.over50.aqv.fasta.md *2.fastq.N.rem.trim.over50.aqv.fasta.md

import sys
Fread_dict={}
Rread_dict={}
Fread=0
Rread=0
Pairedread=0
result=""

F = open(sys.argv[1],"r")
R = open(sys.argv[2],"r")
O =open(sys.argv[1]+".paired.fasta","w")

for line in F:
    if line.startswith(">"):
        readID = line[1:].split(" ")[0]
        Fread_dict[readID] = line
        Fread += 1 
    else:
        Fread_dict[readID] += line

for line in R:
    if line.startswith(">"):
        readID = line[1:].split(" ")[0]
        Rread_dict[readID] = line
        Rread += 1
    else:
        Rread_dict[readID] += line

for key in Fread_dict:
    if  Rread_dict.has_key(key) == True:
        result += Fread_dict[key] + Rread_dict[key]
        Pairedread += 1

print str(int(Fread) + int(Rread) - 2*int(Pairedread)) + " reads unpaierd"
O.write(result)
