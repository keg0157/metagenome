#!/bin/sh
#$ -S /bin/sh

# 1.N除去
# 2.Phixの除去
# 3.cutadapt
# 4.長さ50bp未満のリードの除去 + クオリティフィルタ
# 5.ヒトゲノムマッピング
# 6.FとRの片方にしかないリードの除去

dir=$1

# 0. 行数チェック
echo "***count fastq***"
#wc -l ${dir}*.fastq

# 1.N除去(N_delete) *.fastq => *.fastq.N
echo "=========rem N========="
python /home/masuda/script/remN.py ${dir}*R1.fastq
python /home/masuda/script/remN.py ${dir}*R2.fastq

# 2.Phix除去(Phix_delete) * => *.rem
echo "=========rem phix========="
/home/masuda/software/bowtie2-2.2.9/bowtie2 --no-hd --no-sq --no-unal --fast-local -x /home/masuda/DB/phiX_bowtie2-2.2.9/phiX174.fasta.index -U ${dir}*R1*.fastq.N -S ${dir}phix.1.sam
/home/masuda/software/bowtie2-2.2.9/bowtie2 --no-hd --no-sq --no-unal --fast-local -x /home/masuda/DB/phiX_bowtie2-2.2.9/phiX174.fasta.index -U ${dir}*R2*.fastq.N -S ${dir}phix.2.sam
python /home/masuda/script/delete_mapped_fastq.py ${dir}*R1*.fastq.N ${dir}phix.1.sam
python /home/masuda/script/delete_mapped_fastq.py ${dir}*R2*.fastq.N ${dir}phix.2.sam

# 1の削除
echo "*******count *1.fastq.N*******"
#wc -l ${dir}*R1*.fastq.N
#rm ${dir}*R1*.fastq.N
echo "*******count *2.fastq.N*******"
#wc -l ${dir}*R2*.fastq.N
#rm ${dir}*R2*.fastq.N

# 3.Cutadapt  * => *.trim
echo "=========adapter cut========="
for i in ${dir}*R1*.fastq.N.rem
do
cutadapt -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -O 33 -o ${i}.trim -q 17 -f fastq $i
done

for i in ${dir}*R2*.fastq.N.rem
do
cutadapt -a CTGTCTCTTATACACATCTGACGCTGCCGACGA -O 32 -o ${i}.trim -q 17 -f fastq $i
done

# 2の削除
echo "*******count *1.fastq.N.rem*******"
#wc -l ${dir}*R1*.fastq.N.rem
#rm ${dir}*R1*.fastq.N.rem
echo "*******count *2.fastq.N.rem*******"
#wc -l ${dir}*R2*.fastq.N.rem
#rm ${dir}*R2*.fastq.N.rem


# 4.length < 50 and AQ < 25 の除去* => *.over50.aqv
echo "=========rem short read , Quality filtering and convert fasta from fastq========="
python /home/masuda/script/over50_QF.py ${dir}*R1*.fastq.N.rem.trim /home/masuda/DB/ascii
python /home/masuda/script/over50_QF.py ${dir}*R2*.fastq.N.rem.trim /home/masuda/DB/ascii

# 3の削除
echo "*******count *1.fastq.N.rem.trim*******"
#wc -l ${dir}*R1*.fastq.N.rem.trim
#rm ${dir}*R1*.fastq.N.rem.trim
echo "*******count *2.fastq.N.rem.trim*******"
#wc -l ${dir}*R2*.fastq.N.rem.trim
#rm ${dir}*R2*.fastq.N.rem.trim

# 5. ヒトゲノムマッピング *.fastq.N.trim.over50.aqv => *.fastq.N.trim.over50.aqv.md
echo "==========delete human genome========="
for i in ${dir}*.over50.aqv
do
/home/masuda/software/bowtie2-2.2.9/bowtie2 --no-hd --no-sq --no-unal --fast-local -x /home/masuda/DB/human_genome_bowtie2-2.2.9/human_genome.fa.index -U $i -S ${dir}bowtied_human_genome.sam
python /home/masuda/script/delete_humangenome.py $i ${dir}bowtied_human_genome.sam
done

# 4の削除
echo "*******count *1.fastq.N.rem.trim.over50.aqv*******"
#wc -l ${dir}*R1*.fastq.N.rem.trim.over50.aqv
#rm ${dir}*R1*.fastq.N.rem.trim.over50.aqv
echo "*******count *2.fastq.N.rem.trim.over50.aqv*******"
#wc -l ${dir}*R2*.fastq.N.rem.trim.over50.aqv
#rm ${dir}*R2*.fastq.N.rem.trim.over50.aqv


# 6. FR 両方あるリードのみ採用 *1.*.md *2.*md => *1.fastq.N.rem.trim.over50.aqv.md.paired
echo "=========delete Unpaired read=========="
python /home/masuda/script/delete_unpairedFR_forfastq.py ${dir}*R1*.fastq.N.rem.trim.over50.aqv.md ${dir}*R2*.fastq.N.rem.trim.over50.aqv.md

# 5の削除
echo "*******count *2.fastq.N.rem.trim.over50.aqv.md*******"
#wc -l ${dir}*R1*.fastq.N.rem.trim.over50.aqv.md
#rm ${dir}*R1*.fastq.N.rem.trim.over50.aqv.md
echo "*******count *2.fastq.N.rem.trim.over50.aqv.md*******"
#wc -l ${dir}*R2*.fastq.N.rem.trim.over50.aqv.md
#rm ${dir}*R2*.fastq.N.rem.trim.over50.aqv.md

# 6の計測
echo "*******count *2.fastq.N.rem.trim.over50.aqv.md.fasta.paired.fasta*******"
#wc -l ${dir}*R1*.fastq.N.rem.trim.over50.aqv.md.paired.fastq
#wc -l ${dir}*R2*.fastq.N.rem.trim.over50.aqv.md.paired.fastq

