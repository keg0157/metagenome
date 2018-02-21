#!/bin/sh
#$ -S /bin/sh

dir=$1

echo "-------mapping fasta to scaffold-------"
fasta=`ls ${dir} -1 | grep ".md.fasta.paired.fasta"|egrep -v "IDchange"`
mkdir ${dir}INDEX_scaffold/  # indexの作成＆マッピング scaffoldに使ったfasta => scaffold_bowtied.sam
/home/masuda/software/bowtie2-2.2.9/bowtie2-build -f ${dir}scaffold.fa ${dir}INDEX_scaffold/INDEX_scaffold
/home/masuda/software/bowtie2-2.2.9/bowtie2 --no-hd --no-sq --no-unal -x ${dir}INDEX_scaffold/INDEX_scaffold -f -U ${dir}${fasta} -S ${dir}scaffold_bowtied.sam

echo "-------culculating coverage-------" # =>scaffold_bowtied.sam.genehits
python /home/masuda/script/GeneRedundancy.py ${dir}scaffold_bowtied.sam ${dir}*.gff

echo "-------selecting Tophits-------" # *.res => *.res.parsed
perl /home/masuda/script/Parse_TopScore ${dir}*.res

echo "-------finltering Identity>40%,Score>70,cov>80-------" # *.res.parsed => *.res.parsed.id40.sc70.cov80
python /home/masuda/script/id40_sc70_cov80.py ${dir}*.res.parsed ${dir}*.gff.aa.fasta.over50 /home/masuda/DB/taxonomy.strain_to_eukary_or_prokary 

echo "-------making table-------" # 引値 => BLASTの結果,GeneRedundancyの結果,遺伝子名とKO番号の対応表, KO番号とPathway,moduleの対応表
python /home/masuda/script/ko_pathway_module_abundance.py ${dir}*.res.parsed.id40.sc70.cov80 ${dir}scaffold_bowtied.sam.genehits /home/masuda/DB/genes_ko.list /home/masuda/DB/pathway_ko_list /home/masuda/DB/module_ko_list


####その後####

#テーブル作成
#python /home/masuda/script/make_ko_module_pathway_table.py samplename_ID `pwd`
#python /home/masuda/script/make_koComposition_table.py samplename_ID `pwd`

#ステージの変換
#python /home/masuda/script/id_stage.py species_table_LTP_2017_02_14 /home/masuda/DB/160705_library.list.txt
#python /home/masuda/script/id_stage.py species_table_LTP_2017_02_14 /home/masuda/DB/160705_library.list.txt
#python /home/masuda/script/id_stage.py species_table_LTP_2017_02_14 /home/masuda/DB/160705_library.list.txt

#normalize
#R --vanilla --slave --args /home/masuda/zengo/ko_table {dir}ko_table_norm < /home/masuda/script/normalize2.R
#R --vanilla --slave --args /home/masuda/zengo/modu_table {dir}modu_table_norm < /home/masuda/script/normalize2.R
#R --vanilla --slave --args /home/masuda/zengo/path_table {dir}path_table_norm < /home/masuda/script/normalize2.R
