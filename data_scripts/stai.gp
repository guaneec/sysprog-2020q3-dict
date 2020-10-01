
set output 'img/stai.png'
set terminal pngcairo
set title "CDF, execution time of prefix search"
set key bottom right box
set xlabel "time (ms)"
set ylabel "cdf"
set logscale x
set grid ytics xtics mxtics

plot 'measurement/stai_REF.txt' u ($1*1000):(1) smooth cnorm t 'ref', 'measurement/stai_CPY.txt' u ($1*1000):(1) smooth cnorm t 'cpy'