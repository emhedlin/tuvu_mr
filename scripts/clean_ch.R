library(tidyverse)



# 1. unique ---------------------------------------------------------------
resight <- read_csv("data/resight.csv") %>% filter(dead != "dead") %>%
  select(tag, year, age, origin, dead) %>%
  filter(tag != "T55")

banded <- read_csv("data/banded.csv") %>% filter(!is.na(Yr) | Yr < 2003)
names(banded)[2] <- "tag"


unique_tags <- c(unique(resight$tag), unique(banded$tag))
unique_tags <- unique(unique_tags)


# 2. ----------------------------------------------------------------------

tags_year <- expand.grid(tag = unique_tags,
                         year = 2003:2019)



# 3. ----------------------------------------------------------------------

banded_unique <- banded %>% 
  filter(A == 4) %>% # hatch year
  select(tag, "year" = "Yr") %>%
  mutate(cap = rep(1)) %>%
  filter(!duplicated(tag)) %>%
  filter(year > 2002)


# 4. ----------------------------------------------------------------------


ages_origin <- resight %>%
  filter(origin == "y") %>% # hatch your
  filter(age == "0") %>%
  mutate(tag_year = paste0(tag,year)) %>%
  filter(!duplicated(tag_year)) %>%
  select(-tag_year, -age, - origin, -dead) %>%
  mutate(cap = rep(1))



resights <- resight %>% 
  filter(origin != "y") %>%
  filter(tag %in% c(banded_unique$tag, ages_origin$tag)) %>%
  select(tag, year) %>%
  mutate(cap = rep(1))

combined <- rbind(banded_unique, ages_origin, resights)
  
ch <- combined %>% 
  mutate(tag_year = paste0(tag, year)) %>%
  filter(!duplicated(tag_year)) %>%
  select(-tag_year)%>%
  mutate(tag = as.factor(tag))


unique_tags_years <- tibble(expand.grid(tag = unique(c(ages_origin$tag, banded_unique$tag)),
                                 year = 2003:2019))

ch_full <- unique_tags_years %>%
  left_join(ch, by = c("tag", "year")) %>%
  mutate(cap = ifelse(is.na(cap), 0, cap))


ch_tag <- ch_full %>% 
  pivot_wider(id_cols = tag, names_from = year, values_from = cap) 

write.csv(ch_tag, "data/tuvu_ch.csv")


