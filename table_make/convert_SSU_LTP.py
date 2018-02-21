#python convert_SSU_LTP.py species_table LTP.header_03
import sys

LTParray=[]
pre_table = open(sys.argv[1],"r") 
pre_table2 = ""
LTP_header = open(sys.argv[2],"r") 

for line in LTP_header:
    LTParray.append(line.split("\n")[0])

for line in pre_table:
    tax = line.split("\t")[1]
    spe = "Unassigned"
    if tax != "Unassigned":
        aaa = tax.lower().rsplit(";",1)
        for LINE in LTParray:
            if LINE.lower() in aaa[1]:
                spe = aaa[0] + ";" + LINE
                print line.split("\t")[0] + "\t" + spe + "\t" + line.split("\t")[2],
                break

 
