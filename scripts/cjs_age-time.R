library(nuwcru)
library(brms)
library(tidybayes)
library(tidyverse)
library(rstan)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
set.seed(123)




# ran this with age-specific detection, but had high rhat, and 4 divergent transitions.
# switched to mean_p instead since resighting probability does seem to stay fairly consistent 
# when we have decent samples

stan_data <- list(y = y,
                  nind = nrow(y),
                  n_occasions = ncol(y),
                  x = age,
                  max_age = max(age))

#' beta = age specific survival
#' alpha = age specific detection
#' mean_phi/mu = mean survival
#' epsilon = vector of length n_occaision -1 = year ranef
#' gamma = vector of length nind = individual ranef
#' sigma_year = variance of epsilon
#' sigma_ind = variance of gamma

## Parameters monitored
params <- c("beta", "mean_p", "mu", "epsilon", "sigma")

## Call Stan from R
inits <- lapply(1:nc, function(i){ 
  list(beta = runif(16, 0, 1),
       mean_p = runif(1, 0, 1),
       mu = runif(1, 0, 1),
       epsilon = rnorm(stan_data$n_occasions-1))})

## MCMC settings
ni <- 3000
nt <- 1
nb <- 1000
nc <- 4


cjs_age_ranef_phi <- stan("models/cjs_age-phi_ran.stan",
                          data = stan_data, init = inits, pars = params,
                          chains = nc, iter = ni, warmup = nb, thin = nt,
                          seed = 1,
                          open_progress = FALSE)



