normalize <- function(data){
  data_rate <- data
  data_sums <- apply(data, 2, sum)
  data_rate <- t(apply(data, 1, function(i){
			  i/data_sums
			  }
		      )
		)
  return(data_rate)
}


