#!/bin/sh
#$ -S /bin/sh
# -l month -l medium -l s_vmem=150G -l mem_req=150G -pe def_slot 4
# -l mem=150G -pe smp 4

dir=$1

echo "running idba_ud"
mkdir ${dir}assembly_result
/home/masuda/software/idba-1.1.1/bin/idba_ud --num_threads 4 --mink 20 --maxk 120 --step 10 -r ${dir}*.paired.fasta -o ${dir}assembly_result/
cp ${dir}assembly_result/scaffold.fa ${dir}
