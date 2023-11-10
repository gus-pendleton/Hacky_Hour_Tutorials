list.files(path = "data")

library(tidyverse)

fearless_df <- read_csv(file = "data/fearless.csv")

# Let's write a basic for loop

for(x in c(1,2,3)){print(x)}

our_vector <- c(1,2,3)

for(y in our_vector){
  print(y)
  }


for(our_number in c(1,2,3)){
  new_number <- our_number * 10
  print(new_number)
}


our_files <- list.files(path = "data", pattern = "*.csv", full.names = TRUE)

our_files


for(file in our_files){
  taylor_dfs <- read_csv(file)
}

# Writing a for loop that works

# We need to initialize an empty list
taylor_dfs_list <- list()

# Indexing

our_files[2]

length(our_files)

1:4

for(index in 1:length(our_files)){
  taylor_dfs_list[[index]] <- read_csv(our_files[index])
}

taylor_dfs_list[1]


library(purrr)

taylor_dfs_map <- map(our_files, read_csv)

basenames <- basename(our_files)

clean_names <- str_remove(basenames, pattern = ".csv")

names(our_files) <- clean_names

our_files


final_df <- map_dfr(our_files, read_csv, .id = "Album")

final_df[2:3,4:5]
final_df$Album

final_df%>%
  select(Album, danceability)%>%
  filter(Album=="evermore")


