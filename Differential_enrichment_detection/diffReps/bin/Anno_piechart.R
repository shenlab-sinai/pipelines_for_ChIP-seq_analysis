#!/usr/bin/env Rscript

args <- commandArgs(T)
result.path <- paste(args[1], "/", sep="")
file.name <- args[2]
anno.col <- as.numeric(args[3])
header.is <- as.logical(args[4])

anno <-
  read.delim(paste(result.path, file.name, sep=""), header=header.is)
anno.table <- table(anno[, anno.col])
lbls <- paste(names(anno.table)," ",
              anno.table, sep="")
pdf(paste(result.path, file.name, "_diffReps_dis.pdf", sep=""))
pie(anno.table, labels=lbls, col=rainbow(length(lbls)),
    cex=0.8, radius=0.7,
    main=paste("Distribution"))
dev.off()
write.csv(anno.table, file=paste(result.path, file.name,
                             "_diffReps_distribution", ".csv",
                             sep=""))