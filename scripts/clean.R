library(tidyverse)



dat <- read_csv("data/resight.csv")

# distribution of ages at tagging
table(dat$age)

dat$age <- as.numeric(dat$age)

# calculate age at each resight
tuvu <- dat %>% 
  group_by(tag, year, origin, age, dead) %>% 
  tally() %>%
  group_by(tag) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(age_est = year - lag(year, default = first(year)) + lag(age, default = first(age))) 

# create df with entire date range for each individual
empty <- expand.grid(tag = unique(tuvu$tag), year = unique(tuvu$year))

# fill empty dates with observations, results in balanced dataframe
tuvu_ex <- empty %>% 
  left_join(tuvu, by = c("tag", "year")) %>% 
  arrange(tag, year)

# split balanced df into list by individual
tuvu_ex_list <- tuvu_ex %>% 
  group_by(tag) %>% 
  group_split()

for ( i in 1:length(tuvu_ex_list)){
  firstyear <- filter(tuvu_ex_list[[i]], origin == "y") 
  firstyear <- firstyear$year - firstyear$age_est
  tuvu_ex_list[[i]]$age_est <- tuvu_ex_list[[i]]$year - firstyear
  tuvu_ex_list[[i]] <- filter(tuvu_ex_list[[i]], age_est >= 0)
}

tuvu <- bind_rows(tuvu_ex_list) %>% 
  select(tag:origin, dead:n, "age" = "age_est") %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>%
  right_join(empty, by = c("tag", "year")) %>% 
  arrange(tag, year) %>%
  filter(!is.na(year))

tuvu

