#python convert_fq2fa.py *fastq.N.rem.trim.over50.aqv.md

import sys
result=""
count=0

fastq = open(sys.argv[1],"r")
output = open(sys.argv[1] + ".fasta","w")

for line in fastq:
    count += 1
    if count % 4 == 1:
        result += ">" + line[1:]
    elif count % 4 == 2:
        result += line
    else:
        continue

output.write(result)
