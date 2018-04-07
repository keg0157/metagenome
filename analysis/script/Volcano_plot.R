### Library 読み込み
library("matrixStats")

### 引数 読み込み
matrix = commandArgs(trailingOnly=TRUE)[1]
metadata = commandArgs(trailingOnly=TRUE)[2]
output_dir = commandArgs(trailingOnly=TRUE)[3]
Stage = commandArgs(trailingOnly=TRUE)[4]
Method = commandArgs(trailingOnly=TRUE)[5] ### zellar,None
x_axis = commandArgs(trailingOnly=TRUE)[6] ### Count or FC
Highlight = commandArgs(trailingOnly=TRUE)[7] ### 色付けの有無

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

### FC 計算
Culculate_FC = function(matrix){
  FC_list = log2(matrix[,post] / matrix[,pre])
  median_FC_list = rowMedians(FC_list)
  return(median_FC_list)
}


### plot
Plot = function(matrix,Method,x_axis,Highlight,Up_or_down_count_list,median_FC_list,Pval_list,AbundanceSize_list){
  plot_col=c()
  if(Method == "zellar"){
    zellar_up = c("Fusobacterium_nucleatum","Peptostreptococcus_stomatis","Porphyromonas_asaccharolytica","Clostridium_symbiosum","Clostridium_hylemonae")
    zellar_down = c("Streptococcus_salivarius","Phascolarctobacterium_succinatutens","Butyrivibrio_crossotus","Dorea_formicigenerans","Methanosphaera_stadtmanae")
    ## 色の指定
    for(i in 1:nrow(matrix)){
      if(is.element(rownames(matrix)[i],c(zellar_up,zellar_down)) == T){
        ifelse(is.element(rownames(matrix)[i],zellar_up) == T, plot_col <- c(plot_col,2),plot_col <- c(plot_col,4))
      }
      else{
        plot_col = c(plot_col,1)
      }
    }
    ## x軸,y軸の指定
    if(x_axis=="Count"){
      X = Up_or_down_count_list
      Xlim = c( -1 * (as.integer(max(Up_or_down_count_list)) +1 ) , as.integer(max(Up_or_down_count_list)) +1 )
    }else{
      X = median_FC_list
      Xlim = c(min(median_FC_list[is.na(median_FC_list) == F]),max(median_FC_list[is.na(median_FC_list) == F]))
    } 
    Ylim = c( 0 , as.integer(max(-log10(Pval_list))) +1 )
    
    plot(X,-log10(Pval_list),pch=16,col=plot_col,xlim=Xlim,ylim=Ylim,xlab="",ylab="",cex=c(AbundanceSize_list))
    par(xpd=TRUE)
    legend("topleft",legend=c("1e-2 ~ 1e-0","1e-4 ~ 1e-2","1e-8 ~ 1e-4"),col=1,pch=16,pt.cex=c(1.75,1.0,0.6),cex=1.2)
    
    ## 数字をふる
    for(i in 1:nrow(matrix)){
      if(is.element(rownames(matrix)[i],zellar_up)==T){
        for(n in 1:length(zellar_up)){
          if(rownames(matrix)[i] == zellar_up[n]){
            text(Up_or_down_count_list[i],-log10(Pval_list)[i],pos=3,labels=n,cex=1.4,col=2)
          }
        }
      }
      else if(is.element(rownames(matrix)[i],zellar_down)==T){
        for(N in 1:length(zellar_down)){
          if(rownames(matrix)[i] == zellar_down[N]){
            text(Up_or_down_count_list[i],-log10(Pval_list)[i],pos=3,labels=N+5,cex=1.4,col=4)
          }
        }
      }
    }
  }else{
    ## 色の指定
    for(i in 1:nrow(matrix)){
      if(is.na(Highlight) == T){
        plot_col = 1
      }else{
        ifelse(is.element(rownames(matrix)[i],Highlight),plot_col <- c(plot_col,2),plot_col <- c(plot_col,1))
      }
    }
    ## x軸の指定
    if(x_axis=="Count"){
      X = Up_or_down_count_list
      Xlim = c( -1 * (as.integer(max(Up_or_down_count_list)) +1 ) , as.integer(max(Up_or_down_count_list)) +1 )
    }else{
      X = median_FC_list
      Xlim = c(min(median_FC_list[is.na(median_FC_list) == F]),max(median_FC_list[is.na(median_FC_list) == F]))
    } 
    Ylim = c( 0 , as.integer(max(-log10(Pval_list))) +1 )
    
    plot(X,-log10(Pval_list),pch=16,col=plot_col,xlim=Xlim,ylim=Ylim,xlab="",ylab="",cex=c(AbundanceSize_list))
    par(xpd=TRUE)
    legend("topleft",legend=c("1e-2 ~ 1e-0","1e-4 ~ 1e-2","1e-8 ~ 1e-4"),col=1,pch=16,pt.cex=c(1.75,1.0,0.6),cex=1.2)
    ## 名前をふる
    for(i in 1:nrow(matrix)){
      if(plot_col[i] == 2){
        text(X[i],-log10(Pval_list)[i],labels=rownames(matrix)[i],pos=4,cex=0.6,col=2)
      }
    }
  }
}  

VOLCANO_PLOT <- function(matrix,metadata,Method,x_axis,Highlight){
  table_row = read.table(matrix,header = T,row.names=1,sep='\t',check.names = F)
  table_rel =  Converte_relative(table_row)
  table_rel_time_series = table_rel[,which(metadata$State != "N") ]
  
  Up_or_down_count_list = Up_or_down_count(table_rel_time_series)
  AbundanceSize_list = culculate_AbundanceSize(table_rel_time_series)
  Pval_list = Culculate_pval(table_rel_time_series)
  median_FC_list = Culculate_FC(table_rel_time_series)
  Plot(table_rel_time_series,Method,x_axis,Highlight,Up_or_down_count_list,median_FC_list,Pval_list,AbundanceSize_list)
}

### 実行と保存
pdf(paste(output_dir,"Volcano_sp.pdf",sep=""),paper="a4r", width=9.5, height=7)
  VOLCANO_PLOT(matrix,metadata,Method,x_axis,Highlight)
dev.off()

