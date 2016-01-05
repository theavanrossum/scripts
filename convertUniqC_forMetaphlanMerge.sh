#!/bin/bash
sed -i 's/^ [ ]*\([0-9][0-9]*\) [ ]*\([0-9][0-9]*\)/\2 \1/g' *.counts
sed -i 's/ /\t/g'  *.counts
~/programs/metaphlan/utils/merge_metaphlan_tables.py *.counts > counts.txt
