#python over50.QF.py *fastq ascii
from __future__ import division
import sys
ascii_dir={}
result=""
count=0
count_under50=0
count_badq=0

fastq = open(sys.argv[1],'r')
asciifile = open(sys.argv[2],"r")
output = open(sys.argv[1]+".over50.aqv",'w')

for line in asciifile:
    ascii_dir[line.split("\t")[0]] = int(line.split("\t")[1]) - 33

for line in fastq:
    count += 1
    sumQ=0;Qnum=0
    if count % 4 == 1:
        name = line
    elif count % 4 == 2:
        seq = line
    elif count % 4 == 3:
        plus = line 
    elif count % 4 == 0:
        for Q in list(line[:-1]):
            if ascii_dir.has_key(Q):
                sumQ += ascii_dir[Q]
            Qnum += 1
        if len(seq) > 50: #rem \n >=50
            if sumQ/Qnum >= 25:
                result += name + seq + plus + line
            else:
                count_badq += 1
        else:
            count_under50 += 1

print  str(count_under50) + " reads deleted because of under 50"
print  str(count_badq) + " reads deleted because of bad quality" 
output.write(result)
