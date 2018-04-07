### Library 読み込み
library(RColorBrewer);library("matrixStats");library(ggplot2)

### 引数 読み込み
matrix = commandArgs(trailingOnly=TRUE)[1]
metadata = commandArgs(trailingOnly=TRUE)[2]
output_dir = commandArgs(trailingOnly=TRUE)[3]
Stage = commandArgs(trailingOnly=TRUE)[4]

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

### 0以外の最小値をreturn
check_min = function(data){
  min = 10000
  for(i in 1:nrow(data)){
    if(min > data[i] && data[i] > 0){
      min = data[i]
    }
  }
  return(min)
}

### P-value 計算
Culculate_pval_unpaired = function(matrix){
  pval_list=c()
  for(i in 1:nrow(matrix)){
    pval = wilcox.test(matrix[i,post],matrix[i,pre])
    pval_list <- c(pval_list,pval$p.value)
  }
  return(pval_list)
}

### マトリクス内の最小値を加えてから FC 計算 
Culculate_FC = function(matrix){
  matrix_plusmin = matrix + check_min(matrix)
  FC_list = log2(matrix_plusmin[,post] / matrix_plusmin[,pre])
  median_FC_list = rowMedians(FC_list)
  return(median_FC_list)
}

### 増減数を算出
Up_or_down_count = function(matrix){
  dif = matrix[,post] - matrix[,pre]
  post_up_count = rowSums(dif > 0) 
  post_down_count = rowSums(dif < 0) 
  count = c()
  for(i in 1:nrow(matrix)){
    ifelse(post_up_count[i] >= post_down_count[i] ,count <- c(count,post_up_count[i]),count <- c(count,-1 * post_down_count[i]))
  }
  return(count)
}


### 特徴量抽出
Feature_selection = function(Up_or_down_count_list,Pval_list){
  threshold = length(pre) * 0.7
  filter1 = abs(Up_or_down_count_list) > threshold
  filter2 = Pval_list < 0.05
  feature = which(filter1 & filter2)
  return(feature)
}

### main関数
heatmap = function(matrix,metadata){
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  Converte_relative(table_row)
  table_rel_time_series = table_rel[,which(metadata$State != "N") ]
  
  Up_or_down_count_list = Up_or_down_count(table_rel_time_series)
  Pval_list = Culculate_pval_unpaired(table_rel_time_series)
  median_FC_list = Culculate_FC(table_rel_time_series)
  
  feature = Feature_selection(Up_or_down_count_list,Pval_list)
  df = data.frame(stage = Stage,FeatureName = rownames(table_rel_time_series)[feature],FC = median_FC_list[feature],count = Up_or_down_count_list[feature])
  df = transform(df, FeatureName = factor(FeatureName, levels = df[order(df$count,decreasing = F),]$FeatureName)) 
  ggplot(df ,aes(x = stage,y=FeatureName)) + geom_tile(aes(fill=FC)) + scale_fill_gradientn(colours = rev(brewer.pal(9, "Spectral")), na.value = "white") + geom_text(aes(label = df $count)) 
}

### 実行と保存
pdf(paste(output_dir,"Heatmap.pdf",sep=""),paper="a4r", width=9.5, height=7)
  heatmap(matrix,metadata)
dev.off()

