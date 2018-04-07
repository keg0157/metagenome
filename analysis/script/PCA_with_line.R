### PCA
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

### PCA
PCA = function(matrix,metadata){
  metadata = read.table(metadata,header = T,row.names=1,sep='\t',check.names = F)
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  data.frame(Converte_relative(table_row),check.names = F)
  
  pre_post = c(which(metadata$Stage == "0"),which(metadata$Stage == "1234"))
  tdata = t(table_rel[,pre_post])
  pca_res = prcomp(tdata)
  Correspondence = data.frame(seq(1, ncol(table_rel[,pre_post]), +2),seq(2, ncol(table_rel[,pre_post]), +2))
  
  metadata$Category = paste(metadata$State,metadata$Stage,sep="_")
  metadata$Category[which(metadata$Stage == 0)] <-  c("pink","light blue")
  metadata$Category[which(metadata$Stage == 1234)] <-  c("tomato","royal blue")
  
  plot(pca_res$x,col=metadata[pre_post,]$Category,pch=19)
  legend("bottomleft",legend = c("pre-stage0","post-stage0","pre-stage1234","post-stage1234"),col=unique(metadata[pre_post,]$Category),pch=19,cex=1.0)
  
  for(i in 1:nrow(tdata)){
    ifelse( metadata[pre_post,]$Stage[seq(1,78,2)][i] == "1234",col_list <- "black", col_list <- "gray" )
    lines(c(pca_res$x[Correspondence[i,1],1],pca_res$x[Correspondence[i,2],1]),c(pca_res$x[Correspondence[i,1],2],pca_res$x[Correspondence[i,2],2]),col=col_list,lwd = 2.5)}
}

### 実行と保存
pdf(paste(output_dir,"PCA.pdf",sep=""),paper="a4r", width=9.5, height=7)
  PCA(matrix,metadata)
dev.off()

