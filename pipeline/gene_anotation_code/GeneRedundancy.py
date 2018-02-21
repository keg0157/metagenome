#python GeneRedundancy.py scaffold_bowtied.sam  *_scaffold.gff
import sys
import re
f=open(sys.argv[1],"r")
F=open(sys.argv[2],"r")
o=open(sys.argv[1] + ".genehits","w")

prev_scaID=""
result=""
scagene_dict={}
merge_dict={}
genestart_dict={}
genestop_dict={}
scagene_count_dict={}
genehits_dict={}

for LINE in F:
    if not LINE.startswith("#") and len(LINE) != 1:
        scaID = LINE.split("\t")[0]
        genestart = LINE.split("\t")[3]
        genestop = LINE.split("\t")[4]
        geneID = LINE.split("\t")[8].split(",")[0].replace('=', '_')
        merge = scaID + "\t" + geneID
        if prev_scaID == scaID:
            scagene_dict[scaID][gene_count] = geneID
            merge_dict[scaID][gene_count] = merge
            genestart_dict[merge] = int(genestart)
            genestop_dict[merge] = int(genestop)
            scagene_count_dict[scaID] += 1
            gene_count += 1
        else:
            gene_count = 0
            scagene_dict[scaID]={}
            merge_dict[scaID]={}
            scagene_dict[scaID][gene_count] = geneID
            merge_dict[scaID][gene_count] = merge
            genestart_dict[merge] = int(genestart)
            genestop_dict[merge] = int(genestop)
            scagene_count_dict[scaID] = 1
            gene_count = 1
            prev_scaID = scaID

for line in f:
    scaID = line.split("\t")[2]
    mapstart = int(line.split("\t")[3])
    tmp = line.split("\t")[5]
    tmp2 = tmp.split("M")
    maplength = 0
    for contents in tmp2:
        if contents.isdigit() == True:
            maplength += int(contents)
        elif len(contents) != 0:
            num = re.findall(r'[0-9]+',contents)
            maplength += int(num[len(num)-1])
    mapstop = mapstart + maplength
    if scagene_count_dict.has_key(scaID) == True:
        count = scagene_count_dict[scaID]
        for i in range(count):
           if genestart_dict[merge_dict[scaID][i]] > mapstop:
               continue
           elif genestart_dict[merge_dict[scaID][i]] <= mapstop:
               if genestop_dict[merge_dict[scaID][i]] < mapstart:
                   continue
               else:
                   if genestart_dict[merge_dict[scaID][i]] > mapstart:
                       if genestop_dict[merge_dict[scaID][i]] <= mapstop:
                           overlap = genestop_dict[merge_dict[scaID][i]] - genestart_dict[merge_dict[scaID][i]] + 1
                       else:
                           overlap = mapstop - genestart_dict[merge_dict[scaID][i]] + 1
                   else:
                       if genestop_dict[merge_dict[scaID][i]] <= mapstop:
                           overlap = genestop_dict[merge_dict[scaID][i]] - mapstart + 1
                       else:
                           overlap = mapstop - mapstart + 1
           if genehits_dict.has_key(merge_dict[scaID][i]) == False:
               genehits_dict[merge_dict[scaID][i]] = overlap
           else:
               genehits_dict[merge_dict[scaID][i]] += overlap

for key in sorted(genehits_dict.keys()):
    genelen = genestop_dict[key] - genestart_dict[key] + 1
    cov = genehits_dict[key] * 1.0 / genelen
    result += key + "\t" + str(genelen) + "\t" + str(cov) + "\n"
o.write(result)
