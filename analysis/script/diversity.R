### Library 読み込み
library("ggfortify");library("gridExtra");library("vegan")

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


### サブサンプリング
ReSumpling = function(matrix,metadata){
  int_matrix = apply(apply(matrix,2,function(x){return(x/min(x[x>0]))}),c(1,2),as.integer)
  t_int_matrix = t(int_matrix)
  t_int_matrix_rared = rrarefy(t_int_matrix,min(rowSums(t(int_matrix))))
  return(t_int_matrix_rared)
}



### Shannon Index 計算
culculate_shannon = function(t_int_rared_matrix){
  shannon_index = diversity(t_int_rared_matrix,index="shannon")
  return(shannon_index)
}
  

### Chao1 Index 計算
culculate_chao1 = function(t_int_rared_matrix){
  chao1_index=c()
  for(i in 1:nrow(t_int_rared_matrix)){
    f1 = sum(t_int_rared_matrix[i,]==1)
    f2 = sum(t_int_rared_matrix[i,]==2)
    n = sum(t_int_rared_matrix[i,])
    Sobs = specnumber(t_int_rared_matrix[i,])
    Sest =  Sobs + ((n-1)/n) * (f1*(f1-1)) / ( 2 * (f2+1))
    chao1_index = c(chao1_index,Sest) 
  }
  return(chao1_index)
}


### plot
dot_plot = function(chao1,shannon,metadata,Healthy_sample){
  metadata$Category = paste(metadata$State,metadata$Stage,sep="_")
  df_diversity = data.frame(Chao1_index = chao1,Shannon_diversity = shannon,Category = c(metadata$Category,rep("Healthy",length(Healthy_sample))) )
  df_diversity = transform(df_diversity, Category= factor(Category, levels = c("Healthy","pre_0","post_0","pre_1234","post_1234")))
  p1=ggplot(data=df_diversity, aes(x=Category, y=Chao1_index,fill=Category)) + stat_summary(fun.y=mean, geom="point", shape=18, size=3.5, color="#E69F00") + geom_dotplot(binaxis='y', stackdir='center',stackratio=1.2, dotsize=0.5) + scale_fill_manual(values=c("green","pink","light blue","tomato","royal blue")) + xlab("") + ylab("") + theme(legend.position="none") 
  p2=ggplot(data=df_diversity, aes(x=Category, y=Shannon_diversity,fill=Category)) + stat_summary(fun.y=mean, geom="point", shape=18, size=3.5, color="#E69F00") + geom_dotplot(binaxis='y', stackdir='center',stackratio=1.2, dotsize=0.5) + scale_fill_manual(values=c("green","pink","light blue","tomato","royal blue")) + xlab("") + ylab("") + theme(legend.position="none")
  grid.arrange(p1,p2,ncol = 1, nrow = 2)
}


### main関数
Diversity = function(matrix,metadata){
  metadata = read.table(metadata,header = T,row.names=1,sep='\t',check.names = F)
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  data.frame(Converte_relative(table_row),check.names = F)
  
  Surgery_sample = which(metadata$State != "N") 
  Healthy_sample = c(which(grepl("^(Normal.1|Normal.2)",colnames(table_rel))),which(grepl("^(Few_polyps.1|Few_polyps.2)",colnames(table_rel))))
  matrix_pre_post_healthy_only = table_rel[,c(Surgery_sample,Healthy_sample)]
  
  t_matrix_pre_post_healthy_only_rared = ReSumpling(matrix_pre_post_healthy_only)
  chao1_index = culculate_chao1(t_matrix_pre_post_healthy_only_rared)
  shannon_index = culculate_shannon(t_matrix_pre_post_healthy_only_rared)
  dot_plot(chao1_index,shannon_index,metadata,Healthy_sample)
}

### 実行と保存
pdf(paste(output_dir,"diversity.pdf",sep=""),paper="a4r", width=9.5, height=7)
  Diversity(matrix,metadata)
dev.off()




