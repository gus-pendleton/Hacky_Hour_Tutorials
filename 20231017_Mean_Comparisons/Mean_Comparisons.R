# First, make sure that you've opened up the 20231017_Mean_Comparisons.rpoj file (it should)
# say that in the upper right-hand corner of your RStudio window

# Let's start by loading packages we'll need for the tutorial. I'm going to use functions
# from multiple tidyverse packages, so I'll start there.

library(tidyverse)

# Next, let's read in our first datasheet

rigidity <- read_csv("data/Membrane_Rigidity.csv")

# And take a look

glimpse(rigidity)


# We have two variables: Strain and Membrane Rigidity. 
# Strain has two groups, WT (wildtype) and lpdA (the gene lpdA was deleted)
# We want to test whether the strain
# background leads to significantly different membrane rigidity. 

# Briefly, Strain is coded as a character in R right now, but because we will use it as 
# a categorical group, we should code it as a factor

rigidity_fct <- mutate(rigidity, Strain = factor(Strain, levels  = c("WT","lpdA")))

# Now let's run a two-sample t-test. 

# t-tests are used to compare the means between two groups. Note, t-tests (and all statistical tests)
# are only valid under certain assumptions such as independence, normality, etc. 
# I'm not saying these data necessarily fit these assumptions, but we'll use them to learn
# the techniques and code necessary to run these tests. 

# Base R has a t-test function already
# First, I provide a formula where the left-hand side is our dependent variable, while our
# left-hand side is our independent variable. 
# The data argument specifies which dataframe to use
# And our alternative hypothesis specifies that we are doing a two-sided t-test.
# This means we testing whether the means differ in EITHER direction (WT could be higher OR lower than lpdA)

t.test(Membrane_Rigidity~Strain, data = rigidity_fct, alternative = "two.sided")

# What do we see from this output?
# First, the hypothesis we are testing is "true difference in means between group lpdA and group WT is not equal to 0"
# Second, we see our p-value is 1.67x10^-6 -> very small!
# This is the probability that we would observe the data we did observe (our dataframe)
# if the difference in means between WT and lpdA WAS 0
# So this means that given the data observed, it's very unlikely that the populations of
# WT and lpdA have the same average Membrane Rigidity!

# We also have a 95% confidence interval for the true difference in means, and it kindly
# calculated the means in each group for us. 

# If we wanted to save or pull out pieces of this information to use later, we can do that
# by saving our test as an object.

rigid_t <- t.test(Membrane_Rigidity~Strain, data = rigidity_fct, alternative = "two.sided")

# That way, we can access specific pieces of the test.
rigid_t$p.value # Get the p-value
rigid_t$conf.int # Get that confidence interval


# NEXT-UP: ANOVAs

# What if we have more than two groups?

anteiso <- read_csv("data/Anteiso_Concentrations.csv")

glimpse(anteiso)

# Now, I have three groups, because I tested the percentage of anteiso fatty acids in 
# the membranes of three different mutants. 

# Let's save those as factors (this will also help us with plotting later!)

anteiso_fct <- mutate(anteiso, Strain = factor(Strain, levels = c("WT","codY","lpdA")))

# Now, instead of one comparison between WT and lpdA, we have three to make; 
# WT : codY
# WT : lpdA
# lpdA: codY

# Yes, we could run three t-tests for each comparison. 
# But every time we run a t-test, we risk making a type 1 error, which is a false positive
# The more groups we have, the more comparisons there are, and the higher our chances of 
# seeing a significant difference, even where one doesn't exist.
# And because our cut-off is p < 0.05, if we ran 100 comparisons, we would expect at least 5 
# of them to be false positives, purely by chance. 

# This means that when we run "multiple comparisons", we need a way to make sure
# we're not seeing positive results, purely by chance. 

# The first way we can do that, is by using an ANOVA (ANalysis Of VAriance)

# Our ANOVA will first look at our entire dataframe, and from a birds-eye perspective,
# tell us if at least some of the groups look like they might be significantly different.
# This gives us "permission" to then do pairwise comparisons. 

# Let's run an anova, to see whether there are significant differences between at least
# two groups in our data

# Again, we'll use formula notation ot identify our dependent and independent variables
anteiso_aov <- aov(Percent_anteiso~Strain, data = anteiso_fct)

summary(anteiso_aov)

# As microbiologists, the only output we probably care about is the p-value. 
# This is the last column (Pr(>F)), and equals 1.04x10^-6 - def less than 0.05
# We can pull it out directly from the object as well, but it's kinda a pain in the butt

summary(anteiso_aov)[[1]]$'Pr(>F)'

# So instead, I like to use the package "broom" to tidy up any statistical test in R

library(broom)

broom::tidy(anteiso_aov)

# Which gives me a lovely dataframe

# It works on t-tests too!

broom::tidy(rigid_t)

# OKAY! So our ANOVA tells us that at least two groups have different means for their 
# Percent_anteiso. Now we need to do pairwise tests to figure out which ones. 

# These are called "post-hoc" tests, which means you only do them after another test. 
# In our case, our ANOVA gave us permission to do a post-hoc test to calculate
# pairwise comparisons. 

# There are many post-hoc tests, but the one you will likely see most often is 
# Tukey Test/Tukey Post Hoc Test/Tukey Honest Significant Difference (TukeyHSD)

# To run a tukey test, we'll feed in our ANOVA object directly

TukeyHSD(anteiso_aov)

# What we see is each row is a comparison between two groups, the difference in their means, 
# the lower and upper confidence interval for the "true" difference, and the p-value

# You can also "tidy" up tukey results!

TukeyHSD(anteiso_aov) %>%
  broom::tidy()

# All of our adjusted p values (adj.p.value) are <0.05, so we can conclude that 
# there are significant differences between all three groups

# FINALLY - plotting! I still think it's good practice to know how to run these tests
# on their own. All of these functions are incredibly flexible and have many arguments 
# that will subtly change your outputs and can accomodate more advanced, multivariate tests. 

# That said, sometimes it's easier to calculate these tests on the fly at the same time
# that we plot our data, if you're mostly just following the defaults. 

# For that, we'll need to use the ggpubr package

library(ggpubr)

# Let's start with our two-sample comparison
rigidity_fct %>%
  ggplot(aes(x = Strain, y = Membrane_Rigidity)) + # Define our axes
  geom_jitter(width = .1) +  # Plot points with some narrow jitter
  ggpubr::stat_compare_means(method = "t.test")

# Hmm, that's okay, but usually we do this with brackets
# For that, we need to list each of the comparisons we want to make

rigidity_fct %>%
  ggplot(aes(x = Strain, y = Membrane_Rigidity)) + # Define our axes
  geom_jitter(width = .1) +  # Plot points with some narrow jitter
  ggpubr::stat_compare_means(method = "t.test", comparisons = list(c("WT","lpdA")))

# Okay, what if we want to do multiple comparisons? 

# First, we can put on our ANOVA test results
anteiso_fct %>%
  ggplot(aes(x = Strain, y = Percent_anteiso)) + 
  geom_point() + 
  ggpubr::stat_compare_means(method = "anova")

# Adding Tukey results is a little more complicated, as we do it semi-manually
# The best way to do this is to use Tukey results from the rstatix package, which 
# is slightly different than the tidy results from broom (it's personal preference)

library(rstatix)

tukey_results <- tukey_hsd(anteiso_aov)

# And we add the p-values manually using ggpubr

anteiso_fct %>%
  ggplot(aes(x = Strain, y = Percent_anteiso)) + 
  geom_point() + 
  ggpubr::stat_compare_means(method = "anova") + 
  ggpubr::stat_pvalue_manual(tukey_results, label = "p.adj",
                             y.position = c(35,40,45))

# We could also just use significance codes

anteiso_fct %>%
  ggplot(aes(x = Strain, y = Percent_anteiso)) + 
  geom_point() + 
  ggpubr::stat_compare_means(method = "anova") + 
  ggpubr::stat_pvalue_manual(tukey_results, label = "p.adj.signif",
                             y.position = c(35,40,45))

# Finally, let's make both of these plots publication quality, just for the thrill of 
# ggplotting

rigidity_fct %>%
  ggplot(aes(x = Strain, y = Membrane_Rigidity, color = Strain)) + # Define our axes 
  stat_summary(geom = "errorbar", width = 0.4, linewidth = 1.5, alpha = 0.8,
               fun.min = mean, fun.max = mean) + 
  stat_summary(geom = "errorbar", width = 0.2, alpha = 0.8,
               fun.min = \(x)mean(x) - sd(x),
               fun.max = \(x)mean(x) + sd(x))+
  geom_jitter(width = .1, alpha = 0.8) +  # Plot points with some narrow jitter
  ggpubr::stat_compare_means(method = "t.test", comparisons = list(c("WT","lpdA"))) + 
  labs(y = "Relative Membrane Rigidity") + 
  scale_color_manual(values = c("#0848a3","#F69200")) + 
  theme_classic() + 
  theme(legend.position = "none")

anteiso_fct %>%
  ggplot(aes(x = Strain, y = Percent_anteiso, color = Strain)) + 
  stat_summary(geom = "errorbar", width = 0.4, linewidth = 1.5, alpha = 0.8,
               fun.min = mean, fun.max = mean) + 
  stat_summary(geom = "errorbar", width = 0.2, alpha = 0.8,
               fun.min = \(x)mean(x) - sd(x),
               fun.max = \(x)mean(x) + sd(x))+
  geom_jitter(width = .1, alpha = 0.8) +  # Plot points with some narrow jitter
  ggpubr::stat_compare_means(method = "anova") + 
  ggpubr::stat_pvalue_manual(tukey_results, label = "p.adj.signif",
                             y.position = c(35,40,45)) + 
  labs(y = "Anteiso Membrane Lipids (%)") + 
  scale_color_manual(values = c("#0848a3","#FF8CC2","#F69200")) +
  theme_classic() + 
  theme(legend.position = "none")


