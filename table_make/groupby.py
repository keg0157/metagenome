#python groupby.py *fulltaxon
import sys
import pandas as pd
import numpy as np

inp = open(sys.argv[1],"r")
sp_table = pd.read_table(inp,sep='\t',names=[ 'sample','species','cov'])

sp_table_group=sp_table.groupby("species")['cov'].sum()
sp_table_group.to_csv(sys.argv[1] + "_groupby", sep="\t")


#silva_table2 = pd.concat([silva_table,pd.DataFrame(silva_table.sum(axis=0),columns=['Total']).T])
#sp_table2 = pd.concat([sp_table,pd.DataFrame(sp_table.sum(axis=0),columns=['Total']).T])

#silva_table2.to_csv("/Users/masuda/Gdrive/metagenome/analy/table/silva_table_total.tsv", sep="\t")
#sp_table2.to_csv("/Users/masuda/Gdrive/metagenome/analy/table/species_table_total.tsv", sep="\t")
