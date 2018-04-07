### Library 読み込み
library(reshape2);library(ggplot2)

### 引数 読み込み
matrix = commandArgs(trailingOnly=TRUE)[1]
metadata = commandArgs(trailingOnly=TRUE)[2]
Threshold = as.numeric(commandArgs(trailingOnly=TRUE)[3])
output_dir = commandArgs(trailingOnly=TRUE)[4]

### 相対値に変換してX以下をOthersとして集計
Abundance_filter <- function(data,Threshold){
  data_sums = apply(data, 2, sum)
  data_rel = t(apply(data, 1, function(i){
    i/data_sums
  }))
  rowsum = apply(data_rel,1,sum)
  data_rel = cbind(data_rel,rowsum)
  data_rel = data_rel[sort.list(data_rel[,"rowsum"],decreasing = TRUE),]
  X = Threshold
  num = sum(rowMeans(data_rel) > X )
  others = apply(data_rel[seq(num + 1,nrow(data_rel)),],2,sum)
  data_rel = rbind(data_rel,others)
  data_rel = data_rel[,-ncol(data_rel)]
  data_rel = data_rel[-((num+1):(nrow(data_rel)-1)),]
  return(data_rel)
}

### meltする
make_melt_table = function(matrix,metadata){
  matrix_melt = melt(t(matrix))
  matrix_melt$State = rep(as.character(metadata$State),nrow(matrix))
  matrix_melt$Stage = rep(metadata$Stage,nrow(matrix))
  matrix_melt$Category = paste(metadata$State,metadata$Stage,sep="_")
  matrix_melt <- transform(matrix_melt, Category= factor(Category, levels = c("pre_0","post_0","pre_1234","post_1234")))
  return(matrix_melt)
}

### boxplot
gg_box <- function(melt_table,metadata,log_switch){
  g <- ggplot(melt_table,aes (x = Var2, y = value, fill = Category, dodge = Category))
  ifelse(log_switch == "ON", g <- g + scale_y_log10() , g <- g )
  g <- g + geom_boxplot(outlier.colour = "black",outlier.size = 0.5)
  g <- g + scale_fill_manual(values = c(pre_0 = "pink",post_0 = "light blue",pre_1234 = "tomato",post_1234 = "royal blue"))
  g <- g + theme(axis.text.x = element_text(size = 6,face = "italic"),plot.title = element_text(hjust = 0.5))
  plot(g)
}

### main関数
Taxonomy_composition = function(matrix,metadata,Threshold){
  metadata = read.table(metadata,header = T,row.names=1,sep='\t',check.names = F)
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  data.frame(Abundance_filter(table_row,Threshold),check.names = F)
  melt_table_rel = make_melt_table(table_rel,metadata)
  gg_box(melt_table_rel,metadata,"OFF")
    ggsave(paste(output_dir,"composition.pdf",sep=""),paper="a4r", width=9.5, height=7)
  gg_box(melt_table_rel,metadata,"ON")
    ggsave(paste(output_dir,"composition_log.pdf",sep=""),paper="a4r", width=9.5, height=7)
}

### 実行
Taxonomy_composition(matrix,metadata,Threshold)


