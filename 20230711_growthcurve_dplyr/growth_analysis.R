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




# CODE WE WROTE DURING WORKSHOP
# Plotting with ggplot

# ggplot only accepts data in long format

growth_data

ggplot(growth_data, aes(x = Time, y = S1_1)) + 
  geom_point()

combined_and_blanked

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked)) + 
  geom_point()

# Aesthetics (aes) can be either dependent on our data, or independent

# Aesthetics independent of the data
ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked)) + 
  geom_point(color = "red", fill = "black", shape = 24, size = 5, alpha = .5)

# Aesthetic dependent on the data
ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, shape = Strain)) + 
  geom_point()

# ggplot's are based on layering

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  geom_line() + 
  geom_boxplot()


# Let's start making our nice growth curve

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point()


# Let's use scales to more accurately portray our data

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  scale_y_continuous(trans = "log2") + 
  scale_color_manual(values = c("red","black")) + 
  scale_x_continuous(limits = c(0,4))


# Let's aggregate out data, first using a dplyr approach

combined_and_blanked %>%
  group_by(Strain, Time) %>%
  summarize(mean_od = mean(OD_Blanked),
            sd = sd(OD_Blanked),
            lower = mean_od - sd,
            upper = mean_od + sd) %>%
  ggplot(aes(x = Time, y = mean_od, color = Strain)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = lower, ymax = upper), width = .25, color = "black")


# We can also do this, just in ggplot
# And we use "stat" to do so

lower <- function(data){
  mean(data) - sd(data)
}

upper <- function(data){
  mean(data) + sd(data)
}


ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  stat_summary(geom = "point", fun = mean) + 
  stat_summary(geom = "line", fun = mean) + 
  stat_summary(geom = "errorbar", width = 0.25,
               fun.min = lower,
               fun.max = upper)


# We can separate data using facets

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  facet_wrap(~Replicate)

ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  facet_wrap(~Strain, scales = "free_y")


ggplot(combined_and_blanked, aes(x = Time, y = OD_Blanked, color = Strain)) + 
  geom_point() + 
  facet_grid(rows = vars(Strain), cols = vars(Replicate))


# Let's actually make a good looking plot


baseline_plot <- combined_and_blanked %>%
  group_by(Strain, Time) %>%
  summarize(mean_od = mean(OD_Blanked),
            sd = sd(OD_Blanked),
            lower = mean_od - sd,
            upper = mean_od + sd) %>%
  ggplot(aes(x = Time, y = mean_od, color = Strain)) + 
  geom_point(size = 2) + 
  geom_line() + 
  geom_errorbar(aes(ymin = lower, ymax = upper), width = .25) + 
  scale_y_continuous(trans = "log2") + 
  scale_color_manual(values = c("#0848a3", "#F69200"), 
                     labels = c("WT",expression(Delta*italic(dakA))))

final_plot <- baseline_plot + 
  labs(x = "Time (hr)", y = expression(OD[600])) + 
  theme(axis.line = element_line(color = "black"),
        panel.background = element_rect(fill = "white"),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10),
        legend.text.align = 0,
        legend.key = element_rect(fill = "white"),
        panel.grid.major = element_line(color = "grey80"))

final_plot

# Let's save our work

ggsave(final_plot, filename = "growth_curve.png", width = 5, height = 3,
       units = "in", dpi = 300)
