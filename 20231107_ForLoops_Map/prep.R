df <- taylor::taylor_all_songs
library(tidyverse)

nested <- df%>%
  select(album_name, album_release, track_name, danceability, energy, loudness, tempo, duration_ms)%>%
  nest_by(album_name)%>%
  filter(!is.na(album_name))%>%
  mutate(album_name = janitor::make_clean_names(album_name))

map2(nested$album_name, nested$data, \(x,y)write_csv(y, file = paste0("data/",x,".csv")))
nested$data[[1]]

files <- list.files("data", pattern = "*.csv", full.names = TRUE)
bns <- basename(files)
clean_names <- str_remove(bns, ".csv")

names(files) <- clean_names
full_df <- map_dfr(files, read_csv, .id = "album_name")



