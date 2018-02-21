#python id40_sc70_cov80.py *.res.parsed *scaffold.gff.aa.fasta.over50 /home/masudakeigo/DB/taxonomy.strain_to_eukary_or_prokary 

import sys 
ghost_res = open(sys.argv[1],"r")
gff = open(sys.argv[2],"r")
taxonomy = open(sys.argv[3],"r")
o = open(sys.argv[1]+".id40.sc70.cov80","w")

result=""
taxonomy_dict={}
gff_dict = {}

# make taxonomy_dict
for LINE in taxonomy:
    taxonomy_dict[LINE.split("\t")[0]] = LINE.split("\t")[1][:-1]

#get gene length from gff
for LINE in gff:
    if LINE.startswith(">"):
        NAME = LINE.split(">")[1][:-1]
    else:
        gff_dict[NAME] = len(LINE)

#calculate hit_length from blast and ID score taxnomy filter
for line in ghost_res:
    name = line.split("\t")[0]
    ID = float(line.split("\t")[2])
    score = float(line.split("\t")[11])
    genus = line.split("\t")[1].split(":")[0]
    hit_length = int(line.split("\t")[7]) - int(line.split("\t")[6])
    all_length = gff_dict[name]
    if float(hit_length) / all_length >= 0.8 and ID > 40 and score > 70 and taxonomy_dict.get(genus) != "Eukaryotes":
        result += line[:-1] + "\t" + str(taxonomy_dict.get(genus)) + "\n"

o.write(result)
        
    
