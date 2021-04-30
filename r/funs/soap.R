# Author: Mengkun Du  
# Update: April 30, 2021


## Functions related to the SOAP
gamma_robust <- function(Z, E, k){
  return(apply(Z*E[,k], 2, median))
}

tratio <- function(df){
  return(df/((df - 2)*qt(0.75, df)^2))
}

mat_cor <- function(M, center = TRUE){
  if (center) M <- sweep(M, 2, colMeans(M))
  S <- sqrt(colSums(M^2))
  return((t(M) %*% M)/(S %*% t(S)))
}

## Bickel and Levina (2008)
cv_BL <- function(M, c){
  n  <- nrow(M)
  p  <- ncol(M)
  id <- sample(1:n, floor(n*(1 - 1/log(n))))
  S1 <- mat_cor(M[id,])
  S1 <- S1*(abs(S1) >= c*sqrt(log(p)/n))
  S2 <- mat_cor(M[setdiff(1:n, id),])
  return(mean((S1-S2)^2))
}

CV_BL <- function(M, H, c){
  return(mean(replicate(H, cv_BL(M, c))))
}

## Cai and Liu (2011) and Fan et al. (2013) 
S_POET <- function(samples, ada = FALSE, df = 10, c = 2){
  
  # Principal decomposition
  mat   <- mat_bas(samples)
  Eigen <- eigen(mat$EF %*% t(mat$EF)/mat$n, symmetric = TRUE)
  d     <- which.min(sapply(0:10, FUN = IC_BN, Eigen = Eigen, E = mat$EF)) - 1
  
  if (d > 0){
    
    # Latent factors
    Z <- Eigen$vectors[,1:d]*sqrt(mat$n)
    
    if (d == 1){
      G  <- as.matrix(sapply(1:mat$m, FUN = gamma_robust, E = mat$EF, Z = as.matrix(Z))*tratio(df))
    } else {
      G  <- t(sapply(1:mat$m, FUN = gamma_robust, E = mat$EF, Z = Z))*tratio(df)
    }
    
    E <- mat$EF -  Z %*% t(G)
  } else {
    E <- mat$EF
  }
  
  # Correlation coefficient matrix
  S <- mat_cor(E, center = FALSE)
  
  if (ada){
    c <- seq(1, 3, 0.1)
    c <- c[which.min(sapply(c, FUN = CV_BL, M = E, H = 10))]
  }
  return(S*(abs(S) >= c*sqrt(log(mat$m)/mat$n)))
}

shrink <- function(S, clust = TRUE){
  
  # Measure of correlations
  metric <- colSums(abs(S))
  
  if (clust){
    
    # k-means
    clust <- kmeans(metric, 2)
    return(clust$cluster == which.min(clust$centers))
  } else {
    return(metric <= median(metric))
  }
}
