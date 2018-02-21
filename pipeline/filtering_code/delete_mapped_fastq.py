#python del_mapped_fastq.py *fastq.N phix.sam
import sys
fastq_dict={}
del_read={}
result=""
count=0

fastq = open(sys.argv[1],"r")
sam = open(sys.argv[2],"r")
output = open(sys.argv[1]+".rem","w")

for line in sam:
    del_read[line.split("\t")[0]] = 1

for line in fastq:
    count += 1
    if count % 4 == 1: 
        readname = line[1:].split(" ")[0]
        fastq_dict[readname] = line
    else:
        fastq_dict[readname] += line

for key in fastq_dict:
    if del_read.get(key) != 1:
        result +=  fastq_dict[key]

print str(len(del_read)) + " reads deleted"
output.write(result)
