#!/bin/R

# trying to avoid dependencies, this needs getopt
#spec <- matrix(c(
#        'counts'    , 'c', 1, "character", "file with table where rows are kmers and columns are samples, each table entry is a kmer frequency count (required)",
#        'distMethod', 'd', 1, "character", "name of metric to use in calculating distance matrix (required) e.g. manhattan",
#        'kmerLength', 'k', 1, "integer"  , "length of kmer (required for naming output file)",
#        'help'      , 'h', 0, "logical"  , "this help"
#),ncol=5,byrow=T)
#opt = getopt(spec);
#if (!is.null(opt$help) || is.null(opt$in)) {
#    cat(paste(getopt(spec, usage=T),"\n"));
#    q();
#}
#
#if ( is.null(opt$counts ) ) { stop("Error: Missing input count file") }
#if ( is.null(opt$distMethod ) ) { stop("Error: Missing distance method") }
#if ( is.null(opt$kmerLength ) ) { stop("Error: Missing kmer length") }
#if ( !is.numeric(opt$kmerLength ) ) { stop("Error: Kmer length is not numeric") }

args <- commandArgs(trailingOnly = TRUE)
kmerLength <- args[1] # e.g. 4
distMethod <- args[2] # e.g. "manhattan"
kmerCountTablePath <- args[3] # e.g. "all.Counts.min2.minSum10.txt"

# for lower memory alternative, could load two files in at a time

print("Loading data...")

kmerCountTable<-read.csv(kmerCountTablePath,header=T,sep="\t")

print(paste("Number of samples",ncol(kmerCountTable)))
print(paste("Number of kmers",nrow(kmerCountTable)))
#print(summary(kmerCountTable))

print("Calculating dist...")

distanceMatrix<-matrix( nrow = ncol(kmerCountTable), ncol = ncol(kmerCountTable) )

for( i in 1:( ncol(kmerCountTable)-1 ) ){
     print(colnames(kmerCountTable)[i])
      for( j in (i+1):ncol(kmerCountTable) ){
      	    distanceMatrix[i,j]<-dist(t(kmerCountTable[,c(i,j)]),method=distMethod)
      }
}

row.names(distanceMatrix)<-colnames(kmerCountTable)
colnames(distanceMatrix)<-colnames(kmerCountTable)

print("saving dist")
write.csv(distanceMatrix,file=paste("distanceMatrix.k",kmerLength,".min2.minSum10.",distMethod,".csv",sep=""))
