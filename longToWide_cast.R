
# read in a long table where the first column is variable A, the second is variable B, and the third is the count
# output a wide table where the rows are variable A and the columns are variable B

# get input file
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

#inputFile <- "VcDNA_HQ.min100_assembly.sam.contigSampleCounts.tsv" 
inputFile <- as.character(args[1])
outputFile <- paste0(inputFile,"_wide.tsv")

print(paste("Processing file:",inputFile, "creating:",outputFile))


library(reshape2)
longData <- read.csv2(file=inputFile,sep = "\t",strip.white = T,stringsAsFactors = F,header = F)
wideData <- reshape2::dcast(data = longData,formula = V1 ~ V2,fill = 0,value.var = "V3")
write.csv(wideData, file= outputFile, row.names=F)