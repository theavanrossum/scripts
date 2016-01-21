#!/home.westgrid/thea/programs/anaconda/bin/python

# get the longest n sequences from fasta file
# if multiple with same length, all will be returned

from Bio import SeqIO
import argparse
__author__ = 'theavanrossum'
 
parser = argparse.ArgumentParser(description='Get the sequence lengths from fasta file.')
parser.add_argument('-f','--fasta', help='Input fasta file name',required=True)
args = parser.parse_args()

fastaFile=args.fasta

fileOut=fastaFile + ".lengths.txt"
print( "The sequence lengths from "+fastaFile+" will be saved as "+fileOut)

#Get the lengths and ids
ids_and_lengths = (( rec.id, len(rec) ) for rec in SeqIO.parse(open(fastaFile),"fasta"))

open(fileOut, 'w').write('\n'.join('%s\t%s' % x for x in ids_and_lengths))

