# Today we will learn how to compare genetic neighborhoods using gene arrow maps that will highlight regions of similarity using TidyLocalSynteny

#install packages if necessary 

#load in packages
library(tidyverse)
library(ggplot2)
library(readxl)
library(RColorBrewer)


# Lets read in our data 
# What is required input?
  # 1. region tables: genomic coordinates of genes with 4 columns: chr, start, end, gene_ID
  # 2. each table should have its own region table that can be a different species, genotype, or a different region of the same genome
  # 3. attribute stable with with the following required columns: gene_ID, group, strand.
      # gene_IDs must be unique across genomes/species/accessions and match the gene_IDs in the region tables
      # group = homologous group obtained through BLASTp 

# Read in data
region1 <- read_excel("Data/ExampleRegion1.xlsx")
region2 <- read_excel("Data/ExampleRegion2.xlsx")
region3 <- read_excel("Data/ExampleRegion3.xlsx")

attributes <- read_excel("Data/ExampleAttributes1.xlsx")


# Define range and midpoint
## First lets align the regions of interest to their mid point using the following function
shift_midpoint <- function(region){
  
  colnames(region) <- c("Chr", "start", "end", "gene_ID")
  
  region %>%
    mutate(min = min(start)) %>% 
    mutate(max = max(end)) %>% 
    mutate(mid = min+(max - min)/2) %>% 
    mutate(start_new = start - mid) %>% 
    mutate(end_new = end - mid)
}

## Now lets create a dataframe for visualization

# first lets add species information to each region 
# then we will calculate new coordinates relative to the midpoints of the respective respective regions.
# next we will calculate the mid point for each gene
# depending on positive or negative strand, if + then we renamed it ">". if - we renamed it "<"
# flip start and end positions based on strandedness of genes. If a gene is on the - strand, start becomes end, and end becomes start.

my_regions <- rbind(
  region1 %>% 
    shift_midpoint() %>% 
    mutate(species = "species1"),
  
  region2 %>% 
    shift_midpoint() %>% 
    mutate(species = "species2"),
  
  region3 %>% 
    shift_midpoint() %>% 
    mutate(species = "species3")
) %>% 
  left_join(attributes, by = "gene_ID") %>% 
  mutate(gene_mid = start_new + (end_new-start_new)/2) %>% 
  mutate(
    strand.text = case_when(
      strand == "+" ~ ">",
      strand == "-" ~ "<",
      T ~ " "
    )
  ) %>% 
  mutate(group = case_when(
    is.na(group) ~ "Other",
    T ~ group
  )) %>% 
  mutate(start_strand = case_when(
    strand == "+" ~ start_new,
    strand == "-" ~ end_new,
    T ~ start_new
  )) %>% 
  mutate(end_strand = case_when(
    strand == "+" ~ end_new,
    strand == "-" ~ start_new,
    T ~ end_new
  )) 

my_regions

# Now lets visualize
my_regions %>% 
  mutate(species.f = factor(species, levels = c(
    "species1", "species2", "species3"
  ))) %>% 
  mutate(species.n = as.numeric(species.f)) %>% 
  ggplot(aes(x = gene_mid, y = species.n)) +
  geom_hline(aes(yintercept = species.n)) #geom_hline(aes(yintercept = species.n)) draws a horizontal black line for each species. +
  geom_ribbon(data = . %>%
                filter(group != "Other"),
              aes(group = group, fill = group,
                  xmin = start_strand, xmax = end_strand),
              alpha = 0.3) +
  geom_rect(aes(xmin = start_strand, xmax = end_strand, 
                ymin = species.n - 0.05, ymax = species.n + 0.05,
                fill = group)
  ) +
  geom_text(aes(label = strand.text, x = gene_mid)) +
  scale_fill_manual(values = c(brewer.pal(8, "Set2")[1:4], "grey80")) +
  scale_y_continuous(breaks = c(1, 2, 3),
                     labels = c("Species1", "Species2", "Species3")) +
  labs(fill = "Homologs") +
  theme_classic() +
  theme(axis.title = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_text(color = "black"))

# save the figure
ggsave("Figures/example1.png", height = 2, width = 4)




