library(R2jags)


# Script simulates age structured (hatch-year, after hatch-year) cr data, and evaluates



# cjs sim function --------------------------------------------------------

sim_cjs <- function(phi, p, marked){
  n_occasions <- dim(phi)[2] + 1
  cap_hist <- matrix(0, ncol = n_occasions, nrow = sum(marked))
  
  # Define a vector with the occasion of marking
  mark.occ <- rep(1:length(marked), marked[1:length(marked)])
  
  # Fill the cap_hist matrix
  for (i in 1:sum(marked)){
    cap_hist[i, mark.occ[i]] <- 1 # 1 at the release occasion
    if (mark.occ[i]==n_occasions) next
    for (t in (mark.occ[i]+1):n_occasions){
      
      # Bernoulli trial: does individual survive occassion?
      sur <- rbinom(1, 1, phi[i,t-1])
      if (sur==0) break		# If dead, move to next individual 
      
      # Bernoulli trial: is individual recaptured? 
      rp <- rbinom(1, 1, p[i,t-1])
      if (rp==1) cap_hist[i,t] <- 1
    } #t
  } #i
  return(cap_hist)
}





# simulate data -----------------------------------------------------------





# Define parameter values
n_occasions <- 17                   # Number of capture occasions
marked_j <- rep(20, n_occasions-1)  # Annual number of newly marked juveniles
marked_a <- rep(10, n_occasions-1)  # Annual number of newly marked adults
phi_juv <- 0.3                      # Juvenile annual survival
phi_ad <- 0.65                      # Adult annual survival
p <- rep(0.2, n_occasions-1)        # Recapture

phi_j <- c(phi_juv, rep(phi_ad, n_occasions-2))
phi_a <- rep(phi_ad, n_occasions-1)

# Define matrices with survival and recapture probabilities
PHI_J <- matrix(0, ncol = n_occasions-1, nrow = sum(marked_j))
for (i in 1:length(marked_j)){
  PHI_J[(sum(marked_j[1:i])-marked_j[i]+1):sum(marked_j[1:i]),i:(n_occasions-1)] <- matrix(rep(phi_j[1:(n_occasions-i)],marked_j[i]), ncol = n_occasions-i, byrow = TRUE)
}

P_J <- matrix(rep(p, sum(marked_j)), ncol = n_occasions-1, nrow = sum(marked_j), byrow = TRUE)
PHI_A <- matrix(rep(phi_a, sum(marked_a)), ncol = n_occasions-1, nrow = sum(marked_a), byrow = TRUE)
P_A <- matrix(rep(p, sum(marked_a)), ncol = n_occasions-1, nrow = sum(marked_a), byrow = TRUE)

# Apply simulation function
CH_J <- sim_cjs(PHI_J, P_J, marked_j)  # individuals marked as juveniles
CH_A <- sim_cjs(PHI_A, P_A, marked_a)  # individuals marked as adults 

# Create vector with occasion of marking
get_first <- function(x) min(which(x!=0))
f_j <- apply(CH_J, 1, get_first)
f_a <- apply(CH_A, 1, get_first)

# Create matrices X indicating age classes
x_j <- matrix(NA, ncol = dim(CH_J)[2]-1, nrow = dim(CH_J)[1])
x_a <- matrix(NA, ncol = dim(CH_A)[2]-1, nrow = dim(CH_A)[1])

for (i in 1:nrow(CH_J)){
  for (t in f_j[i]:(ncol(CH_J)-1)){
    x_j[i,t] <- 2
    x_j[i,f_j[i]] <- 1   
  } #t
} #i

for (i in 1:nrow(CH_A)){
  for (t in f_a[i]:(ncol(CH_A)-1)){
    x_a[i,t] <- 2
  } #t
} #i
dim(CH)


# review data -------------------------------------------------------------


CH <- rbind(CH_J, CH_A)
f <- c(f_j, f_a)
x <- rbind(x_j, x_a)
x <- matrix(NA, ncol = ncol(CH)-1, nrow = nrow(CH))


# jags model --------------------------------------------------------------


# I included a section for continuous age since we do have some specific ages in the tuvu dataset
# I suspect we should treat individuals as hatch year vs after hatch year though, not sure we have
# the confidence in age identification to be more specific

# Specify model in BUGS language
cat(file = "cjs-age.txt", "
model {

# If age is continuous - 
# Constraints - uncomment for continuous age class
    #  for (i in 1:nind){
    #    for (t in f[i]:(n_occasions-1)){
    #      logit(phi[i,t]) <- mu + beta*x[i,t]
    #      p[i,t] <- mean.p
    #    } #t
    #  } #i
    #  
    #  # Priors (and derived parameters)
    #  mu ~ dnorm(0, 0.01)             # Prior for mean of logit survival
    #  beta ~ dnorm(0, 0.01)           # Prior for slope parameter
    #  for (i in 1:(n_occasions-1)){
    #    phi.age[i] <- ilogit(mu + beta*i)   # Logit back-transformation 
    #  }
    #  mean.p ~ dunif(0, 1)                # Prior for mean recapture

# Priors (and derived parameters)
    #  mu ~ dnorm(0, 0.01)             # Prior for mean of logit survival
    #  beta ~ dnorm(0, 0.01)           # Prior for slope parameter
    #  for (i in 1:(n_occasions-1)){
    #    phi.age[i] <- ilogit(mu + beta*i)   # Logit back-transformation 
    #  }
    #  mean.p ~ dunif(0, 1)                # Prior for mean recapture

# If age is categorical
# Constraints
    for (i in 1:nind){
       for (t in f[i]:(n_occasions-1)){
          phi[i,t] <- beta[x[i,t]]
          p[i,t] <- mean.p
          } #t
       } #i

# Priors
    for (u in 1:2){
       beta[u] ~ dunif(0, 1)     # Priors for age-specific survival
       }
    mean.p ~ dunif(0, 1)         # Prior for mean recapture
    
 # Likelihood 
    for (i in 1:nind){
      # Define latent state at first capture
      z[i,f[i]] <- 1
      for (t in (f[i]+1):n_occasions){
        # State process
        z[i,t] ~ dbern(phi[i,t-1] * z[i,t-1])
        # Observation process
        y[i,t] ~ dbern(p[i,t-1] * z[i,t])
      } #t
    } #i
}
")

# Bundle data
jags.data <- list(y = CH, 
                  f = f, 
                  nind = nrow(CH), 
                  n_occasions = ncol(CH), 
                  x = x)

z.inits <- function(ch){
  state <- ch
  state[state==0] <- 1
  get.first <- function(x) min(which(x!=0))
  f <- apply(ch, 1, get_first)
  for (i in 1:nrow(ch)){
    state[i,1:f[i]] <- NA
  }
  return(state)
}



# Initial values
inits <- function(){list(z = z.inits(CH), 
                         beta = runif(2, 0, 1), 
                         mean.p = runif(1, 0, 1))}  

# Parameters monitored
parameters <- c("beta", 
                "mean.p")

# MCMC settings
ni <- 5000
nt <- 1
nb <- 1000
nc <- 2

# Call JAGS from R
cjs.age <- jags(data = jags.data, 
                inits = inits, 
                parameters.to.save = parameters, 
                model.file = "cjs-age.txt", 
                n.chains = nc, 
                n.thin = nt, 
                n.iter = ni, 
                n.burnin = nb)



# model results -----------------------------------------------------------


print(cjs.age, digits = 2)

