
# get input file
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

CONTIG.ABUNDANCE.FILE <- "/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/proteinClusters/vsTOV-AAsequences/alnReadsVsRepSeqs/vs-NonTOV-and-TOV/abundTables/multiCountMultiHits/vdnaProtClust_filteredContigAbundAlnLen.tsv_wide.tsv-normByContigLeng.csv"
READ.COUNT.FILE <- "/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/reads/postqc_min70/readCounts_VDNA_min70.txt"

#CONTIG.ABUNDANCE.FILE <- args[1]
#READ.COUNT.FILE  <- args[2]

print(paste("Processing files:",CONTIG.ABUNDANCE.FILE,READ.COUNT.FILE))

SCALE.FACTOR <- 1 # int to scale the data by (so that they aren't all tiny numbers that get tricky), value of 1 means no scaling
# scaling can be useful but need to be aware that it inflates the difference between values close to zero and zeros

print("Loading data...")

# load data
contigAbund <- read.csv2(
  file = CONTIG.ABUNDANCE.FILE,
  header = T,sep = ",",as.is = T,strip.white = T)
# row names as contig names
row.names(contigAbund) <- contigAbund[,1]
contigAbund <- contigAbund[,-1]
head(colnames(contigAbund))
sampNumbers <- as.numeric(gsub("\\D", "", sampNumbers))
head(colnames(contigAbund))

readCounts <- read.csv2(
  file = READ.COUNT.FILE,
  header = F,sep = "\t",as.is = T,strip.white = T)
colnames(readCounts) <- c("SampleFileName","ReadCount")
row.names(readCounts) <- readCounts$SampleFileName
readCountSampNumbers <- as.numeric(gsub("",,readCounts$SampleFileName))

head(readCounts$SampleFileName)

print("Sorting data...")
# sort data
contigAbund <- contigAbund[order(row.names(contigAbund)),]
contigLengths <- subset(contigLengths, subset = ( contigLengths$Contig %in% row.names(contigAbund) ) )
contigLengths <- contigLengths[order(contigLengths$Contig),]

head(row.names(contigAbund))
head(contigLengths$Contig)

if(!identical(row.names(contigAbund), contigLengths$Contig)){
  stop("Contig names not identical between abundance and length data")  
}

print("Normalising...")

contigAbund.norm <- data.matrix(contigAbund)/contigLengths[,"Length"]

print("Writing results...")
write.csv(contigAbund.norm, paste(CONTIG.ABUNDANCE.FILE,"-normByContigLeng.csv",sep=""), na="")

print("Done!")