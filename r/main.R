# Title:  Simulations of AdaFAT and SOAP
# Author: Mengkun Du  
# Update: April 30, 2021


## Functions
source("funs/bh.R")
source("funs/fat.R")
source("funs/prop.R")
source("funs/samp.R")
source("funs/soap.R")

## Model parameters calibrated by Chinese A-share market (Jan.2014 - Dec.2018)
load("para/para1634.RData")
load("para/para237.RData")
para <- para1634

## Set-up
m <- nrow(para$sigma)  # Cross-sectional dimension
n <- 600               # Sample size
p <- 0.1               # True proportion of alternatives

## Set of alternatives
sigma <- diag(t(para$sigma) %*% para$sigma)
IR    <- para$alpha/sqrt(sigma)
H1    <- order(abs(IR), decreasing = TRUE)[0:floor(p*m)]
alpha <- para$alpha*(1:m %in% H1)

## Simulated samples
samples <- sampling(n, m, para, H1, df = 3)

## p-values
type  <- "double_side"
p_ori <- pvalue(mlt_ori(samples), type = type)
p_ora <- pvalue(mlt_ora(samples, alpha, sigma), type = type)
p_ada <- pvalue(mlt_dw(samples, type = type, ada = TRUE), type = type)
p_sop <- pvalue(mlt_dw(samples, type = type, ada = TRUE, robust = TRUE), type = type)

## Rejections in multiple testing (Benjamini and Hochberg, 1995)
tau   <- 0.1
r_ori <- MLT_BH(p_ori, tau)
r_ora <- MLT_BH(p_ora, tau)
r_ada <- MLT_BH(p_ada, tau)
r_sop <- MLT_BH(p_sop, tau)

## Given true parameters
fdp_ori <- MLT_BH(p_ori, tau, FDP = TRUE, H1 = H1)
fdp_ora <- MLT_BH(p_ora, tau, FDP = TRUE, H1 = H1)
fdp_ada <- MLT_BH(p_ada, tau, FDP = TRUE, H1 = H1)
fdp_sop <- MLT_BH(p_sop, tau, FDP = TRUE, H1 = H1)

## Estimated proportion of alternatives 
J_sop  <- shrink(S_POET(samples))

### Storey (2002)
st_ori <- AP_ST(p_ori, 0.5, 0)
st_ora <- AP_ST(p_ora, 0.5, 0)
st_ada <- AP_ST(p_ada, 0.5, 0)
st_sop <- AP_ST(p_sop[J_sop], 0.5, 0)*sum(J_sop)/m

### Benjamini et al. (2006)
tst_ori <- AP_TST(p_ori, 0.1)
tst_ora <- AP_TST(p_ora, 0.1)
tst_ada <- AP_TST(p_ada, 0.1)
tst_sop <- AP_TST(p_sop[J_sop], 0.1)*sum(J_sop)/m

### Farcomeni and Pacillo (2011)
fp_ori <- AP_FP(p_ori, 0.05)
fp_ora <- AP_FP(p_ora, 0.05)
fp_ada <- AP_FP(p_ada, 0.05)
fp_sop <- AP_FP(p_sop[J_sop], 0.05)*sum(J_sop)/m

## Outputs
summ <- data.frame(matrix(NA, 4, 6))
rownames(summ) <- c("Ori", "Ora", "Ada", "SOAP")
colnames(summ) <- c("R","FDP","POW","ST","TST","FP")
summ$R   <- c(length(r_ori), length(r_ora), length(r_ada), length(r_sop))
summ$FDP <- round(c(fdp_ori[1], fdp_ora[1], fdp_ada[1], fdp_sop[1]), 3)
summ$POW <- round(c(fdp_ori[2], fdp_ora[2], fdp_ada[2], fdp_sop[2]), 3)
summ$ST  <- round(c(st_ori,  st_ora,  st_ada,  st_sop),  3)
summ$TST <- round(c(tst_ori, tst_ora, tst_ada, tst_sop), 3)
summ$FP  <- round(c(fp_ori,  fp_ora,  fp_ada,  fp_sop),  3)
show(summ)

