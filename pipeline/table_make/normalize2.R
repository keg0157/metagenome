args1 = commandArgs(trailingOnly=TRUE)[1]
args2 = commandArgs(trailingOnly=TRUE)[2]

normalize <- function(data){
  data2 = read.table(data,header=T,row.names=1,sep='\t',check.name=F)
  data_rate <- data2
  data_sums <- apply(data2, 2, sum)
  data_rate <- t(apply(data2, 1, function(i){i/data_sums}))
  return(data_rate)
}

table_norm=normalize(args1)
write.table(table_norm , args2 , quote=F, col.names = T , sep='\t')
