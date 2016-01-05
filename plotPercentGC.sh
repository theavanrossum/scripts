read_fasta -i $1 -n 10000 |   # read in 10000 entries
analyze_gc |                            # analyze GC% per entry
bin_vals -k GC% |                       # bin GC% values
plot_histogram -k GC%_BIN -s num -x     # plot a histogram