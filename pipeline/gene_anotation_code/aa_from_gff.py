#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
gff_file=sys.argv[1]
sampleID=sys.argv[2]

def file_generator(filename):
    f=open(filename,'r')
    for line in f:
        yield line
    f.close()

def ID_formalize(proteinID):
    ID=str(proteinID)
    number_of_zero_add=8-len(ID)
    item=ID
    for i in range(number_of_zero_add):
        item='0'+item
    return item

def protein_ID_set(sampleID,contig,proteinID):
    item=sampleID+'_'+contig+'_'+ID_formalize(proteinID)
    return item

flag=False
proteinID=1
os.system("cat /dev/null > %s.aa.fasta"%(gff_file))
g=open('%s.aa.fasta'%(gff_file),'r+')
for line in file_generator(gff_file):
    if line[0]!='#' and line!='\n':
		# 本当にcontigの場合は,上が正しい
        #contig=line.split(' ')[0]
		contig=line.split('\t')[0]
    if line[:9]=='##Protein':
        flag=True
        g.write('>'+protein_ID_set(sampleID,contig,proteinID)+'\n')
    if line.rstrip()=='##end-Protein':
        flag=False
        proteinID+=1
    if flag and '##Protein' not in line:
        g.write(line[2:])
g.close()
        
    
