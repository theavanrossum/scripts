#!/usr/bin/env Rscript

###############################################################
### Parameter section. Set these before running this script ###
###############################################################
NUM.BOOT.ITER <- 100 #number of iterations of subsampling to be done before averaging together

#INPUT.FILE <- "/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/proteinClusters/deNovo/alnReadsVsRepSeqs/blastx/filtered/
#INPUT.FILE <- "/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/assembly/VDNA_HQ.min70_assembly.sam.contigSampleCounts_wide.tsv"

reproducibleResults <- F # F if you want it to change everytime this is run, set as integer if you want it to be reproducible
subsampleSize <- NULL # set as NULL to use the minimum sample size or set as int to use a different size and discard samples with read counts less than this

IGNORE.COLUMN.PATTERN <- "NEG"

### If phyloseq isn't installed, run these two commands. R v3 required. 
#source("http://bioconductor.org/biocLite.R")
#biocLite("phyloseq")

#####################################################################
### If all goes well, you shouldn't need to change anything below ###
#####################################################################

# get input file
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}
INPUT.FILE <- args[1]
print(paste("Processing file:",INPUT.FILE))


library("phyloseq")

# load data
contigAbundPreSubset <- read.csv2(
  file = INPUT.FILE,
  header = T,sep = ",",as.is = T,strip.white = T)
# row names as contig names
#contigAbundPreSubset <- contigAbundPreSubset[,-1]
contigNames <- contigAbundPreSubset[,1]
contigAbundPreSubset <- data.frame(contigAbundPreSubset[,-1])

contigAbundPreSubset <- as.data.frame(lapply(contigAbundPreSubset,as.numeric))
row.names(contigAbundPreSubset) <- contigNames

# remove any samples with no reads assigned to any contigs or less than the subsample amount
print(paste(sum(colSums(contigAbundPreSubset) == 0)," samples removed due to zero reads assigned to contigs"))
contigAbundPreSubset <- subset(contigAbundPreSubset, sample = T, select = colSums(contigAbundPreSubset) > 0)


# get smallest read count sum by sample
if( is.null(subsampleSize) | 
    !is.numeric(subsampleSize) | 
    (is.numeric(subsampleSize) & isTRUE(subsampleSize < 1)) ){
  subsampleSize <-  floor(min(colSums(contigAbundPreSubset[,grep(x=colnames(contigAbundPreSubset),pattern=IGNORE.COLUMN.PATTERN,invert=T,value=F),])))
#  subsampleSize <-  floor(min(colSums(contigAbundPreSubset)))
  print("Smallest sample sizes:")
  print(sort(colSums(contigAbundPreSubset))[1:5])
  print(paste("Subsampling to minimum sample size:", subsampleSize ))
  
  # remove any samples that match the IGNORE.COLUMN.PATTERN and have < cutoff reads
  contigAbundPreSubset <- subset(contigAbundPreSubset, sample = T, select = colSums(contigAbundPreSubset) > subsampleSize)
}else{
  print(paste("Subsampling to user-defined sample size:", subsampleSize ))
  print(paste(sum(colSums(contigAbundPreSubset) < subsampleSize )," samples removed due to read count lower than subsample size"))
  contigAbundPreSubset <- subset(contigAbundPreSubset, sample = T, select = colSums(contigAbundPreSubset) > subsampleSize)
}

# remove any samples with no reads assigned to any contigs
print(paste(sum(rowSums(contigAbundPreSubset) == 0)," contigs removed due to zero reads assigned"))
contigAbundPreSubset <- subset(contigAbundPreSubset, sample = rowSums(contigAbundPreSubset) > 0)

# use phyloseq to do subsampling
fakeOTUtable <- otu_table(contigAbundPreSubset, taxa_are_rows=T)
phyloseqObj <- phyloseq(fakeOTUtable)

# 2D array to store subsample counts
data.subsamples.sum <- array(0, dim=c(nrow(contigAbundPreSubset),ncol(contigAbundPreSubset))) 

print(paste("Iterating",NUM.BOOT.ITER,"times..."))
for (i in 1:NUM.BOOT.ITER) {
  cat(paste(i," "))
  phyloseqObj.subsampled <- rarefy_even_depth(phyloseqObj, sample.size=subsampleSize,trimOTUs = F,verbose = F)
  data.subsamples.sum <- data.subsamples.sum + phyloseqObj.subsampled
}
# divide the sums by the number of iteration to make a mean value
data.subsamples.mean <- data.subsamples.sum/NUM.BOOT.ITER


outFile <- paste(INPUT.FILE,"-rarefied",subsampleSize,".csv",sep="")
print(paste("Writing results to",outFile))
colnames(data.subsamples.mean)<- colnames(contigAbundPreSubset)
row.names(data.subsamples.mean)<- row.names(contigAbundPreSubset)
  
write.csv(data.subsamples.mean, outFile, na="")
print("Done!")