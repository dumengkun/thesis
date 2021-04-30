# Author: Mengkun Du  
# Update: April 30, 2021


## Standardized t distribution
get_rand <- function(n, df = 3){
  return(rt(n, df)/sqrt(df/(df-2)))
}

## Simulate samples
sampling <- function(n, m, para, H1, df = 3){
  ## Number of common factors
  p <- length(para$x_mu)
  q <- ncol(para$gamma)
  
  ## Sampling
  Random <- get_rand((m+p+q)*n, df)
  
  ## Common factors
  id  <- 0
  len <- n*p
  x   <- rep(1,n) %*% t(para$x_mu) + matrix(Random[(id+1):(id+len)], n, p) %*% para$x_sd
  
  ## Latent factors
  id  <- id + len
  len <- n*q
  z   <- matrix(Random[(id+1):(id+len)], n, q)
  
  ## Idiosyncratic component
  id  <- id + len
  len <- m*n
  e   <- matrix(Random[(id+1):(id+len)], n, m) %*% para$sigma
  
  ## Responses (Intercepts under true nulls are set to zero)
  y   <- rep(1,n) %*% t(para$alpha*(1:m %in% H1)) + x %*% t(para$beta) + z %*% t(para$gamma) + e
  
  return(list(x = x, y = y, e = e))
}
