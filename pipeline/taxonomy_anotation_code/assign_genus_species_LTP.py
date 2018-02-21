#python assign_genus_species.LTP.py vit16s.LTP.res.parsed taxon_information
import sys

blast = open(sys.argv[1],"r")
taxon_information  = open(sys.argv[2],"r")

output1 = open(sys.argv[1] + ".sample.hits.LTP_genus","w")
output2 = open(sys.argv[1] + ".sample.hits.LTP_species","w")
output3 = open(sys.argv[1] + ".sample.hits.LTP_fulltaxon","w")

blast_dict_ge={}
blast_dict_sp={}
blast_dict_fulltaxon={}

taxon_dict={}
result_genus = ""
result_species = ""
result_fulltaxon = ""

for line in taxon_information:
	arr = line.split("\t")
	taxID = arr[0]
	taxon_dict[taxID] = ';'.join(arr[1:])

for line in blast:
    arr = line.split("\t")
    genus     = arr[1].split("_rna_")[1].rsplit("_",1)[0].split("_")[0]
    species     = arr[1].split("_rna_")[1].rsplit("_",1)[0]
    fulltaxon = taxon_dict[arr[1].split("_",1)[0]].rstrip()
    num      = float(arr[-1])
    sample   = arr[0].split("___")[-1]
    
    if blast_dict_ge.has_key(sample) == False:
        blast_dict_ge[sample]={}

    if blast_dict_sp.has_key(sample) == False:
        blast_dict_sp[sample]={}
    
    if blast_dict_fulltaxon.has_key(sample) == False:
        blast_dict_fulltaxon[sample]={}
    
    if blast_dict_ge[sample].has_key(genus) == False:
        blast_dict_ge[sample][genus] = num
    else:
        blast_dict_ge[sample][genus] += num
    
    if blast_dict_sp[sample].has_key(species) == False:
        blast_dict_sp[sample][species] = num
    else:
        blast_dict_sp[sample][species] += num

    if blast_dict_fulltaxon[sample].has_key(fulltaxon) == False:
        blast_dict_fulltaxon[sample][fulltaxon] = num
    else:
        blast_dict_fulltaxon[sample][fulltaxon] += num
		
   
for key1 in blast_dict_ge:
    for key2 in blast_dict_ge[key1]:
        result_genus += key2 + "\t" + str(blast_dict_ge[key1][key2]) + "\n"

for key1 in blast_dict_sp:
    for key2 in blast_dict_sp[key1]:
        result_species += key2 + "\t" + str(blast_dict_sp[key1][key2]) + "\n"

for key1 in blast_dict_fulltaxon:
    for key2 in blast_dict_fulltaxon[key1]:
        result_fulltaxon += key2 + "\t" + str(blast_dict_fulltaxon[key1][key2]) + "\n"

output1.write(result_genus)
output2.write(result_species)
output3.write(result_fulltaxon)

