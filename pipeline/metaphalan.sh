#!/bin/sh
#$ -S /bin/sh

dir=$1

f1=`echo ${dir}*R1*paired`
f2=`echo ${dir}*R2*paired`

sample=`basename ${dir}`
export PATH="$PATH:/home/masuda/software/bowtie2-2.2.9/"

# qsubで投げる
/home/masuda/software/metaphlan2/metaphlan2.py ${f1},${f2} --bowtie2out ${dir}${sample}_bowtie2.bz2 --nproc 5 --stat_q 0 --input_type fastq > ${dir}${sample}_metaphlan2.tsv

# サンプルごとに集計
#python /home/masuda/script/aggregated_by_sample.py list/zengo_list `pwd`

# genus,speciesのテーブル作成
#grep -E "(s__)|(^ID)" metaphlan2_merged_2017_11_30 | grep -v "t__" | sed 's/^.*s__//g' > metaphlan2_species_table_2017_11_30
#grep -E "(g__)|(^ID)" metaphlan2_merged_2017_11_30 | grep -v "s__" | sed 's/^.*g__//g' > metaphlan2_genus_table_2017_11_30
#grep -E "(p__)|(^ID)" metaphlan2_merged_2017_11_30 | grep -v "c__" | sed 's/^.*p__//g' > metaphlan2_phylum_table_2017_11_30

#stage変換
#python /home/masuda/script/id_stage.py metaphlan2_species_table_2017_11_30 /home/masuda/DB/160705_library.list.txt
#python /home/masuda/script/id_stage.py metaphlan2_genus_table_2017_11_30 /home/masuda/DB/160705_library.list.txt

#sed -i "1i`head -n 1 metaphlan2_merged_2017_11_30`" metaphlan2_genus_table_2017_11_30
#sed -i "1i`head -n 1 metaphlan2_merged_2017_11_30`" metaphlan2_species_table_2017_11_30
