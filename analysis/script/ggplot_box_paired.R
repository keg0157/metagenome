### Library 読み込み
library(reshape2);library(ggplot2)

### 引数 読み込み
matrix = commandArgs(trailingOnly=TRUE)[1]
metadata = commandArgs(trailingOnly=TRUE)[2]
output_dir = commandArgs(trailingOnly=TRUE)[3]
Stage = commandArgs(trailingOnly=TRUE)[4]
Feature = commandArgs(trailingOnly=TRUE)[5]
log_switch = commandArgs(trailingOnly=TRUE)[6]

### 引数の処理
metadata = read.table(metadata,header = T,row.names=1,sep='\t',check.names = F)
if(Stage=="0"){
  pre = which(metadata$Stage == 0 & metadata$State == "pre" )
  post = which(metadata$Stage == 0 & metadata$State == "post" )
  pre_post = which(metadata$Stage == 0)
}else if(Stage=="1234"){
  pre = which(metadata$Stage == 1234 & metadata$State == "pre" )
  post = which(metadata$Stage == 1234 & metadata$State == "post" )
  pre_post = which(metadata$Stage == 1234)
}

### 相対値に変換して降順に
Converte_relative <- function(data){
  data_sums = apply(data, 2, sum)
  data_rel = t(apply(data, 1, function(i){
    i/data_sums
  }))
  rowsum = apply(data_rel,1,sum)
  data_rel = cbind(data_rel,rowsum)
  data_rel = data_rel[sort.list(data_rel[,"rowsum"],decreasing = TRUE),]
  data_rel = data_rel[,-ncol(data_rel)]
  return(data_rel)
}

### melt
make_melt_table = function(matrix,metadata){
  matrix_melt = melt(t(matrix))
  matrix_melt$State = rep(as.character(metadata$State),nrow(matrix))
  matrix_melt$Stage = rep(metadata$Stage,nrow(matrix))
  matrix_melt$Category = paste(metadata$State,metadata$Stage,sep="_")
  matrix_melt$Sample = substr(matrix_melt$Var1,1,5)
  matrix_melt <- transform(matrix_melt, Category= factor(Category, levels = c("pre_0","post_0","pre_1234","post_1234")))
  matrix_melt = transform(matrix_melt, State = factor(State,  levels = c("pre","post")))
  return(matrix_melt)
}

### あるFeatureが何行目にあるか出力
return_number <- function(name_list,dataset){
  num_check=c();
  for (name in name_list){
    for (i in 1:nrow(dataset)){
      if(rev(strsplit(rownames(dataset)[i],";")[[1]])[1] == name){
        num_check=c(num_check,i)
        break
      }
    }
  }
  return(num_check)
}

### plot
Plot <- function(matrix,melt_table,metadata,stage,Feature,log_switch){
  # 色の指定
  dif = matrix[,post] - matrix[,pre]
  dif[dif>=0] <- "1";dif[dif<0] <- "2"
  col = rep(dif[return_number(Feature,matrix),], each=2)
  
  ## gg_plot
  g <- ggplot(subset(melt_table,Var2 %in% Feature & Stage == stage ),aes(x = State , y = value,fill = State)) 
  g <- g + geom_boxplot(outlier.colour = "black",outlier.size = 0.5) + scale_fill_manual(values = c(pre = "tomato",post = "royal blue")) 
  g <- g + geom_line(aes(group = Sample,color = col))  
  g <- g + geom_point() + theme(legend.position = "none") 
  g <- g + ggtitle(Feature)
  ifelse(log_switch == "ON", g <- g + scale_y_log10() , g <- g )
  plot(g)
}

### main関数
ggplot_box_paired = function(matrix,metadata,Stage,Feature,log_switch){
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  Converte_relative(table_row)
  table_rel_time_series = table_rel[,which(metadata$State != "N") ]
  melt_table_rel_time_series =  make_melt_table(table_rel_time_series,metadata)
  Plot(table_rel_time_series,melt_table_rel_time_series,metadata,Stage,Feature,log_switch)
}

### 実行と保存
pdf(paste(output_dir,Feature,".pdf",sep=""),paper="a4r", width=9.5, height=7)
  ggplot_box_paired(matrix,metadata,Stage,Feature,log_switch)
dev.off()
