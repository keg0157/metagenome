#!/bin/sh
#$ -S /bin/sh
ROOT=~/Desktop/

### fig.3 (phylum組成)
R --vanilla --slave --args ${ROOT}input/metaphlan2_phylum_table_2017_11_30 ${ROOT}input/metadata.tsv 0.005 ${ROOT}/output/phylum_composition/ < ${ROOT}script/Taxonomy_composition.R

### fig.4 (主成分分析)
R --vanilla --slave --args ${ROOT}input/metaphlan2_genus_table_2017_11_30_plus ${ROOT}input/metadata.tsv ${ROOT}/output/PCA/ < ${ROOT}script/PCA_biplot.R

### fig.5 (主成分分析 前後比較)
R --vanilla --slave --args ${ROOT}input/metaphlan2_genus_table_2017_11_30_plus ${ROOT}input/metadata.tsv ${ROOT}/output/PCA/ < ${ROOT}script/PCA_with_line.R

### fig.6 (多様性)
R --vanilla --slave --args ${ROOT}input/metaphlan2_genus_table_2017_11_30_plus ${ROOT}input/metadata.tsv ${ROOT}/output/diversity/ < ${ROOT}script/diversity.R

### fig.7 (Volcano plot species)
R --vanilla --slave --args ${ROOT}input/metaphlan2_species_table_2017_11_30_plus ${ROOT}input/metadata.tsv ${ROOT}/output/volcano/ "1234"  "zellar" "Count"  < ${ROOT}script/volcano_plot.R

### fig.8 (box plot species)
Feature_list=("Fusobacterium_nucleatum" "Peptostreptococcus_stomatis" "Clostridium_symbiosum" "Streptococcus_salivarius")                                                                           for Feature in ${Feature_list[@]}
do
R --vanilla --slave --args ${ROOT}input/metaphlan2_species_table_2017_11_30_plus ${ROOT}input/metadata.tsv ${ROOT}/output/boxplot/ "1234"  ${Feature} "ON"  < ${ROOT}script/ggplot_box_paired.R
done

### fig.9,10 (LefSe)
python ${ROOT}tool/lefse/format_input.py ${ROOT}input/metaphlan2_fulltaxon_table_2017_11_30_for_lefse ${ROOT}tool/lefse/tmp/fulltaxon.in -c 2 -u 1 -o 1000000
python ${ROOT}tool/lefse/run_lefse.py ${ROOT}tool/lefse/tmp/fulltaxon.in ${ROOT}tool/lefse/results/fulltaxon.res
python ${ROOT}tool/lefse/plot_cladogram.py ${ROOT}tool/lefse/results/fulltaxon.res ${ROOT}output/lefse/fulltaxon_cladogram.pdf --format pdf

### species
python ${ROOT}tool/lefse/format_input.py ${ROOT}input/metaphlan2_species_table_2017_11_30_for_lefse ${ROOT}tool/lefse/tmp/species.in -c 2 -u 1 -o 1000000
python ${ROOT}tool/lefse/run_lefse2.py ${ROOT}tool/lefse/tmp/species.in ${ROOT}tool/lefse/results/species.res
python ${ROOT}tool/lefse/plot_res.py ${ROOT}tool/lefse/results/species.res ${ROOT}output/lefse/species.pdf --format pdf

### fig.11 (Volcano plot module)
R --vanilla --slave --args ${ROOT}input/module_table_2017_09_14_plus ${ROOT}input/metadata.tsv ${ROOT}/output/volcano/ "1234"   < ${ROOT}script/volcano_xyplot.R

### fig.12 (Heatmap)
R --vanilla --slave --args ${ROOT}input/module_table_2017_09_14_plus ${ROOT}input/metadata.tsv ${ROOT}/output/Heatmap/ "1234"  < ${ROOT}script/visualize_heatmap.R

### fig.13 (box plot module)
Feature_list=("md:M00134" "md:M00250" "md:M00124" "md:M00118")
for Feature in ${Feature_list[@]}
do
R --vanilla --slave --args ${ROOT}input/module_table_2017_09_14_plus ${ROOT}input/metadata.tsv ${ROOT}/output/boxplot/ "1234"  ${Feature} "ON"  < ${ROOT}script/ggplot_box_paired.R
done

