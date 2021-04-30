# Author: Mengkun Du  
# Update: April 30, 2021


## Benjamini and Hochberg (1995)
MLT_BH <- function(pvalue, tau, FDP = FALSE, H1 = NULL){
  m <- length(pvalue)
  pvalue_sort <- sort(pvalue)
  k <- which(pvalue_sort <= tau*(1:m)/m)
  if(length(k) > 0){
    k <- max(k)
    if (FDP){
      V <- sum(pvalue[setdiff(1:m, H1)] <= pvalue_sort[k])
      S <- sum(pvalue[H1] <= pvalue_sort[k])
      return(c(V/(V+S), S/length(H1)))
    } else {
      return(which(pvalue <= pvalue_sort[k]))
    }
  } else {
    if (FDP){
      return(c(0, 0))
    } else {
      return(NULL)
    }
  }
}
