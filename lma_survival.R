# LMA Survival
library(tidyverse)
library(ggplot2)
library(RJDBC)
library(lubridate)

# libraries for databases and SQL...
source('~/db_connection_tools.R')
con <- redshift_connect(yaml_file = 'config.yml')
query <- getSQL(filepath = 'page_loads.sql')
df_raw <- dbGetQuery(conn = con, statement = query)

t <- today()

# number of days to cap the histogram at
cap_value <- 5

df <- df_raw %>%
      mutate(month = month(first_visit)) %>%
      mutate(max_bin = case_when(total_lifetime >= cap_value ~ cap_value, 
                                 TRUE ~ total_lifetime)) %>%
      mutate(zero_days = case_when(total_lifetime >= 1 ~ 1, 
                                   TRUE ~ total_lifetime)) %>%
      # Remove current_month
      filter(month != month(t))


# Make a histogram of how many days people stick around
p1 <- ggplot(data = df, aes(x = max_bin)) +
  geom_histogram(bins = 100) +
  facet_wrap(facets = ~ month) +
  ggtitle(label = 'LMA days between first and last visit',
          subtitle = paste('lifetime capped at', cap_value, 'days'))

# Show count of page loads
p2 <- ggplot(data = df, aes(x = page_loads)) +
  geom_histogram(bins = 50) +
  facet_wrap(facets = ~ month) +
  ggtitle(label = 'Histogram of page loads by user_id',
          subtitle = 'faceted by first visit month') +
  xlim(c(0,25))

ggsave(filename = paste0('~/Projects/ad_hoc/lma_survival/img/lifetime_', t, '.png'), plot = p1,
      width = 8, height = 6)
ggsave(filename = paste0('~/Projects/ad_hoc/lma_survival/img/pageloads_', t, '.png'), plot = p2,
       width = 8, height = 6)


# some renaming for writing nice stuff to CSV output
df_write <- df %>%
            mutate(sign_up_month = month) %>%
            select(-c(max_bin, zero_days, month))

write.table(x = df_write, 
           file = paste0('lma_engagement_population', t, '.csv'), 
           sep = "|",
           row.names = FALSE)

# ---------------------------- #
# Get distinct users over time
# ---------------------------- #
query <- getSQL(filepath = 'sql/distinct_users_over_time.sql')
df_raw <- dbGetQuery(conn = con, statement = query)

df <- df_raw %>%
        mutate(dt = ymd(dt))

p3 <- ggplot(data = df, aes(x = dt, y = distinct_anon_ids)) +
      geom_line() +
      geom_smooth() +
      ggtitle(label = 'Distinct Anonymous IDs per day w/ Loess smoothing',
              subtitle = paste0('LMA launch to ', t))

p4 <- ggplot(data = df, aes(x = dt, y = distinct_users)) +
      geom_line() +
      geom_smooth() +
      ggtitle(label = 'Distinct User IDs per day w/ Loess smoothing',
              subtitle = paste0('LMA launch to ', t))

ggsave(filename = paste0('~/Projects/ad_hoc/lma_survival/img/anon_ids_per_day_', t, '.png'), 
       plot = p3, width = 8, height = 6)
ggsave(filename = paste0('~/Projects/ad_hoc/lma_survival/img/user_ids_per_day_', t, '.png'), 
       plot = p4, width = 8, height = 6)





