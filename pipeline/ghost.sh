#!/bin/sh
#$ -S /bin/sh

dir=$1
sample=`basename $dir`

# 1.長さ50未満の遺伝子は捨てる *.gff.aa.fasta  => *.gff.aa.fasta.over50
echo "running fasta_over50.py"
python /home/masuda/script/fasta_over50.py ${dir}*.gff.aa.fasta

# 2.アノテーション *.gff.aa.fasta.nd.fasta.over50 => ghostx.res
echo "running ghostx"
/home/masuda/software/ghostx-1.3.7/src/ghostx aln -i ${dir}*.gff.aa.fasta.over50 -d /home/masuda/DB/ghostxDB/prokaryotes.pep -o ${dir}ghostx.res
