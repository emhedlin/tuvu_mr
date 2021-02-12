library(nuwcru)
library(brms)
library(tidybayes)
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
set.seed(123)




# Load data ---------------------------------------------------------------


dat <- read_csv("data/tuvu_ch.csv") %>% filter(age == "hy")
y <- dat[,4:ncol(dat)]




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
first <- c()
last <- c()
for (i in 1:nrow(y)){
  first[i] <- first_capture(y[i,])
  last[i] <- last_capture(y[i,])
}

# create matrix of ages
ages <- 1:17
age <- y

for (i in 1:nrow(y)){
  for (t in first[i]:ncol(y)){
    k = t - (first[i]-1)
    age[i,t] <- ages[k]      
  }
}



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
params <- c("beta", "mean_p")

## MCMC settings
ni <- 2000
nt <- 1
nb <- 1000
nc <- 4

## Initial values
inits <- function() list(beta = runif(16, 0, 1),
                         alpha = runif(16, 0, 1))



## Call Stan from R
cjs_age  <- stan("/Volumes/GoogleDrive/My Drive/NuWCRU/Analysis/NuWCRU/example-models/BPA/Ch.07/cjs_age.stan",
                 data = stan_data, init = inits, pars = params,
                 chains = nc, iter = ni, warmup = nb, thin = nt,
                 seed = 1,
                 open_progress = FALSE)

## Summarize posteriors
print(cjs_age, digits = 3)



# age _ phi and p ---------------------------------------------------------



stan_data <- list(y = y,
                  nind = nrow(y),
                  n_occasions = ncol(y),
                  x = age,
                  max_age = max(age))

## Parameters monitored
params <- c("beta", "alpha")

## Call Stan from R
inits <- function() list(beta = runif(16, 0, 1),
                         alpha = runif(16, 0, 1))

## MCMC settings
ni <- 3000
nt <- 1
nb <- 1000
nc <- 4


cjs_age  <- stan("models/cjs_age-phi_p.stan",
                 data = stan_data, init = inits, pars = params,
                 chains = nc, iter = ni, warmup = nb, thin = nt,
                 seed = 1,
                 open_progress = FALSE)





# visual ------------------------------------------------------------------
library(bayesplot)

posterior2 <- extract(cjs_age)
mcmc_scatter(
  as.matrix(cjs_age),
  pars = c("beta[5]", "alpha[5]"),
  np = nuts_params(cjs_age),
  np_style = scatter_style_np(div_color = "green", div_alpha = 0.8)
)

color_scheme_set("mix-blue-pink")
p <- mcmc_trace(posterior2,  pars = c("mu", "tau"), n_warmup = 300,
                facet_args = list(nrow = 2, labeller = label_parsed))
p + facet_text(size = 15)


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


ann_text <- tibble(year = factor(1, levels = 1:16))



stan_all %>% 
  ggplot() +
  geom_histogram(aes(x = surv), fill="#ffdcaa", bins = 500) + 
  geom_histogram(data = stan_all, aes(x = surv), fill ="#ffdcaa", bins = 500) + 
  geom_histogram(aes(x = det), fill = "#d4d4d4", bins = 500) +
  geom_point(data = mean_surv_stan, aes(x = mean_surv, y = 0, alpha = alpha), colour = "#ffa92d") +
  geom_point(data = mean_det_stan, aes(x = mean_det, y = 0, alpha = alpha), colour = "#252836") +
  facet_grid(year~., switch = "y") +
  theme_nuwcru() + facet_nuwcru() + 
  geom_text(data = ann_text, aes(x = 0.90, y = 500), label = "survival", colour = "#ffa92d") +
  geom_text(data = ann_text, aes(x = 0.15, y = 500), label = "detection", colour = "#d4d4d4") +
  labs(subtitle = "Posteriors for survival and detection") +
  ylab("") + xlab("") +
  theme(panel.border = element_blank(), axis.line.y = element_blank(), axis.text.y = element_blank(), 
        axis.ticks.x = element_blank(),axis.ticks.y = element_blank(), axis.text.x = element_text(angle = 0, hjust = 0.5), plot.subtitle = element_text(colour = "#252836", hjust = 0.5),
        strip.background = element_rect(colour = "white"), strip.text.y.left = element_text(angle = 0))


getmode <- function(x) {
  uniqx <- unique(x)
  uniqx[which.max(tabulate(match(x, uniqx)))]
}



vis <- stan_all %>% 
  pivot_longer(surv:det) %>%
  group_by(year, name) %>%
  summarize(mode = getmode(value),
            sd = sd(value)) %>%
  mutate(ualpha = mode + (sd*1.96),
         lalpha = mode - (sd*1.96),
         alpha = plogis(1/(ualpha-lalpha))*2) %>%
  mutate(upper95 = ifelse(mode + (sd*1.96)  > 1, 1, mode + (sd*1.96)),
         upper80 = ifelse(mode + (sd*1.282) > 1, 1, mode + (sd*1.282)),
         upper50 = ifelse(mode + (sd*0.674) > 1, 1, mode + (sd*0.674)),
         lower95 = ifelse(mode - (sd*1.96)  < 0, 0, mode - (sd*1.96)),
         lower80 = ifelse(mode - (sd*1.282) < 0, 0, mode - (sd*1.282)),
         lower50 = ifelse(mode - (sd*0.674) < 0, 0, mode - (sd*0.674))) %>%
  mutate(year = as.numeric(year))

dim(y)
# export as png, 700 x 826
p_surv <- ggplot() +
  geom_segment(data = filter(vis, name == "surv"), aes(x = year, xend = year, y = lower95, yend = upper95,alpha = alpha +(alpha*.2)), colour = "#ffdcaa", size = 0.5) +
  geom_segment(data = filter(vis, name == "surv"), aes(x = year, xend = year, y = lower80, yend = upper80,alpha = alpha +(alpha*.2)), colour = "#ffdcaa", size = 1) +
  geom_segment(data = filter(vis, name == "surv"), aes(x = year, xend = year, y = lower50, yend = upper50,alpha = alpha +(alpha*.2)), colour = "#ffdcaa", size = 2) +
  geom_point(data = filter(vis, name == "surv"), aes(x = year, y = mode, alpha = alpha), shape = 16, stroke=0, colour = "#ffa92d", size = 2) +
  geom_text(aes(x = 2.8, y = 0.05), label = "survival probability", colour = "#ffa92d", size = 4.75) +
  ggtitle("Age-specific Estimates") +
  xlab("") + ylab("") +
  scale_x_continuous(limits = c(1,16), breaks = seq(1,16,1)) +
  theme_nuwcru() +
  theme(axis.line.y = element_blank(), 
        axis.ticks.x = element_blank(),axis.ticks.y = element_blank(), axis.text.x = element_blank(),axis.line.x = element_blank(),
        plot.title = element_text(colour = "#252836", size = 12), legend.position = "none")

p_det <- ggplot() +
  geom_segment(data = filter(vis, name == "det"), aes(x = year, xend = year, y = lower95, yend = upper95, alpha = alpha), colour = "#d4d4d4", size = 0.5) +
  geom_segment(data = filter(vis, name == "det"), aes(x = year, xend = year, y = lower80, yend = upper80, alpha = alpha), colour = "#d4d4d4", size = 1) +
  geom_segment(data = filter(vis, name == "det"), aes(x = year, xend = year, y = lower50, yend = upper50, alpha = alpha), colour = "#d4d4d4", size = 2) +
  geom_point(data = filter(vis, name == "det"), aes(x = year, y = mode, alpha = alpha), shape = 16, stroke=0, colour = "#252836", size = 2) +
  geom_text(aes(x = 3, y = 0.05), label = "resighting probability", colour = "#c6c6c6", size = 4.75) +
  xlab("") + ylab("") +
  scale_x_continuous(limits = c(1,16), breaks = seq(1,16,1)) +
  theme_nuwcru() +
  theme(axis.line.y = element_blank(), 
        axis.ticks.x = element_blank(),axis.ticks.y = element_blank(), axis.text.x = element_text(angle = 0, hjust = 0.5),axis.line.x = element_blank(),
        plot.title = element_text(colour = "#252836"), legend.position = "none")

ggpubr::ggarrange(p_surv, p_det, ncol = 1, nrow = 2)

