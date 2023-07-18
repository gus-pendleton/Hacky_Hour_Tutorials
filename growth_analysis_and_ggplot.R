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

# GGPLOT TUTORIAL BEGINS HERE

# ggplot requires data in long format
growth_data # Wide format

clean_data_od # Long format

ggplot(growth_data, aes(x = Time, y = S1_1))+
  geom_point()
ggplot(growth_data, aes(x = Time, y = S1_2))+
  geom_point()

# With wide format data, we can only plot a single series at a time

# With long format data, we can plot all of them

ggplot(clean_data_od, aes(x = Time, y = OD))+
  geom_point()

# aes() specifies how data from our dataframe is controlling the plot

ggplot(clean_data_od, aes(x = Time, y = OD, color = Strain))

# But a ggplot is nothing without a geom

ggplot(clean_data_od, aes(x = Time, y = OD, color = Strain)) + 
  geom_point()


# We can use different geoms for different types of data
ggplot(clean_data_od, aes(x = Time, y = OD, color = Strain)) + 
  geom_point()

ggplot(doubling_times, aes(x = Strain, y = doubling_time_min))+
  geom_boxplot()

# And we can stack geoms
ggplot(doubling_times, aes(x = Strain, y = doubling_time_min)) +
  geom_boxplot() + 
  geom_point()
# Notice how we add layers to our ggplots using +, not the pipe (%>%)

# We can control geom aesthetics either dependent or independent of the data

ggplot(doubling_times, aes(x = Strain, y = doubling_time_min)) +
 geom_point(color = "black", fill = "blue", size = 5, alpha = 0.5, shape = 21)

ggplot(doubling_times, aes(x = Strain, y = doubling_time_min)) +
  geom_point(aes(color = Replicate)) # Notice how we map color to a column of our dataframe in aes()

# Let's start building our growth curve

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) +
  geom_point() 

# That's a start. Let's use scales to change the way our aes() is being interpreted

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) +
  geom_point() +
  scale_y_continuous(trans = "log2") + # Change the y axis to log2 scale
  scale_color_manual(values = c("thistle", "turquoise")) + # Change the color scale (which we mapped to strain)
  scale_x_continuous(limits = c(0,4)) # Change the limits on the x axis

# Let's plot aggregated data, using a dplyr approach and a ggplot approach

# dplyr approach

combined_and_blanked %>%
  group_by(Strain, Time) %>%
  summarize(mean = mean(OD_Blanked), # Calculate the mean OD at each timepoint for each strain
            sd = sd(OD_Blanked),
            lower = mean - sd,
            upper = mean + sd) %>% # Calculate mean +/- standard deviation (sd) for our error bars
  ggplot(aes(x = Time, y = mean, color = Strain)) + 
  geom_point(size = 2) + # Add in points
  geom_line() + # Add in lines connecting the points
  geom_errorbar(aes(ymin = lower, ymax = upper), width = .25) # Add in error bars


combined_and_blanked %>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain)) + 
  stat_summary(geom = "point", fun = mean) + # Calculate the mean for each timepoint, and plot it as a point
  stat_summary(geom = "line", fun = mean) + # Calculate the mean for each timepoint, and plot it as a line
  stat_summary(geom = "errorbar", width = 0.25,
               fun.min = \(x)mean(x) - sd(x), # Calculate mean - sd for each timepoint, and plot it as the lower errorbar
               fun.max = \(x)mean(x) + sd(x)) # Calculate mean + sd for each timepoint, and plot it as the upper errorbar

# The \(x) notation is defining an "anonymous function", which can be translated as "for each strain at each timepoint, take the data we have (x) and do these things to it
# This notation is from relatively recent versions of R - you may need to use a notation that looks like this:
combined_and_blanked %>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain)) + 
  stat_summary(geom = "point", fun = mean) + # Calculate the mean for each timepoint, and plot it as a point
  stat_summary(geom = "line", fun = mean) + # Calculate the mean for each timepoint, and plot it as a line
  stat_summary(geom = "errorbar", width = 0.25,
               fun.min = function(x)mean(x) - sd(x), # Calculate mean - sd for each timepoint, and plot it as the lower errorbar
               fun.max = function(x)mean(x) + sd(x))


# And we can separate data using facets

combined_and_blanked %>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  facet_wrap(~Strain) # Facet by Strain. It will just take a guess how you want the plots arranged

combined_and_blanked %>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  facet_wrap(~Strain, scales = "free_y") # Specify that the y axes can be different between facets.

combined_and_blanked %>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  facet_grid(rows = vars(Strain), cols = vars(Replicate)) # Facet, bt specify which variables should separate the data into rows and columns of plots


# That was great! Let's build our good plot that we'll want to show off

baseline_plot <- combined_and_blanked %>%
  ggplot(aes(x = Time, y = OD_Blanked, color = Strain)) + 
  stat_summary(geom = "point", fun = mean) + 
  stat_summary(geom = "line", fun = mean) + 
  stat_summary(geom = "errorbar", width = 0.25,
               fun.min = \(x)mean(x) - sd(x),
               fun.max = \(x)mean(x) + sd(x)) + 
  geom_jitter(alpha = 0.3, width = 0.2) + # Add in our actual datapoints, but make them light so they aren't too distracting
  scale_y_continuous(trans = "log2") + 
  scale_color_manual(values = c("#0848a3","#F69200"))

# Do we feel good about this? It's functional - it shows all the data we need.
# But shouldn't things also be pretty?

# We can control all of the dressing on our ggplot to make it more visuallu appealing
baseline_plot + 
  labs(x = "Time (hrs)", y = "Optical Density") + # Change axis labels
  theme(axis.line = element_line(color = "black"), # Make our axis lines black
        axis.text = element_text(size = 10), # Make our axis text bigger
        axis.title = element_text(size = 12), # Make our axis titles bigger
        legend.text = element_text(size = 10), # Make our legend text bigger
        legend.title = element_text(size = 12), # Make our legend title bigger
        panel.background = element_rect(fill = "white"), # Change the plot background to white, instead of grey
        panel.grid.major = element_line(color = "grey80")) # Add in grey gridlines

# We can also use ready-made themes

baseline_plot + 
  theme_classic()

# I need to load the package ggprism to get this prism-looking theme
library(ggprism)
baseline_plot + 
  theme_prism()

# Finally, we can save ggplots with ggsave

final_plot <- baseline_plot + 
  labs(x = "Time (hrs)", y = "Optical Density") + 
  theme(axis.line = element_line(color = "black"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 12),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "grey80"))

ggsave(final_plot, filename = "Exported_GC.png", width = 5, height = 3, 
       units = "in", dpi = 300)

# Everytime you edit this plot and run this script, you re-save the file with your updated work
# And you can rest easy knowing your resolution is as high as journal requirements!

# There is way more you can do with ggplot - I really mean it when I say everything
# it fully customizable. Ggplot is also all about googling - more than anythihg else,
# I am constantly looking stuff up when I'm plotting. 

# If you want to challenge yourself, go ahead and try and make a corresponding plot
# with our RFUs. In what ways will this plot be the same, and in what ways will it be different?




