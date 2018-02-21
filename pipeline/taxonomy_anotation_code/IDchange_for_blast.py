#python IDchange_for_blast.py fasta_using_blast
import sys

fasta = open(sys.argv[1],"r")
output = open(sys.argv[1] + ".IDchange","w")
result = ""

for line in fasta:
    if line.startswith(">"):
        tmp =line[:-1].split(" ")
        tmp2 = "_".join(tmp)
        ID = tmp2 + "___" + sys.argv[1].rsplit("/",1)[-1].split(".1.fastq.N")[0]
        result += ID + "\n"
    else:
        result += line
output.write(result)
 
