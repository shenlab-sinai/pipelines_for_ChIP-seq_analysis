#! /usr/bin/env Rscript

args <- commandArgs(TRUE)
data.path <- args[1]
result.path <- args[2]
tag <- args[3]
input.tag <- args[4]

tss <- read.table(paste(result.path, "/", tag, "_tss.txt", sep=""), 
	stringsAsFactors=FALSE, sep="\t", comment.char="")
gb <- read.table(paste(result.path, "/", tag, "_GB.txt", sep=""),
	stringsAsFactors=FALSE, sep="\t", comment.char="")
tss.input <- read.table(paste(result.path, "/", input.tag, "_tss.txt", sep=""),
	stringsAsFactors=FALSE, sep="\t", comment.char="")
gb.input <- read.table(paste(result.path, "/", input.tag, "_GB.txt", sep=""), 
	stringsAsFactors=FALSE, sep="\t", comment.char="")

tss.count <- tss[,11]
gb.count <- gb[,11]
tss.count.input <- tss.input[,11]
gb.count.input <- gb.input[,11]

chip.cnt <- read.table(paste(data.path, "/", tag, ".bam.cnt", sep=""), 
	stringsAsFactors=FALSE, sep="\t", comment.char="")[1,1]
input.cnt <- read.table(paste(data.path, "/", input.tag, ".bam.cnt", sep=""), 
	stringsAsFactors=FALSE, sep="\t", comment.char="")[1,1]

PI <- (log2(((tss.count+1)/chip.cnt)/((tss.count.input+1)/input.cnt)) - 
	log2(((gb.count+1)/chip.cnt)/((gb.count.input+1)/input.cnt)))

res <- tss[,1:7]
res <- cbind(res, tss[,c(11,13)], gb[,c(11,13)])
total.count <- res[,8] + res[,10]
total.cutoff <- quantile(total.count, probs=0.1)
cat("0.1 Quantile cutoff of ", tag, " is:", total.cutoff, "\n")
pdf(file=paste(result.path, "/", tag, "_PI.pdf", sep=""))
hist(PI, breaks=100, main="Hist of PI without reads cutoff")
PI[total.count<=total.cutoff] <- NA
res <- cbind(res, PI)

write.table(res, file=paste(result.path, "/", tag, "_PI.txt", sep=""),
	sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
hist(res$PI, breaks=100, main="Hist of PI (lowest 10% reads counts removed)")
qqnorm(res$PI)
hist(log10(total.count), breaks=100)
dev.off()