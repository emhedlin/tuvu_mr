library(nuwcru)
library(brms)
library(tidybayes)
library(tidyverse)
library(rstan)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
set.seed(123)



#  - beta[x[i,t]]  # age dependant survival
#  - alpha[x[i,t]] # age dependant resight 






# Load data ---------------------------------------------------------------


dat <- read_csv("data/tuvu_ch.csv") 
y <- dat[,3:ncol(dat)]


# generate age covs -------------------------------------------------------

# functions to pull out first and last captures
first_capture <- function(y_i){
  for (k in 1:length(y_i)){
    if (y_i[k] == 1){return(k)}
  }
}

last_capture <- function(y_i){
  for (k_rev in 0:(length(y_i)-1)){
    k <- length(y_i)-k_rev
      if (y_i[k] == 1){return(k)}
  }
}



# create vectors of first and last captures/resights
first <- rep(0,nrow(y))
last <- rep(0,nrow(y))

for (i in 1:nrow(y)){
  first[i] <- first_capture(y[i,])
  last[i] <- last_capture(y[i,])
  }


# create matrix of ages

#         1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7
# ages <- c(1,2,3,4,5,6,7,8,8,8,8,8,9,9,9,9,9)
ages <- 1:17
age <- y

for (i in 1:nrow(y)){
  for (t in first[i]:ncol(y)){
    k = t - (first[i]-1)
    age[i,t] <- ages[k]      
  }
}


y
# check data
y
first
last
age <- age[,-17]


# Age as fixed ------------------------------------------------------------

stan_data <- list(y = y,
                  nind = nrow(y),
                  n_occasions = ncol(y),
                  x = age,
                  max_age = max(age))

## Parameters monitored
params <- c("beta", "alpha")

## MCMC settings
ni <- 2000
nt <- 1
nb <- 1000
nc <- 4

## Initial values
inits <- function() list(beta = runif(16, 0, 1),
                         alpha = runif(16, 0, 1))

## Call Stan from R
cjs_age  <- stan("models/cjs_age-phi_p.stan",
                 data = stan_data, init = inits, pars = params,
                 chains = nc, iter = ni, warmup = nb, thin = nt,
                 seed = 1,
                 open_progress = FALSE)

## Summarize posteriors
print(cjs_age, digits = 3)




# visual ------------------------------------------------------------------


getmode <- function(x) {
  uniqx <- unique(x)
  uniqx[which.max(tabulate(match(x, uniqx)))]
}

post <- posterior_samples(cjs_age) %>%
  select(-lp__) %>% 
  gather(key, value)


stan_alpha <- post %>% filter(str_detect(key, "alpha"))
stan_beta <- post %>% filter(str_detect(key, "beta"))
stan_year <- str_extract(stan_alpha$key, "\\-*\\d+\\.*\\d*")
stan_all <- tibble(year = as.factor(as.numeric(stan_year)),
                   surv = stan_beta$value,
                   det = stan_alpha$value)

mean_surv_stan <- stan_all %>%
  group_by(year) %>%
  summarize(mean_surv = mean(surv),
            sd = sd(surv)) %>%
  mutate(alpha = plogis((1/sd)*.1))

mean_det_stan <- stan_all %>%
  group_by(year) %>%
  summarize(mean_det = mean(det),
            sd = sd(det)) %>%
  mutate(alpha = plogis((1/sd)*.1))




vis <- stan_all %>% 
  pivot_longer(surv:det) %>%
  group_by(year, name) %>%
  summarize(upper95 = hdi(value, .width = 0.95)[2],
            lower95 = hdi(value, .width = 0.95)[1],
            upper80 = hdi(value, .width = 0.80)[2],
            lower80 = hdi(value, .width = 0.80)[1],
            upper50 = hdi(value, .width = 0.50)[2],
            lower50 = hdi(value, .width = 0.50)[1]) %>%
  mutate(mean = (upper50 + lower50)/2,
         alpha = plogis(1/(upper95 - lower95)))
  # mutate(upper95 = ifelse(mode + (sd*1.96)  > 1, 1, mode + (sd*1.96)),
  #        upper80 = ifelse(mode + (sd*1.282) > 1, 1, mode + (sd*1.282)),
  #        upper50 = ifelse(mode + (sd*0.674) > 1, 1, mode + (sd*0.674)),
  #        lower95 = ifelse(mode - (sd*1.96)  < 0, 0, mode - (sd*1.96)),
  #        lower80 = ifelse(mode - (sd*1.282) < 0, 0, mode - (sd*1.282)),
  #        lower50 = ifelse(mode - (sd*0.674) < 0, 0, mode - (sd*0.674))) %>%
  # mutate(year = as.numeric(year))


vis
p_surv <- ggplot() +
  geom_jitter(data = stan_all, aes(x = year, y = surv), colour = grey8, alpha = 0.03) +
  #geom_line(data = filter(vis, name == "surv"), aes(x = year, y = mean), colour = "#ffdcaa" )+
  geom_segment(data = filter(vis, name == "surv"), aes(x = year, xend = year, y = lower95, yend = upper95, alpha = alpha), colour = "#ffdcaa", size = 0.5) +
  geom_segment(data = filter(vis, name == "surv"), aes(x = year, xend = year, y = lower80, yend = upper80, alpha = alpha), colour = "#ffdcaa", size = 1) +
  geom_segment(data = filter(vis, name == "surv"), aes(x = year, xend = year, y = lower50, yend = upper50, alpha = alpha), colour = "#ffdcaa", size = 2) +
  geom_point(data = filter(vis, name == "surv"), aes(x = year, y = mean, alpha = alpha), shape = 16, stroke=0, colour = "#ffa92d", size = 2) +
  #geom_text(aes(x = 2.8, y = 0.05), label = "survival probability", colour = "#ffa92d", size = 4.75) +
  ggtitle("Age-specific Estimates") +
  xlab("") + ylab("") +
  theme_nuwcru() +
  theme(axis.line.y = element_blank(), 
        axis.ticks.x = element_blank(),axis.ticks.y = element_blank(), axis.text.x = element_blank(),axis.line.x = element_blank(),
        plot.title = element_text(colour = "#252836", size = 12), legend.position = "none")

p_det <- ggplot() +
  geom_jitter(data = stan_all, aes(x = year, y = det), colour = grey8, alpha = 0.03) +
  geom_segment(data = filter(vis, name == "det"), aes(x = year, xend = year, y = lower95, yend = upper95, alpha = alpha), colour = "#d4d4d4", size = 0.5) +
  geom_segment(data = filter(vis, name == "det"), aes(x = year, xend = year, y = lower80, yend = upper80, alpha = alpha), colour = "#d4d4d4", size = 1) +
  geom_segment(data = filter(vis, name == "det"), aes(x = year, xend = year, y = lower50, yend = upper50, alpha = alpha), colour = "#d4d4d4", size = 2) +
  geom_point(data = filter(vis, name == "det"), aes(x = year, y = mean, alpha = alpha), shape = 16, stroke=0, colour = "#252836", size = 2) +
  geom_text(aes(x = 3, y = 0.85), label = "resighting probability", colour = "#c6c6c6", size = 4.75) +
  xlab("") + ylab("") +
  theme_nuwcru() +
  theme(axis.line.y = element_blank(), 
        axis.ticks.x = element_blank(),axis.ticks.y = element_blank(), axis.text.x = element_text(angle = 0, hjust = 0.5),axis.line.x = element_blank(),
        plot.title = element_text(colour = "#252836"), legend.position = "none")

ggpubr::ggarrange(p_surv, p_det, ncol = 1, nrow = 2)





