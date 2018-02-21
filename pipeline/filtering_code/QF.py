#python QF.py *fastq ascii
import sys
ascii_dir={}
result=""
count=0
delcount=0

fastq = open(sys.argv[1],'r')
asciifile = open(sys.argv[2],"r")
output = open(sys.argv[1]+".aqv",'w')

for line in asciifile:
    ascii_dir[line.split("\t")[0]] = int(line.split("\t")[1]) - 33

for line in fastq:
    count += 1
    if count % 4 == 1:
        one = line
    elif count % 4 == 2:
        two = line
    elif count % 4 == 3:
        three = line 
    elif count % 4 == 0:
        sumQ=0 ; Qnum=0
        for Q in list(line[:-1]):
            if ascii_dir.has_key(Q):
                sumQ += ascii_dir[Q]
            Qnum += 1
        if sumQ * 1.0 / Qnum < 25:
            delcount +=1 
        else:
            result += one + two + three + line

print str(delcount) + " reads deleted" 
output.write(result)
