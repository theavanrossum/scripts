
# read in a long table where the first column is variable A, the second is variable B, and the third is the count
# output a wide table where the rows are variable A and the columns are variable B
 

library(reshape2)
longData <- read.csv2(file="VcDNA_HQ.min100_assembly.sam.contigSampleCounts.tsv",sep = "\t",strip.white = T,stringsAsFactors = F,header = F)
wideData <- reshape2::dcast(data = longData,formula = V1 ~ V2,fill = 0,value.var = "V3")
write.csv(wideData, file="VcDNA_HQ.min100_assembly.sam.contigSampleCounts_wide.tsv")