# Loading our libraries
library(ggtree)
library(ggtreeExtra)
library(ggstar)
library(ggnewscale)
library(phyloseq)
library(TDbook)
library(tidyverse)
library(tidytree)

# Hypothetical syntax reading in a tree

# read.beast()
# read.tree()
# read.mega()

# How to make different shapes of a tree

set.seed(11-21-2023)

# Make random tree with 50 tips
tree_shape <- rtree(50)

# Make tree outputs

ggtree(tree_shape)

ggtree(tree_shape, layout = "slanted")

ggtree(tree_shape, layout = "circular")

ggtree(tree_shape, layout = "fan", open.angle = 0)

ggtree(tree_shape, layout = "equal_angle")

ggtree(tree_shape, branch.length = "none", layout = "circular")

# Let's get into a tutorial

# We will use ggtreeExtra to create an abundance ring around our tree

# Load in data from phyloseq

data("GlobalPatterns")

# Create a variable of the data frame
gp <- GlobalPatterns

# We can "prune" our taxa

gp <- prune_taxa(taxa_sums(gp) > 600, gp)

# Finding only human sources

sample_data(gp)$human <- get_variable(gp, "SampleType") %in% c("Feces", "Skin")

sample_data(gp)


# Create a new variable called mergeGP where we will merge our samples

# We will merge them based on the variable of our dataframe and the column sample tpe

mergedGP <- merge_samples(gp, "SampleType")

# tax_glom agglomerates species that have the same taxonomy at a certain taxonomic rank

mergedGP <- tax_glom(mergedGP, "Order")

mergedGP

# Now we will melt our phyloseq data object into a large data frame

melt_simple <- psmelt(mergedGP)  %>% 
  filter(Abundance < 120) %>%
  select(OTU, val=Abundance)

# This uses fan but you can do anything you want

p <- ggtree(mergedGP, layout = "fan", open.angle = 10) + 
  geom_tippoint(mapping = aes(color = Phylum),
                size = 1.5, 
                show.legend = FALSE)

p <- rotate_tree(p, -90)
p

p1 <- p + geom_fruit(
  data = melt_simple,
  geom = geom_boxplot,
  mapping = aes(y = OTU, x = val, group = label,
                fill = Phylum), size = 0.2, 
  outlier.size = 0.5, 
  outlier.stroke = 0.08,
  outlier.shape = 21,
  axis.params = list(
    axis = "x",
    text.size = 1.8,
    hjust = 1,
    vjust = 0.5,
    nbreak = 3
  ),
  grid.params = list(
    
  )
)

p2 <- p1 + 
  scale_fill_discrete(
    name = "Phyla", 
    guide = guide_legend(keywidth = 0.8, keyheight = 0.8, ncol = 1)
  ) + 
  theme(
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 7)
  )
p2

# Making a heatmap

# Load TDbook which has our data

tree <- tree_hmptree

tree

dat1 <- df_tippoint

dat1

dat2 <- df_ring_heatmap

dat3 <- df_barplot_attr

# Adjust the order of the levels in our dataframe

dat2$Sites <- factor(dat2$Sites, levels = c("Stool (prevalence)",
                                            "Cheek (prevalence)",
                                            "Plaque (prevalence)",
                                            "Tongue (prevalence)",
                                            "Nose (prevalence)",
                                            "Vagina (prevalence)",
                                            "Skin (prevalence)"))


dat3$Sites <- factor(dat3$Sites, levels = c("Stool (prevalence)",
                                            "Cheek (prevalence)",
                                            "Plaque (prevalence)",
                                            "Tongue (prevalence)",
                                            "Nose (prevalence)",
                                            "Vagina (prevalence)",
                                            "Skin (prevalence)"))
# Now we get the clade information
nodeids <- nodeid(tree, tree$node.label[nchar(tree$node.label) > 4])

nodedf <- data.frame(node = nodeids)

nodedf

nodelab <- gsub("[\\.0-9]", "", tree$node.label[nchar(tree$node.label) > 4])
tree$node.label


# Making layers of the clade and highlighting

poslist <- c(1.6, 1.4, 1.6, 0.8, 0.1, 0.25, 1.6, 1.6, 1.2, 0.4, 1.2, 1.8, 0.3, 0.8, 0.4, 
             0.3, 0.4, 0.4, 0.4, 0.6, 0.3, 0.4, 0.3)

labdf <- data.frame(node = nodeids,
                    label = nodelab,
                    pos = poslist)

# Now we make the tree

p3 <- ggtree(tree, layout = "rectangular", size = 0.15) + 
  geom_highlight(data = nodedf, 
                 mapping = aes(node = node),
                 extendto = 6.8, alpha = 0.3, fill = "grey", color = "grey50",
                 size = 0.05
                 ) + 
  geom_cladelab(data = labdf, 
                mapping = aes(node = node, label = label, offset.text = pos),
                hjust = 0.5, barsize = NA, 
                horizontal = FALSE, fontsize = 3, fontface = "italic")
  

p3

# We can add shapes to our tree

p4 <- p3 %<+% dat1 + geom_star(
  mapping=aes(fill=Phylum, starshape=Type, size=Size),
  position="identity",starstroke=0.1) +
  scale_fill_manual(values=c("#FFC125","#87CEFA","#7B68EE","#808080",
                             "#800080", "#9ACD32","#D15FEE","#FFC0CB",
                             "#EE6A50","#8DEEEE", "#006400","#800000",
                             "#B0171F","#191970"),
                    guide=guide_legend(keywidth = 0.5, 
                                       keyheight = 0.5, order=1,
                                       override.aes=list(starshape=15)),
                    na.translate=FALSE)+
  scale_starshape_manual(values=c(15, 1),
                         guide=guide_legend(keywidth = 0.5, 
                                            keyheight = 0.5, order=2),
                         na.translate=FALSE)+
  scale_size_continuous(range = c(1, 2.5),
                        guide = guide_legend(keywidth = 0.5, 
                                             keyheight = 0.5, order=3,
                                             override.aes=list(starshape=15)))
p4
p5 <- p4 + 
  new_scale_fill() + 
  geom_fruit(data = dat2, geom = geom_tile, 
             mapping = aes(y = ID, x = Sites, alpha = Abundance, fill = Sites),
             color = "grey50", offset = 0.04, size = 0.02) + 
  scale_alpha_continuous(range = c(0,1), guide = guide_legend(keywidth = 0.3, keyheight = 0.3, order = 5)) + 
  geom_fruit(data = dat3, geom = geom_bar, 
                         mapping = aes(y = ID, x = HigherAbundance, fill = Sites),
                         pwidth = 0.38, orientation = "y", stat = "identity",
             ) + 
    scale_fill_manual(values = c("#FFC125","#87CEFA","#7B68EE","#808080",
                                 "#800080", "#9ACD32","#D15FEE"))