#python del_humangenome.py *fasta bowtied_human_genome.sam
import sys
fasta_dict={}
del_read={}
result=""

fasta = open(sys.argv[1],"r")
sam = open(sys.argv[2],"r")
output = open(sys.argv[1]+".md","w")

for LINE in sam:
    del_read[LINE.split("\t")[0]] = 1
    
for line in fasta:
    if line.startswith(">"):
        readname = line[1:].split(" ")[0]
        fasta_dict[readname] = line
    else:
        fasta_dict[readname] += line

for key in fasta_dict:
    if del_read.get(key) != 1:
        result += fasta_dict[key]

print str(len(del_read)) + " reads deleted"
output.write(result)
        
    
    
