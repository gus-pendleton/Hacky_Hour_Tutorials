library(tidyverse)
library(ggExtra)

horror_data <- read_csv("data/horror_movies.csv")

single_lm <- lm(revenue ~ 1, data = horror_data)

summary(single_lm)

mean(horror_data$revenue)

rvb_lm <- lm(revenue~budget, data = horror_data)

summary(rvb_lm)

median(horror_data$revenue)

# The assumptions of a linear regression model

# Independence

# Linearity

ggplot(horror_data, aes(x = budget, y = revenue)) + 
  geom_point()

# Homoscedasticity

plot(rvb_lm)

# Normality of residuals

# Lack of multicollinearity


# Trying a transformation

plot <- horror_data %>% 
  ggplot(aes(x = budget, y = revenue)) + 
  geom_point()

ggMarginal(plot, type = "histogram")


log_data <- horror_data %>%
  mutate(log.budget = log10(budget),
         log.revenue = log10(revenue))

logplot <- log_data %>%
  ggplot(aes(x = log.budget, y = log.revenue)) + 
  geom_point()

ggMarginal(logplot, type = "histogram")


log_lm <- lm(log.revenue~log.budget, data = log_data)

summary(log_lm)

plot(log_lm)


plot + 
  geom_abline(intercept = rvb_lm$coefficients[1], slope =  rvb_lm$coefficients[2])

plot + 
  geom_smooth(method = "lm", se = FALSE, color = "grey30")

plot + 
  geom_smooth(method = "lm", se = FALSE, color = "grey30", formula = y~x) + 
  ggpubr::stat_regline_equation(formula = y~x, aes(label = paste(..eq.label.., ..adj.rr.label.., sep = "~~~~~~~~~")))
