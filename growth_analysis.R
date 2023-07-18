# Loading our packages

library(tidyverse)

# Reading in data

growth_data <- read_csv("data/growth_data.csv")

gfp_data <- read_csv("data/gfp_data.csv")

# Okay, converting to a clean long format

clean_data_od <- growth_data%>%
  arrange(Time)%>% # Arrange so it's in order of timepoints
  mutate(TimePoint = row_number())%>% # Create "TimePoints" so we can combine OD and GFP
  pivot_longer(starts_with("S"), names_to = "Strain_Rep", values_to = "OD")%>% # Pivot out our names
  separate(Strain_Rep, sep = "_", into = c("Strain", "Replicate")) # Separate into Strain and Replicate

clean_data_gfp <- gfp_data%>%
  arrange(Time)%>% # Arrange so it's in order of timepoitns - you can see this actually did something!
  mutate(TimePoint = row_number())%>% # Create "TimePoints" so we can combine OD and GFP
  pivot_longer(starts_with("S"), names_to = "Strain_Rep", values_to = "GFP")%>%
  separate(Strain_Rep, sep = "_", into = c("Strain", "Replicate"))%>% # Separate into Strain and Replicate
  select(-Time) # Remove the ugly "time" values - we'll use the ones from the OD dataframe

# Combining OD and GFP data
combined <- clean_data_od%>% 
  inner_join(clean_data_gfp)%>% # Let's combine our data with a join
  select(-TimePoint) # We don't need this anymore, so let's keep our dataframe tidy

# Working with "blanks"
blank_data <- combined%>%
  filter(Strain=="S3")%>% # Select strain 3 (my "blank")
  select(Time, Replicate, OD, GFP)%>% # Select just the timepoint, the replicate, and our measurements
  rename(Blank_OD = OD, Blank_GFP = GFP) # Rename so we know this is the blanks

# Calculating blanked RFUs
combined_and_blanked <- combined%>%
  filter(Strain!="S3")%>% # Now let's get rid of our blank (unless you want to plot it in the end)
  left_join(blank_data)%>% # Let's join in our blank data. It will join by time and replicate
  mutate(OD_Blanked = OD - Blank_OD,
         GFP_Blanked = GFP - Blank_GFP,
         RFUs = GFP_Blanked / OD_Blanked) # And let's calculate our blanked GFP_OD

# Let's see what timepoints look like they are in log phase
combined_and_blanked%>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain))+
  geom_point()+
  scale_y_continuous(trans = "log2")


# Calculating doubling times
doubling_times <- combined_and_blanked%>%
  filter(Time < 4)%>% # Limit to data to log phase
  nest_by(Strain, Replicate, .key = "growth_df")%>% # Nest, so that we have little mini dataframes for each strain and replicate
  mutate(models = list(lm(log2(OD_Blanked) ~ Time, data = growth_df)), # Run a linear model to calculate the slope for log2 of OD versus Time
         slope = models$coefficients[2], # Extract the slope from the coefficients
         r_square = summary(models)$adj.r.squared, # See the adjusted r squared
         doubling_time_hr = 1 / slope, # Calculate doubling time
         doubling_time_min = doubling_time_hr * 60) # Convert to minutes