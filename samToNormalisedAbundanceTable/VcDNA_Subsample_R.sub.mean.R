# from Marli

install.packages("ape", repos="http://cran.rstudio.com/")
source("http://bioconductor.org/biocLite.R")

biocLite("phyloseq")

library(phyloseq)

OTU.MarineV2=read.csv("~/Rarefy_OTU_Subsample/VcDNA_abundance.csv",header=T)
OTU.MarineV2Names=OTU.MarineV2[,1]
OTU.MarineV2Ab=OTU.MarineV2[,2:99]
#,2:8 columns where the data are
rownames(OTU.MarineV2Ab,OTU.MarineV2Names,do.NULL=F)

OTU.MarineV2T=otu_table(OTU.MarineV2Ab, taxa_are_rows=T)
#Don't put N/A, it really doesn't like it

OTU.MarineV2Phylo=phyloseq(OTU.MarineV2T)

boot.num=1000  #this is how many sampling will be done and then                				averaged together, change this number to change number of itterations
OTU.MarineV2Sub=array(NA, dim=c(836424,98,boot.num)) #this is a 3dimensional matix (dimension lengths are in dim, y,x,z).  Each z will be a subsample.
for (i in 1:boot.num) {
	OTU.MarineV2Sub.i=rarefy_even_depth(OTU.MarineV2Phylo, sample.size=141821)
	OTU.MarineV2Sub[,,i]=OTU.MarineV2Sub.i
	
}

OTU.MarineV2Sub.mean=apply(OTU.MarineV2Sub, c(1,2), mean) #this "applies" the "mean" function to the data, locking dimensions 1 and 2 (y and x) so taking the mean through  the z dimension.  Returns a matrix y by x.

write.csv(OTU.MarineV2Sub.mean, "~/Rarefy_OTU_Subsample/VcDNA_abundance_sub.csv", na="")
