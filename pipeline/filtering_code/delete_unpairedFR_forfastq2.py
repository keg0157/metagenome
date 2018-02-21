#python delete_unpairidFR.py *1.fastq.N.rem.trim.over50.aqv.fasta.md *2.fastq.N.rem.trim.over50.aqv.fasta.md

import sys
Fread_dict={}
Rread_dict={}
Fread = 0
Rread = 0
count_F = 0
count_R = 0
Pairedread = 0
result_F = ""
result_R = ""

F = open(sys.argv[1],"r")
R = open(sys.argv[2],"r")
O1 =open(sys.argv[1]+".paired","w")
O2 =open(sys.argv[2]+".paired","w")


for line in F:
    count_F += 1
    Fread += 1
    if count_F % 4 == 1:
        readname = line[1:].split(" ")[0]
        readID = line
    elif count_F % 4 ==2:
        seq = line
    elif count_F % 4 ==3:
        plus = line
    elif count_F % 4 ==0:
        Fread_dict[readname] = readID + seq + plus + line

for line in R:
    count_R += 1
    Rread += 1
    if count_R % 4 ==1:
        readname = line[1:].split(" ")[0]
        readID = line
    elif count_R % 4 ==2:
        seq = line
    elif count_R % 4 ==3:
        plus = line
    elif count_R % 4 ==0:
        Rread_dict[readname] = readID + seq + plus + line

for key in Fread_dict:
    if  Rread_dict.has_key(key) == True:
    	result_F += Fread_dict[key]
        result_R += Rread_dict[key]
        Pairedread += 1

print str(int(Fread) + int(Rread) - 2*int(Pairedread)) + " reads unpaierd"
O1.write(result_F)
O2.write(result_R)
