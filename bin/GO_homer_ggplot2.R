#! /usr/bin/env Rscript

args <- commandArgs(TRUE)
file.path <- args[1]
p.val.cutoff <- as.numeric(args[2])

readGO <- function(file.name, result.path){
	x <- read.table(paste(result.path, "/", file.name, sep=""),
		stringsAsFactors=FALSE, sep="\t", comment.char="", header=TRUE, quote="", fill=TRUE)
    if("P.value" %in% colnames(x)){
        x <- x[order(x$P.value), ]
    }else{
        P.value <- 2**(x$logP)
        x["P.value"] <- NA
        x$P.value <- P.value
        x["Number.in.common"] <- NA
        x$Number.in.common <- x$Target.Genes.in.Term
    }
	return(x[, c("Term", "P.value", "Number.in.common")])
}

files <- c("biological_process.txt", "cellular_component.txt", "molecular_function.txt", "kegg.txt")
GO.types <- c("Biological Process", "Cellular Component", "Molecular Function", "KEGG Pathway")
GO.list <- list()
for(i in 1:length(GO.types)){
	GO.list[[GO.types[i]]] <- cbind(GO.types[i], readGO(files[i], file.path))
}
GO.df <- do.call(rbind, GO.list)
GO.df$P.value <- -log10(GO.df$P.value)
GO.df$Number.in.common <- log10(GO.df$Number.in.common)
names(GO.df) <- c("GO.types", "Term", "minusLog10Pvalue", "Log10NinC")
GO.df <- GO.df[which(GO.df$minusLog10Pvalue > -log10(p.val.cutoff)), ]
GO.df <- cbind(Order=nrow(GO.df):1, GO.df)
term.max.len <- max(sapply(as.vector(GO.df$Term), nchar))

require(ggplot2)
pdf(file=paste(file.path,"/" , "GO_barplot_", as.character(p.val.cutoff), ".pdf", sep=""),
	height=1+0.2*nrow(GO.df), width=7+term.max.len*0.05)
ggplot(GO.df, aes(x=Order, y=minusLog10Pvalue, fill=GO.types))+ 
	scale_x_discrete(breaks=GO.df$Order, labels=GO.df$Term, limits=GO.df$Order, expand=c(0,0)) +
    geom_bar(stat="identity") + 
    scale_y_continuous(expand=c(0,0)) + 
    xlab("GO Term") + ylab("-log10(P value)") +
    scale_fill_discrete(name="GO Types") +
    theme(axis.line = element_line(colour = "black"),
    	panel.grid.major = element_blank(),
    	panel.grid.minor = element_blank(),
    	panel.border = element_blank(),
    	panel.background = element_blank()) + 
    coord_flip()
dev.off()