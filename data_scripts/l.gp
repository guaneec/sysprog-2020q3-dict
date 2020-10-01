reset session
set term pngcairo
match=system("echo $match")
set output sprintf('img/l-%s.png', match)
set key top left
set title sprintf("Execution time (CPY): search 1000 words, match: %s", match)
set ylabel "time (ms)"
set xlabel "length of a tested string"
plot sprintf('measurement/l_%s_bloom_median.txt', match) u 1:($2*1000) t 'with bloom', sprintf('measurement/l_%s_nobloom_median.txt', match) u 1:($2*1000) t 'without bloom'