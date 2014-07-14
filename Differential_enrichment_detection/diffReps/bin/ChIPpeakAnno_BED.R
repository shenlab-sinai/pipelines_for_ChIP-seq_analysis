#!/usr/bin/env Rscript

require("ChIPpeakAnno")||{source("http://bioconductor.org/biocLite.R");biocLite("ChIPpeakAnno");require("ChIPpeakAnno")}
args <- commandArgs(T)
result.path <- paste(args[1], "/", sep="")
bed.file.name <- args[2]
genome <- args[3]

if(genome=="rn4"){
  require("org.Rn.eg.db")||{source("http://bioconductor.org/biocLite.R");biocLite("org.Rn.eg.db");require("org.Rn.eg.db")}
  data(TSS.rat.RGSC3.4)
  bio.anno <- "org.Rn.eg.db"
  data.name <- "TSS.rat.RGSC3.4"
}else if(genome=="mm9"){
  require("org.Mm.eg.db")||{source("http://bioconductor.org/biocLite.R");biocLite("org.Mm.eg.db");require("org.Mm.eg.db")}
  data(TSS.mouse.NCBIM37)
  bio.anno <- "org.Mm.eg.db"
  data.name <- "TSS.mouse.NCBIM37"
}else if(genome=="hg19"){
  require("org.Hs.eg.db")||{source("http://bioconductor.org/biocLite.R");biocLite("org.Hs.eg.db");require("org.Hs.eg.db")}
  data(TSS.human.GRCh37)
  bio.anno <- "org.Hs.eg.db"
  data.name <- "TSS.human.GRCh37"
}else{
  stop("Unsupport genome!")
}

x<-read.table(paste(result.path, bed.file.name, sep=""),
              stringsAsFactors=F)
mypeak <- BED2RangedData(x)
annotatedPeak = annotatePeakInBatch(mypeak,
  AnnotationData=get(data.name))
anno.peaks.geneid <- addGeneIDs(annotatedPeak, bio.anno,
                                c("symbol"))
anno.id <- as.data.frame(anno.peaks.geneid) # col 15 is the gene id,
                                            # col 8 is ensembl id.
anno.peaks <- as.data.frame(annotatedPeak)
print(summary(anno.peaks["insideFeature"]))

enrichedGO = getEnrichedGO (annotatedPeak, orgAnn = bio.anno,
  maxP = 0.05, multiAdj = T, minGOterm = 10, multiAdjMethod = "BH" )


GO.csv <- function(GO.df, result.path, bed.file.name, tag){
  new.GO <- unique(GO.df[,-11])
  new.GO <- new.GO[order(new.GO$BH.adjusted.p.value), ]
  write.csv(new.GO, file=paste(result.path, bed.file.name,
                      "_", tag, ".csv",
                      sep=""))
}

GO.csv(enrichedGO$bp, result.path, bed.file.name, "BP")
GO.csv(enrichedGO$mf, result.path, bed.file.name, "MF")
GO.csv(enrichedGO$cc, result.path, bed.file.name, "CC")
