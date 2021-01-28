library(R2jags)



# Simulate Known Fate data for adults -------------------------------------

## Known-fate survival


n <- 20                    # number of adults with transmitters
n_years <- 17              # number of years
phi_mean <- 0.65           # population average survival
phi_lin <-  log(phi_mean/(1-phi_mean))
first <- rpois(n, 5) + 1   # year of first capture
first[first > n_years] <- n_years  # ensure date of capture isn't > 20

year <- as.numeric(scale(1:n_years))
individual <- rnorm(n)


y <- phi <- matrix(NA, n, n_years, dimnames=list(paste("vulture", 1:n, sep=""), 
                                           paste("year", 1:n_years, sep="")))

for(i in 1:n) {
  y[i, first[i]] <- 1
  for(t in (first[i]+1):n_years) {
    phi[i, t] <- plogis(phi_lin + 1*year[t] + 1*individual[i] + -0.5*t) # -0.5*t is age, where -0.5 describes the declining survival
    y[i, t] <- rbinom(1, 1, y[i, t-1] * phi[i, t])
  }
}



last <- rep(NA, n)
for(i in 1:n) {
  lastreal <- max(which(!is.na(y[i,])))
  lastzero <- 17
  if(any(y[i,] < 1, na.rm = n_years))
    lastzero <- min(which(y[i,] < 1))
  last[i] <- min(lastreal, lastzero + sample(2:3, 1))
}

cbind(first, last)	
min(last-first)	# minimum number of years an individual survived
max(last-first)	# max number of years an individual survived


for(i in 1:n) {
  if(last[i] < n_years) 
    y[i, (last[i]+1) : n_years] <- NA
}

# run to obscure some years - check status of our transmitter data to see if it's reliable
    # for(i in 1:n) {
    #   if(y[i, last[i]] < 1) {
    #     threeless <- last[i] - 3
    #     second <- first[i] + 1
    #     secondtolast <- max(threeless, second)		
    #     y[i, secondtolast: (last[i] - 1)] <- NA
    #   }
    # }

# these must be true

all(apply(y, 1, function(x) length(!is.na(x)) > 1))
all(apply(y, 1, function(x) sum(x < 1, na.rm=n_years) < 2))
for(i in 1:n) stopifnot(y[i, first[i]] > 0)



y          # capture history
first      # 1st capture year
last       # year of death
year       # yearly heterogeneity
individual # individual heterogeneity






