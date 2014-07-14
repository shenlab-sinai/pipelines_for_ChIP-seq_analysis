#! /usr/bin/env Rscript

load("mm9.ensembl.genebody.protein_coding.RData")
bed <- genome.coord[genome.coord$bygid.uniq==TRUE, ]
bed <- bed[abs(bed$end-bed$start)>=500, ]

getTSS <- function(row){
	if(row[7]=="+"){
		row[2] = as.numeric(row[2]) - 200
		row[3] = as.numeric(row[2]) + 400
		return(row)
	}else{
		row[2] = as.numeric(row[3]) - 200
		row[3] = as.numeric(row[3]) + 200
		return(row)
	}
}

getGB <- function(row){
	if(row[7]=="+"){
		row[2] = as.numeric(row[2]) + 400
		return(row)
	}else{
		row[3] = as.numeric(row[3]) - 400
		return(row)
	}
}


bed.list <- split(bed, rownames(bed))

tss.list <- lapply(bed.list, getTSS)
tss.bed <- do.call(rbind, tss.list)
write.table(tss.bed, file="mm9.ensembl.coding.tss_200bp.bed",sep="\t", quote=FALSE, 
	row.names=FALSE, col.names=FALSE)

gb.list <- lapply(bed.list, getGB)
gb.bed <- do.call(rbind, gb.list)
write.table(gb.bed, file="mm9.ensembl.coding.gb_400bp.bed",sep="\t", quote=FALSE, 
	row.names=FALSE, col.names=FALSE)
