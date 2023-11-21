library(ggtreeExtra)
library(ggtree)
library(treeio)
library(tidytree)
library(ggstar)
library(ggplot2)
library(ggnewscale)
library(TDbook)
library(phyloseq)
library(dplyr)
library(tidyverse)


#starting off strong showing how to make different shapes of tree
set.seed(11-21-2023) 
tree_shape <- rtree(50)
ggtree(tree_shape) #notice that without any layout commands this is a normal rectangular tree
ggtree(tree_shape, layout="slanted") #now we have slanted
ggtree(tree_shape, layout="circular")
ggtree(tree_shape, layout="fan", open.angle=120)
ggtree(tree_shape, layout="equal_angle")
ggtree(tree_shape, branch.length='none') #noww we have rectangular tree where branch length is not taken into account
ggtree(tree_shape, branch.length='none', layout='circular') #same but in circular view
ggtree(tree_shape, layout="daylight", branch.length = 'none') #again same but daylight view

#now lets get into a tutorial 
#lets make a circular tree!
#then we will add abundance as a ring around it

#load in data from phyloseq library
data("GlobalPatterns")

#create variable of dataframe
GP <- GlobalPatterns

#now we will prune/remove taxa to get unwanted OTUs/taxa from phylogenetic objects
GP <- prune_taxa(taxa_sums(GP) > 600, GP)

#now this line of code will look for the sample data within the GP variable
#notice that it has 26 samples by 8 sample variables
#once you open the dataframe up you will see a column called human and in it, it says if it is true or false if it comes from human samples
#now it will look within the sample data to see if it matches to feces or skin and get the variable 
sample_data(GP)$human <- get_variable(GP, "SampleType") %in%
  c("Feces", "Skin")

#now we will create a new variable called mergeGP where we will merge our samples
#we will merge them based off the variable of our dataframe and the column "SampleType"
mergedGP <- merge_samples(GP, "SampleType")

#tax_glom merges/ agglomerates species that have the same taxxonomy at a certain taxonomic rank 
mergedGP <- tax_glom(mergedGP,"Order")

#now we will "melt" our phyloseq data object into a large data/frame
#we will filter out to get abundances that is < 120 and select for OTU and abundance but instead we are calling it val
melt_simple <- psmelt(mergedGP) %>%
  filter(Abundance < 120) %>%
  select(OTU, val=Abundance)

#now we can make our tree! 
#this is a fan layout but any shape could be used but i think fan looks nice
p <- ggtree(mergedGP, layout="fan", open.angle=10) + 
  geom_tippoint(mapping=aes(color=Phylum), 
                size=1.5,
                show.legend=FALSE)
p <- rotate_tree(p, -90)

p #we are leaving the figure legend out of this for right now but we will add it in a second

p1 <- p +
  geom_fruit(
    data=melt_simple,
    geom=geom_boxplot,
    mapping = aes(
      y=OTU,
      x=val,
      group=label,
      fill=Phylum,
    ),
    size=.2,
    outlier.size=0.5,
    outlier.stroke=0.08,
    outlier.shape=21,
    axis.params=list(
      axis       = "x",
      text.size  = 1.8,
      hjust      = 1,
      vjust      = 0.5,
      nbreak     = 3,
    ),
    grid.params=list() #this is to have grid parameters 
  ) 
p1

p2 <- p1 +
  scale_fill_discrete(
    name="Phyla",
    guide=guide_legend(keywidth=0.8, keyheight=0.8, ncol=1)
  ) +
  theme(
    legend.title=element_text(size=9), 
    legend.text=element_text(size=7) 
  )
p2

#if we are still feeling motivated here is how to make a heat map 

# load data from TDbook, including tree_hmptree, 
# df_tippoint (the abundance and types of microbes),
# df_ring_heatmap (the abundance of microbes at different body sites),
# and df_barplot_attr (the abundance of microbes of greatest prevalence)
tree <- tree_hmptree
dat1 <- df_tippoint
dat2 <- df_ring_heatmap
dat3 <- df_barplot_attr

# adjust the order
dat2$Sites <- factor(dat2$Sites, 
                     levels=c("Stool (prevalence)", "Cheek (prevalence)",
                              "Plaque (prevalence)","Tongue (prevalence)",
                              "Nose (prevalence)", "Vagina (prevalence)",
                              "Skin (prevalence)"))
dat3$Sites <- factor(dat3$Sites, 
                     levels=c("Stool (prevalence)", "Cheek (prevalence)",
                              "Plaque (prevalence)", "Tongue (prevalence)",
                              "Nose (prevalence)", "Vagina (prevalence)",
                              "Skin (prevalence)"))
# extract the clade label information. Because some nodes of tree are
# annotated to genera, which can be displayed with high light using ggtree.
nodeids <- nodeid(tree, tree$node.label[nchar(tree$node.label)>4])
nodedf <- data.frame(node=nodeids)
nodelab <- gsub("[\\.0-9]", "", tree$node.label[nchar(tree$node.label)>4])
# The layers of clade and hightlight
poslist <- c(1.6, 1.4, 1.6, 0.8, 0.1, 0.25, 1.6, 1.6, 1.2, 0.4,
             1.2, 1.8, 0.3, 0.8, 0.4, 0.3, 0.4, 0.4, 0.4, 0.6,
             0.3, 0.4, 0.3)
labdf <- data.frame(node=nodeids, label1=nodelab, pos=poslist)


# The circular layout tree.
p3 <- ggtree(tree, layout="fan", size=0.15, open.angle=5) +
  geom_hilight(data=nodedf, mapping=aes(node=node),
               extendto=6.8, alpha=0.3, fill="grey", color="grey50",
               size=0.05) +
  geom_cladelab(data=labdf, 
                mapping=aes(node=node, 
                            label=label1,
                            offset.text=pos),
                hjust=0.5,
                angle="auto",
                barsize=NA,
                horizontal=FALSE, 
                fontsize=1.4,
                fontface="italic"
  )
p3 #this produces the grey shading over the clades

#this is the solution to get the damn thing going in case it doesnt want to work with tidytree
deid.tbl_tree <- utils::getFromNamespace("nodeid.tbl_tree", "tidytree")
rootnode.tbl_tree <- utils::getFromNamespace("rootnode.tbl_tree", "tidytree")
offspring.tbl_tree <- utils::getFromNamespace("offspring.tbl_tree", "tidytree")
offspring.tbl_tree_item <- utils::getFromNamespace(".offspring.tbl_tree_item", "tidytree")
child.tbl_tree <- utils::getFromNamespace("child.tbl_tree", "tidytree")
parent.tbl_tree <- utils::getFromNamespace("parent.tbl_tree", "tidytree")

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

p4 <- p4 + new_scale_fill() +
  geom_fruit(data=dat2, geom=geom_tile,
             mapping=aes(y=ID, x=Sites, alpha=Abundance, fill=Sites),
             color = "grey50", offset = 0.04,size = 0.02)+
  scale_alpha_continuous(range=c(0, 1),
                         guide=guide_legend(keywidth = 0.3, 
                                            keyheight = 0.3, order=5)) +
  geom_fruit(data=dat3, geom=geom_bar,
             mapping=aes(y=ID, x=HigherAbundance, fill=Sites),
             pwidth=0.38, 
             orientation="y", 
             stat="identity",
  ) +
  scale_fill_manual(values=c("#0000FF","#FFA500","#FF0000",
                             "#800000", "#006400","#800080","#696969"),
                    guide=guide_legend(keywidth = 0.3, 
                                       keyheight = 0.3, order=4))+
  geom_treescale(fontsize=2, linesize=0.3, x=4.9, y=0.1) +
  theme(legend.position=c(0.93, 0.5),
        legend.background=element_rect(fill=NA),
        legend.title=element_text(size=6.5),
        legend.text=element_text(size=4.5),
        legend.spacing.y = unit(0.02, "cm"),
  )
p4

#ggtreeExtra also supports rectangular views
p4 + layout_rectangular() + 
  theme(legend.position=c(.05, .7))

p4



