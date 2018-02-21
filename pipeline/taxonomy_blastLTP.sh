#!/bin/sh
#$ -S /bin/sh
dir=$1

##### blast #####
echo "-----IDchange-----" #change ID for blast (*.md.fasta.paired.fasta => *.md.fasta.paired.fasta.IDchange)
python /home/masuda/script/IDchange_for_blast.py ${dir}*.md.fasta.paired.fasta

echo "-----blast to vitcomic-----"
/home/masuda/software/blast-2.2.26/bin/blastall -p blastn -i ${dir}*.md.fasta.paired.fasta.IDchange -d /home/masuda/DB/vitcomic/blast/newRefs.fa -o ${dir}vit16s.res.eval8 -F F -m 8 -a 1 -b 10 -v 10 -e 1e-8

echo "-----select Hiquality 16s read-----" # select Hiquality 16s read  (*fasta => *fasta.vit16s)
python /home/masuda/script/select_16Sread.py ${dir}*.md.fasta.paired.fasta.IDchange ${dir}vit16s.res.eval8

<<COMENTOUT
#echo "-----blast to silva ssu-----"
blastall -p blastn -i ${dir}*.vit16s -d /home/masuda/DB/Silva_remEucary/SILVA_123_SSURef_Nr99_tax_silva.fasta.remEucary -o ${dir}vit16s.silva.res -F F -m 8 -a 1 -b 10 -v 10 -e 1e-8

#echo "-----select ssu read-----" # select ssu read  ( *.md.fasta.paired.fasta.IDchange => *.md.fasta.paired.fasta.IDchange.ssu )
python /home/masuda/script/select_ssu_read.py ${dir}*.md.fasta.paired.fasta.IDchange ${dir}vit16s.res.eval8
COMENTOUT

echo "-----blast to LTP-----"
/home/masuda/software/blast-2.2.26/bin/blastall -p blastn -i ${dir}*.md.fasta.paired.fasta.IDchange.vit16s -d /home/masuda/DB/Silva_LTP/LTPs123_SSU.compressed.fasta.forblast -o ${dir}vit16s.LTP.res.eval8 -F F -m 8 -a 1 -b 10 -v 10 -e 1e-8

echo "-----quality filtering and select read-----"
python /home/masuda/script/eval8_id97_sc70_cov80.py ${dir}vit16s.LTP.res.eval8 ${dir}*.fasta.IDchange.vit16s
#wc -l ${dir}*.vit16s > ${dir}count_vit16s_read

echo "-----TopHit-----" #leave TopHit (vit16s.silva_all.res.eval8.id97.sc70.cov80.cul_uncul => vit16s.silva_all.res.eval8.id97.sc70.cov80.cul_uncul.parsed)
perl /home/masuda/script/Parse_TopScore ${dir}vit16s.LTP.res.eval8.id97.sc70.cov80

echo "-----aggregate-----" ##aggregate each sample (=>*hits.silvaID,*hits.species,*hits.genus)
python /home/masuda/script/assign_genus_species_LTP.py ${dir}vit16s.LTP.res.eval8.id97.sc70.cov80.parsed /home/masuda/DB/Silva_LTP/LTPs123_SSU.tsv
#wc -l ${dir}vit16s.LTP.res.eval8.id97.sc70.cov80.parsed > ${dir}count_silvaLTP_read

<<COMENTOUT
テーブル作成
python /home/masuda/script/cat_tax_gns_spe.py sample_list `pwd`

stage変換
python /home/masuda/script/id_stage.py species_table_LTP_2017_02_14 /home/masuda/DB/160705_library.list.txt
python /home/masuda/script/id_stage.py genus_table_LTP_2017_02_14 /home/masuda/DB/160705_library.list.txt

ノーマライズ
R --vanilla --slave --args genus_table_LTP_2017_02_14_stage genus_table_LTP_2017_02_14_stage_norm< /home/masuda/script/normalize2.R
R --vanilla --slave --args species_table_LTP_2017_02_14_stage species_table_LTP_2017_02_14_stage_norm< /home/masuda/script/normalize2.R
COMENTOUT
