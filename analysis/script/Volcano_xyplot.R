### Library 読み込み
library("matrixStats")

### zellar module 読み込み
zellar_module =  c("md:M00080","md:M00063","md:M00060","md:M00320","md:M00064","md:M00045","md:M00134","md:M00208","md:M00209","md:M00325","md:M00326","md:M00358","md:M00331","md:M00311","md:M00174","md:M00530","md:M00267","md:M00273","md:M00250","md:M00228","md:M00199","md:M00251","md:M00185","md:M00478")  ## 色の指定
zellar_module2 =  zellar_module[-15]
 
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
  Xlim = c(-10,10)
  Ylim = c(-2.8,2.8)
}else if(Stage=="1234"){
  pre = which(metadata$Stage == 1234 & metadata$State == "pre" )
  post = which(metadata$Stage == 1234 & metadata$State == "post" )
  pre_post = which(metadata$Stage == 1234)
  Xlim = c(-24,24)
  Ylim = c(-4.5,4.5)
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

### あるFeatureが何行目にあるか出力する
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

### Abundance 計算
culculate_AbundanceSize = function(matrix){
  abundance_size_list=c()
  for(i in 1:nrow(matrix)){
    if(mean(matrix[i,pre_post]) == 0){
      abundance_size = 0
    } else if(-log10(mean(matrix[i,pre_post])) >= 4 && -log10(mean(matrix[i,pre_post])) < 7){
      abundance_size = 0.5
    } else if(-log10(mean(matrix[i,pre_post])) >= 2 && -log10(mean(matrix[i,pre_post])) < 4){
      abundance_size = 1.0
    } else if(-log10(mean(matrix[i,pre_post])) >= 0 && -log10(mean(matrix[i,pre_post])) < 2){
      abundance_size = 1.75
    }
    abundance_size_list=c(abundance_size_list,abundance_size)
  }
  return(abundance_size_list)
} 

### P-value 計算
Culculate_pval = function(matrix){
  pval_list=c()
  for(i in 1:nrow(matrix)){
    pval_gre = wilcox.test(matrix[i,post],matrix[i,pre],paired=T,alternative = "greater")
    pval_les = wilcox.test(matrix[i,post],matrix[i,pre],paired=T,alternative = "less")
    ifelse(pval_gre$p.value <= pval_les$p.value, pval_list <- c(pval_list,pval_gre$p.value),pval_list <- c(pval_list,pval_les$p.value))
  }
  return(pval_list)
}

### plot 前処理
Preprocessing = function(matrix,Pval_list,AbundanceSize_list){
  ## zellar moduleの抽出
  
  matrix_zellar_only = matrix[return_number(zellar_module2,matrix),]
  
  ## X値計算
  dif = matrix_zellar_only[,post] - matrix_zellar_only[,pre]
  post_up_count = rowSums(dif > 0)
  post_down_count = rowSums(dif < 0)
  up_down_count = c()
  for(i in 1:nrow(matrix_zellar_only)){
    ifelse(post_up_count[i] >= post_down_count[i] ,up_down_count <- c(up_down_count,post_up_count[i]),up_down_count <- c(up_down_count,-1 * post_down_count[i]))
  }
  X = up_down_count
  ## Y値計算
  enrich_deplet_sign = c(rep(1,15),rep(-1,8))
  Y = -log10(Pval_list[return_number(zellar_module2,matrix)]) * enrich_deplet_sign
  ## abundanceの大きさ指定
  plot_size = AbundanceSize_list[return_number(zellar_module,matrix)]
  
  return(data.frame(X,Y,plot_size,plot_color = c(rep(2,15),rep(4,8)))) 
}

### plot
Plot = function(matrix,Pval_list,AbundanceSize_list){
  df_res = Preprocessing(matrix,Pval_list,AbundanceSize_list)
  plot(df_res$X,df_res$Y,col = df_res$plot_color,pch=16,cex=df_res$plot_size,xlim=Xlim,ylim=Ylim)
  par(xpd=TRUE)
  legend("topleft",legend=c("1e-2 ~ 1e-0","1e-4 ~ 1e-2","1e-8 ~ 1e-4"),col=1,pch=16,pt.cex=c(1.75,1.0,0.6),cex = 1.2)
  
  ## 番号追記
  matrix_zellar_only = matrix[return_number(zellar_module2,matrix),]
  for(i in 1:nrow(matrix_zellar_only)){
    if(is.element(rownames(matrix_zellar_only)[i],zellar_module[1:16])==T){
      for(n in 1:length(zellar_module[1:16])){
        if(rownames(matrix_zellar_only)[i] == zellar_module[1:16][n]){
          text(df_res$X[i],df_res$Y[i],pos=3,labels=n,cex=1.1,col=6)
        }
      }
    }
    else if(is.element(rownames(matrix_zellar_only)[i],zellar_module[17:24])==T){
      for(N in 1:length(zellar_module[17:24])){
        if(rownames(matrix_zellar_only)[i] == zellar_module[17:24][N]){
          text(df_res$X[i],df_res$Y[i],pos=3,labels=N+16,cex=1.1,col=5)
        }
      }
    }
  }
}  
  
  
VOLCANO_MODULE_PLOT <- function(matrix,metadata){
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  Converte_relative(table_row)
  table_rel_time_series = table_rel[,which(metadata$State != "N") ]
  
  AbundanceSize_list = culculate_AbundanceSize(table_rel_time_series)
  Pval_list = Culculate_pval(table_rel_time_series)
  Plot(table_rel_time_series,Pval_list,AbundanceSize_list)
}

### 実行と保存
pdf(paste(output_dir,"Volcano_module.pdf",sep=""),paper="a4r", width=9.5, height=7)
  VOLCANO_MODULE_PLOT(matrix,metadata)
dev.off()



