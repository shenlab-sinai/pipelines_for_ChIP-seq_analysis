#! /usr/bin/env Rscript

args <- commandArgs(TRUE)
result.path <- args[1]
con1 <- args[2]
con2 <- args[3]

files <- list.files(result.path, pattern="*PI.txt")

readPI <- function(file.name, result.path){
	x <- read.table(paste(result.path, "/", file.name, sep=""),
		stringsAsFactors=FALSE, sep="\t", comment.char="")
	return(x[,12])
}

PI.list <- lapply(files, readPI, result.path=result.path)
PI.df <- do.call(cbind, PI.list)
colnames(PI.df) <- files

t.test.row <- function(row, con1.hit, con2.hit){
	if(any(is.na(row))){
		return(NA)
	}else{
		t.res <- t.test(row[con1.hit], row[con2.hit])
		return(t.res$p.value)
	}
}

con1.hit <- grep(con1, colnames(PI.df))
con2.hit <- grep(con2, colnames(PI.df))
PI.p.val <- apply(PI.df, 1, t.test.row, con1.hit=con1.hit, con2.hit=con2.hit)
PI.p.adj <- p.adjust(PI.p.val, method="BH")

diff.row <- function(row, con1.hit, con2.hit){
	if(any(is.na(row))){
		return(NA)
	}else{
		diff.res <- mean(row[con1.hit]) - mean(row[con2.hit])
		return(diff.res)
	}
}

PI.diff <- apply(PI.df, 1, diff.row, con1.hit, con2.hit)

res.df <- read.table(paste(result.path, "/", files[1], sep=""), 
	stringsAsFactors=FALSE, sep="\t", comment.char="")[,1:7]
res.df <- cbind(res.df, PI.diff, PI.p.val, PI.p.adj)
write.table(res.df, file=paste(result.path, "/PI_result.txt", sep=""),
	sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)