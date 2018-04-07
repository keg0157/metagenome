make_StatisticalScore_table = function(matrix){
  ### Abundance 計算
  rmEMPlist = seq(1,nrow(matrix))[rowMeans(matrix[,c(stage0,stage1234)])!=0]
  abundance_size_stage0_list=c();abundance_size_stage1234_list=c();
  for(i in 1:nrow(matrix)){
    if(mean(matrix[i,stage1234]) == 0){
      abundance_size_stage1234=0
    } else if(-log10(mean(matrix[i,stage1234])) >= 4 && -log10(mean(matrix[i,stage1234])) < 7){
      abundance_size_stage1234=0.5
    } else if(-log10(mean(matrix[i,stage1234])) >= 2 && -log10(mean(matrix[i,stage1234])) < 4){
      abundance_size_stage1234=1.0
    } else if(-log10(mean(matrix[i,stage1234])) >= 0 && -log10(mean(matrix[i,stage1234])) < 2){
      abundance_size_stage1234=1.75
    }
    abundance_size_stage1234_list=c(abundance_size_stage1234_list,abundance_size_stage1234)
    
    if(mean(matrix[i,stage0]) == 0){
      abundance_size_stage0=0
    } else if(-log10(mean(matrix[i,stage0])) >= 4 && -log10(mean(matrix[i,stage0])) < 7){
      abundance_size_stage0=0.5
    } else if(-log10(mean(matrix[i,stage0])) >= 2 && -log10(mean(matrix[i,stage0])) < 4){
      abundance_size_stage0=1.0
    } else if(-log10(mean(matrix[i,stage0])) >= 0 && -log10(mean(matrix[i,stage0])) < 2){
      abundance_size_stage0=1.75
    }
    abundance_size_stage0_list=c(abundance_size_stage0_list,abundance_size_stage0)
  }
  
  ### P-value 計算
  pval_1234_list=c();pval_0_list=c();UPorOUT_0_list=c();UPorOUT_1234_list=c();pval_1234_nopaired_list=c();pval_0_nopaired_list=c()
  for(i in 1:nrow(matrix)){
    pval_0_gre = wilcox.test(matrix[i,stage0_after],matrix[i,stage0_before],paired=T,alternative = "greater")
    pval_0_les = wilcox.test(matrix[i,stage0_after],matrix[i,stage0_before],paired=T,alternative = "less")
    pval_1234_gre = wilcox.test(matrix[i,stage1234_after],matrix[i,stage1234_before],paired=T,alternative = "greater")
    pval_1234_les = wilcox.test(matrix[i,stage1234_after],matrix[i,stage1234_before],paired=T,alternative = "less")
    pval_1234_nopaired_list = c(pval_1234_nopaired_list,wilcox.test(matrix[i,stage1234_after],matrix[i,stage1234_before])$p.value)
    pval_0_nopaired_list = c(pval_0_nopaired_list,wilcox.test(matrix[i,stage0_after],matrix[i,stage0_before])$p.value)
    
    if(pval_0_gre$p.value <= pval_0_les$p.value){
      pval_0_list <- c(pval_0_list,pval_0_gre$p.value)
      UPorOUT_0_list <- c(UPorOUT_0_list,"post")
    }
    else{
      pval_0_list <- c(pval_0_list,pval_0_les$p.value)
      UPorOUT_0_list <- c(UPorOUT_0_list,"pre")
    }
    if(pval_1234_gre$p.value <= pval_1234_les$p.value){
      pval_1234_list <-c (pval_1234_list,pval_1234_gre$p.value)
      UPorOUT_1234_list <-c (UPorOUT_1234_list,"post")
    }
    else{
      pval_1234_list <- c(pval_1234_list,pval_1234_les$p.value)
      UPorOUT_1234_list <- c(UPorOUT_1234_list,"pre")
    }
  }
  pval_0_list[is.nan(pval_0_list)] <- 1;pval_1234_list[is.nan(pval_1234_list)] <- 1
  pval_0_nopaired_list[is.nan(pval_0_nopaired_list)] <- 1;pval_1234_nopaired_list[is.nan(pval_1234_nopaired_list)] <- 1
  BH_0_list = BH(pval_0_list[rmEMPlist]);BH_1234_list = BH(pval_1234_list[rmEMPlist])
  
  ### FC 計算
  FC_list = log2(matrix[,after] / matrix[,before])
  #meanFC0_list = rowMeans(FC_list[,1:11]);meanFC1234_list = rowMeans(FC_list[,12:39])
  medianFC0_list = rowMedians(FC_list[,1:11]);medianFC1234_list = rowMedians(FC_list[,12:39])
  
  ### 上昇数、減少数、stay
  dif = matrix[,stage1234_after] - matrix[,stage1234_before]
  post_up_count_1234 = rowSums(dif > 0)
  post_down_count_1234 = rowSums(dif < 0)
  dif = matrix[,stage0_after] - matrix[,stage0_before]
  post_up_count_0 = rowSums(dif > 0)
  post_down_count_0 = rowSums(dif < 0)
  
  ### テーブル作成 
  valtable = data.frame(FeatureName=rownames(matrix)[rmEMPlist],MeanAbundance1234=rowMeans(matrix[,stage1234])[rmEMPlist],p_value1234=pval_1234_list[rmEMPlist],q_value1234=BH_1234_list,Increase_in=UPorOUT_1234_list[rmEMPlist],Up=post_up_count_1234[rmEMPlist],down=post_down_count_1234[rmEMPlist],MedianFC1234=medianFC1234_list[rmEMPlist],VolcanoSize1234=abundance_size_stage1234_list[rmEMPlist],MeanAbundance0=rowMeans(matrix[,stage0])[rmEMPlist],p_value0=pval_0_list[rmEMPlist],q_value0=BH_0_list,Increase_in=UPorOUT_0_list[rmEMPlist],Up=post_up_count_0[rmEMPlist],down=post_down_count_0[rmEMPlist],MedianFC0=medianFC0_list[rmEMPlist],VolcanoSize0=abundance_size_stage0_list[rmEMPlist])
  valtable2 = data.frame(FeatureName=rownames(matrix)[rmEMPlist],MeanAbundance1234=rowMeans(matrix[,stage1234])[rmEMPlist],p_value1234=pval_1234_nopaired_list[rmEMPlist],q_value1234=BH_1234_list,Increase_in=UPorOUT_1234_list[rmEMPlist],Up=post_up_count_1234[rmEMPlist],down=post_down_count_1234[rmEMPlist],MedianFC1234=medianFC1234_list[rmEMPlist],VolcanoSize1234=abundance_size_stage1234_list[rmEMPlist],MeanAbundance0=rowMeans(matrix[,stage0])[rmEMPlist],p_value0=pval_0_list[rmEMPlist],q_value0=BH_0_list,Increase_in=UPorOUT_0_list[rmEMPlist],Up=post_up_count_0[rmEMPlist],down=post_down_count_0[rmEMPlist],MedianFC0=medianFC0_list[rmEMPlist],VolcanoSize0=abundance_size_stage0_list[rmEMPlist])
  return(valtable)
}

