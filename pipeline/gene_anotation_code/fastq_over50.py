#python fastq_over50.py fastq
import sys
result=""
readcount=0
delcount=0
fastq_dict={}

o = open(sys.argv[1]+".over50","w")
f = open(sys.argv[1],"r")
for line in f:
    readcount += 1
    if readcount % 4 == 1:
        readname = line[1:]
        fastq_dict[readname] = line
    else:
        fastq_dict[readname] += line

for key in fastq_dict:
    contents = fastq_dict[key]
    if len(contents.split("\n")[1]) >= 50:
        result += fastq_dict[key]
    else:
        delcount += 1   

print str(delcount) + " deleted"
o.write(result)
