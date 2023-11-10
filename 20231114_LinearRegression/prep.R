library(tidyverse)

horror_movies <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-11-01/horror_movies.csv')


data <- horror_movies %>%
  filter(original_language == "en") %>%
  select(title, release_date, revenue, budget, runtime, popularity, vote_count) %>%
  filter(budget > 0, popularity > 0, revenue > 0, vote_count > 500)

write_csv(data, file = "data/horror_movies.csv")
