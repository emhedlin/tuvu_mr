library(tidyverse)
library(nuwcru)


dat <- read_csv("data/resight.csv")
dat <- dat %>% filter(tag != "T55") # year is missing
# distribution of ages at tagging
table(dat$age) 

# assign categorical ages, hy or ahy
x <- dat %>% filter(origin == "y")
x$age_at_first_cap <- ifelse(x$age == "0", "hy", "ahy")
# dat <- x %>% select(tag, age_at_first_cap) %>% right_join(dat, by = "tag")


# calculate age at each resight
tuvu <- dat %>% 
  group_by(tag, year, origin, age, dead) %>% 
  tally() %>%
  group_by(tag) %>%
  arrange(year, .by_group = TRUE) # %>%
  # mutate(age_est = year - lag(year, default = first(year)) + lag(age, default = first(age))) 

# create df with entire date range for each individual
empty <- expand.grid(tag = unique(tuvu$tag), year = unique(tuvu$year))

# fill empty dates with observations, results in balanced dataframe
tuvu_ex <- empty %>% 
  left_join(tuvu, by = c("tag", "year")) %>% 
  arrange(tag, year)

# ch <- tuvu_ex %>%
#   mutate(cap = ifelse(is.na(n), 0, 1)) %>%
#   select(tag, year, cap) %>%
#   left_join(select(x, tag, "age" = "age_at_first_cap"), by = "tag") %>%
#   filter(!is.na(year)) %>%
#   filter(!duplicated(tag, year))
# 
# ch <- ch %>% filter(!is.na(year))
# ch %>% group_by(year, tag) %>% tally() %>% filter(n > 2)
# ch %>% filter(year == 2003 & tag == "58H")
# 
# 
# ch %>% select(-age) %>%
#   pivot_wider(id_cols = tag, names_from = year, values_from = cap)
# ?pivot_wider












# # split balanced df into list by individual
# tuvu_ex_list <- tuvu_ex %>% 
#   group_by(tag) %>% 
#   group_split()
# 
# for ( i in 1:length(tuvu_ex_list)){
#   firstyear <- filter(tuvu_ex_list[[i]], origin == "y") 
#   firstyear <- firstyear$year - firstyear$age_est
#   tuvu_ex_list[[i]]$age_est <- tuvu_ex_list[[i]]$year - firstyear
#   tuvu_ex_list[[i]] <- filter(tuvu_ex_list[[i]], age_est >= 0)
# }
# 




tuvu <- tuvu_ex %>% 
 # select(tag:origin, dead:n, "age" = "age_est") %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>%
  right_join(empty, by = c("tag", "year")) %>% 
  arrange(tag, year) %>%
  filter(!is.na(year)) %>%
  group_by(tag, year) %>%
  summarize(cap = max(n, na.rm = TRUE)) %>%
  mutate(cap = ifelse(cap > 0, 1, 0))



ch <- tuvu %>% select(tag, year, cap) %>%
  left_join(x %>% filter(!duplicated(tag)) %>% select(tag, "age" = "age_at_first_cap"), by = "tag") 

 # by tag
ch_tag <-ch %>% 
  select(-age) %>%
  mutate(year = as.factor(year)) %>%
  pivot_wider(id_cols = tag, names_from = year, values_from = cap) 

# by age
ch_age <- ch %>% 
  mutate(year = as.factor(year)) %>%
  pivot_wider(id_cols = c(tag,age), names_from = year, values_from = cap) 

write.csv(ch_age, "data/tuvu_ch.csv")
read_csv("data/tuvu_ch.csv")
  
View(ch_age)

sum(is.na(ch_age))
x <- ch_age[,3:ncol(ch_age)]

test <- c()
for (i in 1:nrow(x)){
  test[i] <-  sum(x[i,])
}
which(test == 0)

ch_age[311,]

names(ch)[2:ncol(ch)] <- as.character(2003:2019)
  
  


tuvu %>% 
  group_by(tag) %>%
  group_split()

tagged <- tuvu %>% 
  group_by(year) %>%
  filter(origin == 'y') %>%
  summarize(n_tagged = sum(n, na.rm = TRUE)) 

resight <- tuvu %>% 
  group_by(year) %>%
  filter(origin == 'n') %>%
  summarize(n_tagged = sum(n, na.rm = TRUE)) 


# saved as jpg, 1500x383
ggplot() +
  geom_line(data = resight, aes(x = year, y = n_tagged), colour = grey7) +
  geom_point(data = resight, aes(x = year, y = n_tagged), size = 5.5, shape = 21, colour = grey7, fill = "white") +
  geom_line(data = tagged, aes(x = year, y = n_tagged)) +
  geom_point(data = tagged, aes(x = year, y = n_tagged), size = 4, shape = 21, colour = grey2, fill = grey2) +
  xlab("") + ylab(expression(paste(italic("n")))) +
  scale_x_continuous(breaks = seq(2003, 2019, 1)) +
  scale_y_continuous(breaks = seq(0, 90, 10)) +
  geom_text(aes(x = 2016.7, y = 10), label = "tagged", family = "Times New Roman", size = 6) +
  geom_text(aes(x = 2019, y = 10), label = "resight", family = "Times New Roman", colour = grey6, size = 6) +
  nuwcru::theme_nuwcru() +
  theme(axis.text.x = element_text(size =12),
        axis.text.y = element_text(size =12),
        axis.title.y = element_text(size = 13))

age <- tuvu %>% 
  filter(origin == 'n') %>%
  group_by(year, age) %>%
  tally()

tuvu %>% group_by(origin) %>% tally()

tuvu %>% filter(!is.na(origin)) %>% group_by(tag) %>% tally() %>% arrange(desc(n))

tuvu %>% filter(tag == "S11")
ggplot() +
 geom_segment(data = filter(age, age == 1), aes(x = year-0.49, xend = year-0.49, y = 0, yend = n), colour = grey7) +
 geom_text(data = filter(age, age == 1), aes(x = year-0.43, y = n+0.5), label = "1", size = 2) +
 geom_segment(data = filter(age, age == 2), aes(x = year-0.43, xend = year-0.43, y = 0, yend = n), colour = grey7) +
 # geom_point(data = age, aes(x = year, y = n, group = age), colour= "white", size = 3) +
 # geom_point(data = age, aes(x = year, y = n, group = age), colour = "white", size = 3) +
 # geom_text(data = age, aes(x = year, y = n, group = age, label = age), size = 2.5, position=position_jitter(width=.3)) +
  xlab("") + ylab(expression(paste(italic("n")))) +
  scale_x_continuous(breaks = seq(2003, 2019, 1)) +
  scale_y_continuous(breaks = seq(0, 20, 2)) +
  theme_nuwcru()



# Movement ----------------------------------------------------------------

# *Isolate SK ----
library(tidyverse)
tran <- arrow::read_parquet("data/hm_transmitter.parquet")

# rename columns, remove backticks etc.
tran <- tran %>%
  set_names(~ str_to_lower(.) %>%
              str_replace_all("-", "_") %>%
              str_replace_all("`", "") %>%
              str_replace_all(":", "_"))
names(tran)

unique(tran$individual_local_identifier)

# Spatial limits

# west long > -113
# east long < -91
# northing lat > 48

tran_sk <- tran %>%
  filter(location_lat >= 47 & location_long > -113 & location_long < -91) %>%
  mutate(year = lubridate::year(timestamp))

# SK individuals, number of fixes per year
tran_sk %>%
  group_by(tag_local_identifier, year) %>%
  tally()

# date of first fix by individual
tran_sk %>%
  group_by(tag_local_identifier) %>%
  summarize(first_fix = min(year)) %>%
  group_by(first_fix) %>%
  tally()

write.csv(tran_sk, "data/tran_sk.csv")


