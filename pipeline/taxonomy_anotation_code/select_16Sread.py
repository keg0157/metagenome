#python .paired.fasta vit16s.res

import sys
vit_dict={}
result=""

f=open(sys.argv[1],"r")
F=open(sys.argv[2],"r")
o=open(sys.argv[1] +  ".vit16s","w")

for line in F:
    name=line.split("\t")[0]
    if vit_dict.has_key(name) == False: 
        vit_dict[name] = 1

for line in f:
    if line.startswith(">"):
        readID = line[1:][:-1]
    else:
        if vit_dict.get(readID) == 1:
            result += ">" + readID + "\n" + line

o.write(result)
       
        
    
