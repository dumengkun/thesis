# Author: Mengkun Du  
# Update: April 30, 2021


## Basic matrices
mat_bas <- function(samples){
  m  <- ncol(samples$y)
  n  <- nrow(samples$y)
  Fx <- cbind(1, samples$x)
  
  # Projection matrices
  Qf <- diag(n) - Fx[,-1] %*% solve(t(Fx[,-1]) %*% Fx[,-1]) %*% t(Fx[,-1])
  QF <- diag(n) - Fx %*% solve(t(Fx) %*% Fx) %*% t(Fx)
  cn <- sum(Qf)
  
  # Residuals
  EF <- QF %*% samples$y
  Ef <- Qf %*% samples$y
  
  return(list(m = m, n = n, Qf = Qf, QF = QF, cn = cn, EF = EF, Ef = Ef))
}

## p-values
pvalue <- function(tscore, type = "double_side"){
  if (type == "double_side"){
    return(2*pnorm(-abs(tscore)))
  }
  if (type == "great"){
    return(pnorm(tscore, lower.tail = FALSE))
  }
  if (type == "less"){
    return(pnorm(tscore))
  }
}

## Bai and Ng (2002)
IC_BN <- function(Eigen, E, k){
  n <- dim(E)[1]
  m <- dim(E)[2]
  if (k == 0){
    mse <- mean(E^2)
  } else {
    Z <- Eigen$vectors[,1:k]*sqrt(n)
    G <- t(E) %*% Z/n
    mse <- mean((E -  Z %*% t(G))^2)
  }
  IC <- log(mse) + k*(m+n)/(m*n)*log(m*n/(m+n))
  return(IC)
}

## Oracle procedure
mlt_ora <- function(samples, alpha, sigma){
  mat    <- mat_bas(samples)
  delta  <- sqrt(mat$cn*sigma)
  tscore <- colSums(mat$Qf %*% sweep(samples$e, 2, alpha, FUN = "+"))/delta
  return(tscore)
}

## Original t-test
mlt_ori <- function(samples){
  mat   <- mat_bas(samples)
  delta <- sqrt(mat$cn*colMeans(mat$EF^2))
  return(colSums(mat$Ef)/delta)
}

## AdaFAT and SOAP
mlt_dw <- function(samples, ada = FALSE, robust = FALSE, type = "double_side", tau = 0.2, df = 10){
  
  # Principal decomposition
  mat   <- mat_bas(samples)
  Eigen <- eigen(mat$EF %*% t(mat$EF)/mat$n, symmetric = TRUE)
  d     <- which.min(sapply(0:10, FUN = IC_BN, Eigen = Eigen, E = mat$EF)) - 1
  
  if (d > 0){
    
    # Latent factors
    Z <- Eigen$vectors[,1:d]*sqrt(mat$n)
    
    # SOAP
    if (robust){
      if (d == 1){
        G  <- as.matrix(sapply(1:mat$m, FUN = gamma_robust, E = mat$EF, Z = as.matrix(Z))*tratio(df))
      } else {
        G  <- t(sapply(1:mat$m, FUN = gamma_robust, E = mat$EF, Z = Z))*tratio(df)
      }
    } else {
      G <- t(mat$EF) %*% Z/mat$n
    }
    
    # Idiosyncratic component
    E <- mat$EF -  Z %*% t(G)
    delta  <- sqrt(mat$cn*colMeans(E^2))
    tscore <- colSums(mat$Ef - mat$Ef %*% sweep(G, 2, colMeans(G)) %*% 
                      solve(t(G) %*% sweep(G, 2, colMeans(G))) %*% t(G))/delta
    
    # AdaFAT
    if (ada){
      I <- 1:mat$m
      m <- length(I)
      
      # Estimated set of nulls
      J <- union(MLT_BH(pvalue(mlt_ori(samples), type), tau), MLT_BH(pvalue(tscore, type), tau))
      I <- setdiff(I, J)
      
      while (m > length(I) & length(I) > 100){
        m  <- length(I)
        GI <- as.matrix(G[I,])
        tscore <- colSums(mat$Ef - mat$Ef[,I] %*% sweep(GI, 2, colMeans(GI)) %*% 
                          solve(t(G[I,]) %*% sweep(GI, 2, colMeans(GI))) %*% t(G))/delta
        J <- MLT_BH(pvalue(tscore, type), tau)
        I <- setdiff(I, J)
      }
      
      GI <- as.matrix(G[I,])
      tscore <- colSums(mat$Ef - mat$Ef[,I] %*% sweep(GI, 2, colMeans(GI)) %*% 
                        solve(t(G[I,]) %*% sweep(GI, 2, colMeans(GI))) %*% t(G))/delta
    }
    
    return(tscore)
  } else {
    return(mlt_ori(samples))
  }
}
