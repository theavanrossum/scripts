
CONTIG.ABUNDANCE.FILE <- "/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/assembly/VcDNA_HQ.min100_assembly.sam.contigSampleCounts_wide.tsv-rarefied141821.csv"
CONTIG.LENGTH.FILE <- "/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/assembly/VcDNA_HQ.min100_assembly.fa.lengths.txt"
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

contigLengths <- read.csv2(
  file = CONTIG.LENGTH.FILE,
  header = F,sep = "\t",as.is = T,strip.white = T)
colnames(contigLengths) <- c("Contig","Length")
contigLengths$Contig <- gsub(pattern = "_contig_", replacement = "contig",x = contigLengths$Contig) 
row.names(contigLengths) <- contigLengths$Contig

print("Sorting data...")
# sort data
contigLengths <- contigLengths[order(contigLengths$Contig),]
contigAbund <- contigAbund[order(row.names(contigAbund)),]

if(!identical(row.names(contigAbund), contigLengths$Contig)){
  stop("Contig names not identical between abundance and length data")  
}

print("Normalising...")

contigAbund.norm <- data.matrix(contigAbund)/contigLengths[,"Length"]

print("Writing results...")
write.csv(contigAbund.norm, paste(CONTIG.ABUNDANCE.FILE,"-normByContigLeng.csv",sep=""), na="")

print("Done!")
