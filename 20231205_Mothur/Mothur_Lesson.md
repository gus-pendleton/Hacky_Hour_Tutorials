---
title: "Mothur Workflow" 
author: "Sophia Richter"
date: "01 December, 2023"
output:
  html_document:
    code_folding: show
    highlight: default
    keep_md: yes
    theme: journal
    toc: yes
    toc_float:
      collapsed: no
      smooth_scroll: yes
      toc_depth: 3
editor_options: 
  chunk_output_type: console
---
<style>
pre code, pre, code {
  white-space: pre !important;
  overflow-x: scroll !important;
  word-break: keep-all !important;
  word-wrap: initial !important;
}
</style>




# Introduction

What is Mothur? 

- bioinformatics tool to analyze 16S rRNA gene sequences

Example data set: 

- Pat Schloss's lab has an example dataset on microbial communities sequenced from mouse feces over time
- 5 samples from early in life and 5 from late in life
- V4 region sequences each 250 bp long (forward R1 and reverse R2)

What you need for the tutorial: 

- latest version of mothur
- example data
- SILVA reference database for alignment
- RDP training set

I have included the example data and RDP training set we will work with. You will need to download the silva.bacteria reference databse yourself from the SOP site and add the files to the folder you will be working out of.

We will be following the MiSeq SOP tutorial provided by Mothur: https://mothur.org/wiki/miseq_sop/ 


# Downloading mothur 

If you are not working from BioHPC:

Go to https://github.com/mothur/mothur/releases/tag/v1.48.0

Download the mothur.zip that matches your processor (e.g. if you are a Mac user download Mothur.OSX-10.14.zip). You do not need the version with ".tools".

Move your data files to this directory.

Open the mothur file by double-clicking on it, or in your terminal navigate to that folder and type in ./mothur (mac/linux) or mothur.exe (windows). 

Note: If you are on Mac, you may need to go to security and privacy settings to allow installation. 

This should take you to a terminal window with mothur started.

If you are working from BioHPC: 

- Navigate to the directory with your data
- add mothur to your path and reduce processors used to not overload the system


```bash
/programs/mothur/mothur
set.current(processors=30)
```


# Getting Started in Mothur

First we need to tell Mothur what files we are working with. 

- Indicate input directory (. if from command line, mothurhome if doubleclicked)
- type of file (e.g. fastq or gz if zipped). 
- Prefix indicates the unique file name before a certain character. Default is "_"


```bash
mothur > make.file(inputdir=., type=fastq, prefix=stability)
```


Take a look at the file called stability.files. What does it contain? 

- file with three columns: sample name, forward, and reverse reads

Next, we will combine the forward and reverse reads for each sample. Mothur does this early in the process - if you are working with QIME or DADA2 it may happen later. After aligning, this command will identify positions where the two reads disagree and replace it with the higher quality base if the quality score is high enough, and with an N if not. 


```bash
mothur > make.contigs(file=stability.files)
```

This command also generates stability.trim.contigs.fasta, containing sequence data, and stability.contigs.count_table, containing the group identify for each sequence. You should also get a total # of sequences. How many did you get? (A: 147581)

Let's look at the quality of the sequences after aligning. 


```bash
mothur > summary.seqs(fasta=stability.trim.contigs.fasta, count=stability.contigs.count_table)
```


How can we interpret this? 

- provides quantiles for each parameter: start and end, NBases (total bases), Ambigs (number of N/ambiguous bases per sequence), polymer (same nucleotide repeated)
- NumSeqs provides the number of sequences that each quantile adds to the previous quantile

What are some red flags we see? (A: Ambigs in 2.5% sequences, max length 502 - what happened?)

With screen.seqs we can remove these low-quality sequences. Think about what parameters you want to use. 

- maxambig: number of Ns allowed per sequence. Mothur highly recommends =0
- maxlength, minlength should cover at least 75% of your data - the longer the read the poorer it aligned!
- maxhomop: number of allowed same nucleotides in a row


```bash
mothur > screen.seqs(fasta=stability.trim.contigs.fasta, count=stability.contigs.count_table, maxambig=0, maxlength=275, maxhomop=8)
```

How many sequences did screen.seqs remove? What percent? (A: 22849/147581 = 15%)

Let's take a look at the sequences again - it is always good to use summary.seqs as a sanity check. Note you can also use fasta=current and/or count=current.


```bash
mothur > summary.seqs(fasta=stability.trim.contigs.good.fasta, count=stability.contigs.good.count_table)
```

Were the sequences correctly screened? 
Bonus: Try re-running screen.seqs() and summary.seqs() with different parameters. How many sequences are removed when you lower maxambig? increase maxlength?


# Processing Sequences

Next we are going to align the sequences against the SILVA database to get taxonomy. Because we expect many of the sequences are duplicates, we are only going to work with unique sequences for this step. 


```bash
mothur > unique.seqs(fasta=stability.trim.contigs.good.fasta, count=stability.contigs.good.count_table)
```



We can also look at summary.seqs to see how many unique sequences we have. (Under # of unique seqs: and total # of seqs:)


```bash
mothur > summary.seqs(count=stability.trim.contigs.good.count_table)
```

How many unique sequences do we have? (A: 15,915 of 124,732)

Next we will run the pcr.seqs command to create a database customized to our region of interest. You will need to know where in the SILVA alignment your sequences start and end or using your primers.

This example runs on the V4 region with primers. 


```bash
mothur > pcr.seqs(fasta=silva.bacteria.fasta, start=11895, end=25318, keepdots=F)
```



You can also rename the file for easier reference and take a look at it 


```bash
mothur > rename.file(input=silva.bacteria.pcr.fasta, new=silva.v4.fasta)

# and take a look!
mothur > summary.seqs(fasta=silva.v4.fasta)
```

How many sequences were 'summarized'? What does this mean? What are the lengths of these sequences? Why are they different from our actual sequences? 
(A: this database includes primers)

Now we are going to align the sequences against the SILVA database. 


```bash
mothur > align.seqs(fasta=stability.trim.contigs.good.unique.fasta, reference=silva.v4.fasta)
```

How many sequences aligned? 
(A: All of them)

Note: with lower quality data, you may receive a notification that some sequences were 'flipped' to align, and other "sequences generated alignments that eliminated too many bases" (AKA these did not align).

And take a look: 

```bash
mothur > summary.seqs(fasta=stability.trim.contigs.good.unique.align, count=stability.trim.contigs.good.count_table)
```



To make sure that everything overlaps the same region we’ll re-run screen.seqs to get sequences that start and end with the majority. In this example, we will set sequences to start at or before position 1968 and end at or after position 11550. (shorter or longer sequences are likely due to an insertion/deletion or non-specific amplification)


```bash
mothur > screen.seqs(fasta=stability.trim.contigs.good.unique.align, count=stability.trim.contigs.good.count_table, start=1968, end=11550)

# take a look
mothur > summary.seqs(fasta=current, count=current)
```

What do we see? What are the min and max of the new summary.seqs()? (A: max start is now 1968, min end is now 11550)


Next we can filter the sequences to remove overhangs and gap characters in alignment (e.g. "-") using trump=. and vertical=T


```bash
mothur > filter.seqs(fasta=stability.trim.contigs.good.unique.good.align, vertical=T, trump=.)
```

How do we interpret the output? 

- Length of filtered alignment: final alignment length/columns
- Number of columns removed: from removing gap characters
- Length of the original alignment: original width of alignment
- Number of sequences used to construct filter: unique sequences used for alignment


This can create a couple duplicates, so we will run unique.seqs again


```bash
mothur > unique.seqs(fasta=stability.trim.contigs.good.unique.good.filter.fasta, count=stability.trim.contigs.good.good.count_table)
```

Did it remove any duplicates? (A: no)


And then we will cluster sequences that are extremely similar. If two sequences are similarly abundant and have only 1 difference for every 100 bp of sequence (recommended) then they get merged. For 251 bp that difference would be diffs=2.


```bash
mothur > pre.cluster(fasta=stability.trim.contigs.good.unique.good.filter.unique.fasta, count=stability.trim.contigs.good.unique.good.filter.count_table, diffs=2)
```

How many unique sequences do we have post-clustering? (A: 5975)

Next let's remove chimeras! 
- dereplicate=T only removes a sequence if it is chimeric in all samples.
- this command will also remove the chimeras from your original fasta files


```bash
mothur > chimera.vsearch(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.count_table, dereplicate=t)

# and take a look
mothur > summary.seqs(fasta=current, count=current)

```

How many chimeras were removed? (A: 3533 UNIQUE SEQUENCES) 
What percent of total sequences were removed? (A: 1 - (114,117 / 124,531) = 0.08363)
Should we be concerned by that number? (A: no)


Note: if chimera.vsearch removes more than 10-20% of your sequences, there may be a problem.


Next let's remove all of the unwanted sequences that may have been accidentally amplified (e.g. 18s fragments, mitochondria, chloroplasts, unknown taxa). We can identify them with the trainset provided by Mothur.


```bash
mothur > classify.seqs(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.count_table, reference=trainset9_032012.pds.fasta, taxonomy=trainset9_032012.pds.tax)
```



And then we can remove them with remove.lineage() and update the taxonomy file.

```bash
mothur > remove.lineage(fasta=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.fasta, count=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.count_table, taxonomy=stability.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pds.wang.taxonomy, taxon=Chloroplast-Mitochondria-unknown-Archaea-Eukaryota)

# look at sequences
summary.seqs(count=current)

# Update taxonomy file
mothur > summary.tax(taxonomy=current, count=current)
```

How many sequences were removed? (A: 114,117 - 113955 = 162)
Unique sequences? (A: 0)



If you are working with a mock community, you can assess error rates with Mothur. The example tutorial provides a mock community but I am going to skip that section because not everyone sequences a mock community. 



# Prep Analysis

Let's rename the current file to our final file. 

```bash
mothur > rename.file(fasta=current, count=current, taxonomy=current, prefix=final)
```


Then we are going to assign sequences to OTUs, ASVs, and phylotypes.

To assign OTUs, you have two options. We are going to do the easier option because we have a small dataset: 


```bash
mothur > dist.seqs(fasta=final.fasta, cutoff=0.03)
mothur > cluster(column=final.dist, count=final.count_table)
```


You could also use cluster.split() to bin the sequences.

Next we will run commands to know how many sequences are in each OTU from each group and the taxonomy with classify.otu().


```bash
mothur > make.shared(list=final.opti_mcc.list, count=final.count_table, label=0.03)

mothur > classify.otu(list=final.opti_mcc.list, count=final.count_table, taxonomy=final.taxonomy, label=0.03)
```



Let's open final.opti_mcc.0.03.cons.taxonomy to look at the taxonomy assignments. 
- OTU, size (# sequences), and taxonomy (parenthesis indicate percent sequences classified as that phylum/family/etc. in that OTU)

If you would like, you can also classify the sequences as ASVs or phylotypes. We are going to skip that and just use OTUs. 


# Create a Phylogenetic Tree (optional)


```bash
mothur > dist.seqs(fasta=final.fasta, output=lt)
mothur > clearcut(phylip=final.phylip.dist)
```



# Analysis

We can look at the number of sequences in each sample with 


```bash
mothur > count.groups(shared=final.opti_mcc.shared)
```


We can also subsample and rarefy our data with. Set size to the minimum size of your samples (in this example, size of smallest group is 2403). 


```bash
mothur > sub.sample(shared=final.opti_mcc.shared, size=2403)
```


In Mothur, you can create plots and calculate measurements related to alpha diversity, beta diversity, PCOA and NMDS, etc. if you continue on with the SOP.

I find it is a bit more workable to take your final files from Mothur and input them into R to create these plots and manipulate the data. This will allow you more flexibility to create the graphs exactly as you want them. 

You can use the import_mothur() function from the phyloseq package to import the files you want to create a phyloseq object. 

Converting mothur to phyloseq tutorial: https://norwegianveterinaryinstitute.github.io/BioinfTraining/phyloseq_tutorial.html

Note: you will need to edit the tree before you can input it into R (follow the tutorial)

Example code (but with your correct file names): 


```bash
# Assign variables for imported data
sharedfile= "final.opti_mcc.0.03.subsample.shared"
taxfile= "final.opti_mcc.0.03.cons.taxonomy"
treefile= "final.phylip.tre"
mapfile= "mouse.dpw.metada"

# Import mothur data
mothur_data <- import_mothur(mothur_shared_file = sharedfile,
                             mothur_constaxonomy_file = taxfile,
                             mothur_tree_file = treefile)
```

You could also follow Pat Schloss's R tutorial to work with your data without having to create a phyloseq object: https://riffomonas.org/minimalR/


