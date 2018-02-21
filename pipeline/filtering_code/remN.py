#python remN.py *fastq
import sys
result=""
count=0
delcount=0

fastq = open(sys.argv[1],'r')
output = open(sys.argv[1]+".N",'w')

for line in fastq:
    count += 1
    if count % 4 == 1:
        name = line
    elif count % 4 == 2:
        seq = line
    elif count % 4 == 3:
        plus = line
    else:
        if "N" not in seq and "n" not in seq:
            result += name + seq + plus + line
        else:
            delcount += 1
            
print str(delcount) + " reads deleted"
output.write(result)
