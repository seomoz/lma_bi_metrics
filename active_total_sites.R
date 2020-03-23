# LMA trends
# 
# NB - data is from CSV downloaded from LMA metabase
# Query is in lma_active.sql file
library(lubridate)
library(tidyverse)
library(ggplot2)
library(prophet)

df_raw <- read.csv(file = 'lma_active_total_sites_2020_03_11.csv')

df <- df_raw %>%
      mutate(ds = ymd(substr(signup_date, 1, 11))) %>%
      select(-c(signup_date))

ggplot(data = df, aes(x = ds, y = rolling_active_sites_count)) +
  geom_line() +
  ylim(c(0,3000)) +
  ggtitle(label = 'LMA Rolling Active Sites',
          subtitle = paste0('since ', min(df$ds)))
