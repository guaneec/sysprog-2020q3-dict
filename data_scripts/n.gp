reset session
set term pngcairo
match=system("echo $match")
set output sprintf('img/n-%s.png', match)
set key top left
set title sprintf("Execution time (CPY, m=40k): search 2000 words, match: %s", match)
set ylabel "time (ms)"
set xlabel "items in the filter (1000 items)"
plot sprintf('measurement/n_%s_bloom_median.txt', match) u 1:($2*1000) t 'with bloom', sprintf('measurement/n_%s_nobloom_median.txt', match) u 1:($2*1000) t 'without bloom'