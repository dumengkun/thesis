# Author: Mengkun Du  
# Update: April 30, 2021


## Storey (2002)
AP_ST <- function(pval, t, e){
  if (length(pval) == 0){
    return(0)
  } else {
    return(max((mean(pval <= t) - t - e)/(1-t), 0))
  }
} 

## Benjamini et al. (2006)
AP_TST <- function(pval, tau){
  if (length(pval) == 0){
    return(0)
  } else {
    return(length(MLT_BH(pval, tau/(1+tau)))/length(pval))
  }
}

## Farcomeni and Pacillo (2011)
AP_FP <- function(pval, tau){
  e <- sqrt(log(1/tau)/(2*length(pval)))
  return(max(sapply(pval, AP_ST, pval = pval, e = e), 0))
}