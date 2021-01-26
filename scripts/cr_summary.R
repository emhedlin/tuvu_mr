

# Constant parms ----------------------------------------------------------

#     * phi(.), p(.) ----

# Priors
phi ~ dunif(0,1)
p ~ dunif(0,1)

# Likelihood
for (i in 1 : n_individuals){
  # define latent state at first capture
  z[i, f[i]] <- 1
  
  for (t in (f[i] + 1) : n_occaisions){
    # State Process
    z[i,t] ~ dbern(phi * z[i,t-1])
    
    # Observation Process
    y[i,t] ~ dbern(p * z[i,t])
  }
}




# _------------------------------------------------------------------------
# Cormack-Jolly-Seber -----------------------------------------------------

#     * phi(t), p(t) ----

# Priors
for (t in 1:n_occaisions){
phi[t] ~ dunif(0,1)
p[t] ~ dunif(0,1)
}

# Likelihood
for (i in 1 : n_individuals){
  # define latent state at first capture
  z[i, f[i]] <- 1
  
  for (t in (f[i] + 1) : n_occaisions){
    # State Process
    z[i,t] ~ dbern(phi[t-1] * z[i,t-1])
    
    # Observation Process
    y[i,t] ~ dbern(p[t-1] * z[i,t])
  }
}


#     * phi(i,t), p(i,t) ----

# Priors
for (i in 1 : n_individuals){
  for (t in 1:n_occaisions){
    phi[t] ~ dunif(0,1)
    p[t] ~ dunif(0,1)
  }
}

# Likelihood
for (i in 1 : n_individuals){
  # define latent state at first capture
  z[i, f[i]] <- 1
  
  for (t in (f[i] + 1) : n_occaisions){
    # State Process
    z[i,t] ~ dbern(phi[i,t-1] * z[i,t-1])
    
    # Observation Process
    y[i,t] ~ dbern(p[i,t-1] * z[i,t])
  }
}



# _------------------------------------------------------------------------
# Heterogeneity -----------------------------------------------------------

#     * temporal ----

# Fixed effect
  phi[i,t] <- alpha[t] # survival paramaters for each occaision

# Random corrections to population mean
  logit(phi[i,t]) <- mu + epsilon[t] 
  epsilon[t] ~ dnorm(0, tau)
  tau ~ dexp(1)

# with the random formulation, it's easy to see we can add further covariates
  logit(phi[i,t]) <- B[1] + B[2] * X[t] ... + epsilon[t] 
  

#     * individual ----
  
  logit(phi[i,t]) <- alpha[group[i]] # where group could indicate cohort, sex, etc.
  # and we can easily extend this into a linear model
  
  # with a continuous covariate (mass at birth etc.)
  logit(phi[i,t]) <- B[1] + B[2] * X[i] 
  

  #     * ind and temp ----
  logit(phi[i,t]) <- alpha[age[i,t]] # if age is a group (ie. young/adult)
  

  
  
  
  
