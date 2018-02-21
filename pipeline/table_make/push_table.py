#python push_table.py all.ko.txt ko_table newi_ko_table

import sys
import pandas as pd

df1 = pd.read_csv(sys.argv[1],sep='\t', index_col=0,header=0)
df2 = pd.read_csv(sys.argv[2],sep='\t', index_col=0,header=0)
tmp = pd.concat([df1,df2],axis=1,join_axes=[df1.index])
newtable = tmp.fillna(0)

newtable.to_csv(sys.argv[3],sep="\t")
