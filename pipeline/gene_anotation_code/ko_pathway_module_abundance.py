#python ko_composition.py *.res.parsed.id40.sc70.cov80 scaffold_bowtied.sam.genehits /home/masudakeigo/DB/genes_ko.list /home/masudakeigo/DB/pathway_ko_list /home/masudakeigo/DB/module_ko_list

import sys
gene_ko_dict={}
ko_path_dict={}
ko_composition_dict={}
ko_modu_dict={}
hits_dict={}
ko_hits_dict={}
gene_ratio_dict={} 
uscg_ko=[]
result_ko=""
result_ko_composition=""
result_path=""
result_modu=""

file_ghost = open(sys.argv[1],"r")
file_genehits = open(sys.argv[2],"r")
#file_uscg = open(sys.argv[3],"r")
file_ko = open(sys.argv[3],"r")
file_path = open(sys.argv[4],"r")
file_modu = open(sys.argv[5],"r")
output_ko = open(sys.argv[1] + ".KO","w")
output_ko_composition = open(sys.argv[1] + ".KO_composition","w")
output_path = open(sys.argv[1] + ".Pathway","w")
output_modu = open(sys.argv[1] + ".Module","w")

# make 5 dictionaries 1 uscg array
for line in file_ko:
    gene_ko_dict[line.split("\t")[0]] = line.split("\t")[1][:-1]

for line in file_path:
    ko_path_dict[line.split("\t")[0]] = line.split("\t",1)[1][:-1]

for line in file_modu:
    ko_modu_dict[line.split("\t")[0]] = line.split("\t",1)[1][:-1]

for line in file_genehits:
    gene_num = line.split("\t")[1].split("_")[-1].zfill(8)
    cov = float(line.split("\t")[3])
    hits_dict[gene_num] = cov

#for line in file_uscg:
#    uscg_ko.append(line.split("\t")[1][:-1])

# calculate gene_ratio 
for line in file_ghost:
    gene_num = line.split("\t")[0].split("_")[-1] 
    hit_gene_name = line.split("\t")[1].split(" ")[0]
    hits_ratio = line.split("\t")[-2]
    if hits_dict.has_key(gene_num) == True:
        if gene_ratio_dict.has_key(hit_gene_name) == False:
            gene_ratio_dict[hit_gene_name] = float(hits_ratio) * hits_dict.get(gene_num)
        else:    
            gene_ratio_dict[hit_gene_name] += float(hits_ratio) * hits_dict.get(gene_num)
			
# convert gene_hits to ko_hits
for gene_name in gene_ratio_dict:
    if gene_ko_dict.has_key(gene_name) == True: 
        if ko_hits_dict.has_key(gene_ko_dict[gene_name]) == False:
			ko_hits_dict[gene_ko_dict[gene_name]] = gene_ratio_dict[gene_name]
        else:
			ko_hits_dict[gene_ko_dict[gene_name]] += gene_ratio_dict[gene_name]
    else:
    	if ko_hits_dict.has_key("None") == False:
        	ko_hits_dict["None"] = gene_ratio_dict[gene_name]
    	else:
       		ko_hits_dict["None"] += gene_ratio_dict[gene_name]

# convert gene_hits to ko_composition
for gene_name in gene_ratio_dict:
	if gene_ko_dict.has_key(gene_name) == True:
		ko_sp_name = gene_name.split(":")[0] + ":" + gene_ko_dict[gene_name].split(":")[1]
		if ko_composition_dict.has_key(ko_sp_name) == False:
			ko_composition_dict[ko_sp_name] = gene_ratio_dict[gene_name]
		else:
			ko_composition_dict[ko_sp_name] += gene_ratio_dict[gene_name]
			       			
# calculate uscg hits
#uscg_hits_sum = 0
#uscg_count = 0
#for ko in uscg_ko:
#    if ko_hits_dict.has_key("ko:"+str(ko)) == True:
#        uscg_hits_sum += ko_hits_dict["ko:"+str(ko)]
#        uscg_count += 1
#print str(uscg_count) + " uscg included"  # 36 uscg in general
#uscg_ave = float(uscg_hits_sum) / int(uscg_count) 

# corrected by uscg hits
for ko in ko_hits_dict:
    result_ko += str(ko) + "\t" +  str(ko_hits_dict[ko]) + "\n"

for sp_ko in ko_composition_dict:
    result_ko_composition += str(sp_ko) + "\t" +  str(ko_composition_dict[sp_ko]) + "\n"

for path in ko_path_dict:
    sum_path = 0
    tmp = ko_path_dict[path]
    arr = tmp.split("\t") 
    for ko in arr:
        if ko_hits_dict.has_key(ko) == True:
            sum_path += ko_hits_dict[ko] 
    if sum_path != 0:
        result_path += str(path) + "\t" +  str(sum_path)  + "\n"

for modu in ko_modu_dict:
    sum_modu = 0
    tmp = ko_modu_dict[modu]
    arr = tmp.split("\t")
    for ko in arr:
        if ko_hits_dict.has_key(ko) == True:
            sum_modu += ko_hits_dict[ko]
    if sum_modu != 0:
        result_modu += str(modu) + "\t" +  str(sum_modu)  + "\n"


output_ko.write(result_ko)
output_ko_composition.write(result_ko_composition)
output_path.write(result_path)
output_modu.write(result_modu)
