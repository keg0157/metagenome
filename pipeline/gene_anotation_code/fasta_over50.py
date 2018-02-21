#python fasta_over50.py *gff.aa.fasta
import sys
result=""
delcount=0
fasta_dict={}

f=open(sys.argv[1],"r")
o=open(sys.argv[1]+".over50","w")

for line in f:
    if line.startswith(">"):
        read_name = line[:-1]
        fasta_dict[read_name] = ""
    else:
        fasta_dict[read_name] += line.split("\n")[0]

for key in sorted(fasta_dict.keys()):
    if len(fasta_dict[key]) >= 50:
        result += key + "\n" + fasta_dict[key] + "\n"
    else:
        delcount += 1
o.write(result)
print str(delcount) + " reads are deleted"        

