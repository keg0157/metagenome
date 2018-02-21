#python del_humangenome.py *fasta bowtied_human_genome.sam
import sys
del_read={}
result=""
count=0

fastq = open(sys.argv[1],"r")
sam = open(sys.argv[2],"r")
output = open(sys.argv[1]+".md","w")

for LINE in sam:
    del_read[LINE.split("\t")[0]] = 1
    
for line in fastq:
    count += 1
    if count % 4 ==1:
        readname = line[1:].split(" ")[0]
        readID = line
    elif count % 4 ==2:
        seq = line
    elif count % 4 ==3:
        plus = line
    elif count % 4 ==0:
        if del_read.get(readname) != 1:
            result += readID + seq + plus + line 

print str(len(del_read)) + " reads deleted"
output.write(result)
        
    
    
