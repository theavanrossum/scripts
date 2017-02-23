num=50000
typeField="Visit"

cd "/home.westgrid/thea/CHILD/compare16S/qiime/myOldProtocol/R1noQC/"
mappingFile="/home.westgrid/thea/CHILD/compare16S/qiime/myOldProtocol/R1noQC/mapping_output/mappingFileStuart_R1_corrected.txt"
inputOTUtable="/home.westgrid/thea/CHILD/compare16S/qiime/myOldProtocol/R1noQC/otus/otu_table.biom"
inputRepSetTre="/home.westgrid/thea/CHILD/compare16S/qiime/myOldProtocol/R1noQC/otus/rep_set.tre"

#OTU Heatmap
echo "### OTU Heatmap"
rm -rf OTU_Heatmap ; make_otu_heatmap.py -i $inputOTUtable -o OTU_Heatmap -m $mappingFile -t $inputRepSetTre

#OTU Network
echo "### OTU Network"
rm -rf OTU_Network ; make_otu_network.py -m $mappingFile -i $inputOTUtable -o OTU_Network -b $typeField

#Make Taxa Summary Charts
echo "### Summarize taxa"
rm -rf wf_taxa_summary; summarize_taxa_through_plots.py -i $inputOTUtable -o wf_taxa_summary -m $mappingFile -s

#Make Taxa Summary Charts by type
echo "### Summarize taxa by type"
rm -rf wf_taxa_summary_by_type; summarize_taxa_through_plots.py -i $inputOTUtable -o wf_taxa_summary_by_type -m $mappingFile -s -c $typeField

echo "### Alpha rarefaction"
#alpha_diversity.py -h
echo "alpha_diversity:metrics shannon,PD_whole_tree,chao1,observed_species" > alpha_params.txt

rm -rf wf_arare ; alpha_rarefaction.py -i $inputOTUtable -m $mappingFile -o wf_rare/ -p alpha_params.txt -t $inputRepSetTre

echo "### Beta diversity and plots"
rm -rf wf_bdiv_even$num ; beta_diversity_through_plots.py -i $inputOTUtable -m $mappingFile -o wf_bdiv_even$num/ -t $inputRepSetTre -e $num

echo "### Jackknifed beta diversity"
rm -rf wf_jack_$num ; jackknifed_beta_diversity.py -i $inputOTUtable -t $inputRepSetTre -m $mappingFile -o wf_jack_$num -e $num

echo "### Make Bootstrapped Tree"
make_bootstrapped_tree.py -m wf_jack_$num/unweighted_unifrac/upgma_cmp/master_tree.tre -s wf_jack_$num/unweighted_unifrac/upgma_cmp/jackknife_support.txt -o wf_jack_$num/unweighted_unifrac/upgma_cmp/jackknife_named_nodes.pdf
