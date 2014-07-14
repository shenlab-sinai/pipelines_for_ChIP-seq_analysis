pipelines_for_ChIP-seq_analysis
===============================

Pipelines for ChIP-seq analysis, such as peak calling, differential enrichment
detection, and pausing index calculation for PolII.

## Overview

Here are some scripts I use for the analysis of ChIP-seq, after the [preprocessing of ChIP-seq](https://github.com/shenlab-sinai/chip-seq_preprocess). So the `PROJECT`, `DATA` folders are just the same as the `ChIP-seq preprocess` pipeline.

Now the pipelines including:
+ peak calling:
  + MACS2
  + HOMER
+ differential enrichment detection:
  + diffReps
+ pausing index of PolII ChIP-seq.

## Requirement

+ [bedtools](https://github.com/arq5x/bedtools2).
+ [MACS2](https://github.com/taoliu/MACS).
+ [HOMER](http://homer.salk.edu/homer/ngs/index.html). And don't forget install the genome annotation needed for the analysis.
+ [diffReps](https://code.google.com/p/diffreps/).
+ [region_analysis](https://github.com/shenlab-sinai/region_analysis).
+ [samtools](http://samtools.sourceforge.net/).
+ [ggplot2](http://cran.r-project.org/web/packages/ggplot2/index.html). An R graphic package.
+ [ChIPpeakAnno](http://www.bioconductor.org/packages/release/bioc/html/ChIPpeakAnno.html). A bioconductor package used for annotation and GO analysis.

Install these softwares or packages and make sure the softwares are in `$PATH`.

## Installation

Put all script in `bin` folders to a place in `$PATH` or add these folders to `$PATH`.

## Usage

Generally, all these pipelines could be run in this way:

```bash
nohup ./A_do.sh &
```

All parameters or options used in the projects could be edited to fit the demands before running.

For the organization of projects, I generally follow this paper: [A Quick Guide to Organizing Computational Biology Projects](http://www.ploscompbiol.org/article/info%3Adoi%2F10.1371%2Fjournal.pcbi.1000424). So `$DATA` are the folder contains `*.bam` alignment files, while `$RESULT` folder are the results.

**Important:**

+ To make comparisons between two conditions work, please name the bam files in this way:
```
Say condition A, B, each with 2 replicates, and one DNA input per condition.
Name the files as A_rep1.bam, A_rep2.bam, A_input.bam, B_rep1.bam,
B_rep2.bam, and B_input.bam.The key point is to make the same condition
 samples with common letters and input samples contain "input" or "Input"
 strings. If you use preprocess pipeline in this way, then you just need to edit
 the configurations in A_do.sh
```

## TODO

Dscribtions of each pipeline.
