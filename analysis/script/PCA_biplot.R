### Library 読み込み
library(ggfortify)

### 引数 読み込み
matrix = commandArgs(trailingOnly=TRUE)[1]
metadata = commandArgs(trailingOnly=TRUE)[2]
output_dir = commandArgs(trailingOnly=TRUE)[3]

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

### PCA biplot
PCA_biplot = function(matrix,metadata){
  metadata = read.table(metadata,header = T,row.names=1,sep='\t',check.names = F)
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  data.frame(Converte_relative(table_row),check.names = F)
  
  pre_post = c(which(metadata$Stage == "0"),which(metadata$Stage == "1234"))
  tdata = t(table_rel[,pre_post])
  pca_res = prcomp(tdata)
  metadata$Category = paste(metadata$State,metadata$Stage,sep="_")
  metadata = transform(metadata, Category = factor(Category,  levels = c("pre_0","post_0","pre_1234","post_1234") ))
  
  autoplot(pca_res,x=1,y=2, size=3, data = metadata[pre_post,] ,colour = "Category",loadings = T,loadings.label = T,loadings.label.size=4,loadings.label.colour="black",loadings.colour="black")  + scale_colour_manual(values = c(pre_0 = "pink",post_0 = "light blue",pre_1234 = "red",post_1234 = "blue"))
}

### 実行と保存
pdf(paste(output_dir,"PCA_biplot.pdf",sep=""),paper="a4r", width=9.5, height=7)
  PCA_biplot(matrix,metadata)
dev.off()


