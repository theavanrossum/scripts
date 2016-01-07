ls /home/tva4/watershedMetagenomics/analysis/viral/VcDNA/circonspect/defaults/*/circonspect.csp > col2
cat col2 | cut -d "_" -f 2 > col1
paste col1 col2 > infoForQsubRuns.txt