#!/home.westgrid/thea/programs/anaconda/bin/python

# get the longest n sequences from fasta file
# if multiple with same length, all will be returned

from Bio import SeqIO
import argparse
__author__ = 'theavanrossum'
 
parser = argparse.ArgumentParser(description='Get the longest n sequences from fasta file.')
parser.add_argument('-f','--fasta', help='Input fasta file name',required=True)
parser.add_argument('-n','--nseq',help='Number of sequences', required=True, type=int)
args = parser.parse_args()

fastaFile=args.fasta
nSeq=args.nseq

fastaFileOut=fastaFile + ".longest" + str(nSeq) + ".fasta"
print( "The longest "+str(nSeq)+" sequences from "+fastaFile+" will be saved as "+fastaFileOut)

#Get the lengths and ids, and sort on length
len_and_ids = sorted( (( len(rec), rec.id ) for rec in SeqIO.parse(open(fastaFile),"fasta")) , reverse=True)
lengthCutoff = len_and_ids[nSeq-1][0]
ids = [id for (length, id) in len_and_ids if length >= lengthCutoff ]
del len_and_ids
#Now prepare the index
record_index = SeqIO.index(fastaFile, "fasta")
#Now prepare a generator expression to give the
#records one-by-one for output
records = (record_index[id] for id in ids)

#Finally write these to a file
handle = open(fastaFileOut, "w") 
writer = SeqIO.FastaIO.FastaWriter(handle,wrap=0) 
writer.write_file(records)
handle.close()
