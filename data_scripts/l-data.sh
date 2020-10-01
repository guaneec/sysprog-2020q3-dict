#!/usr/bin/env bash
python3 data_scripts/split_len.py &&\
echo
echo "-----------"
echo "TEST BLOOM"
echo "-----------"
./test_all l "$match" bloom &&\
echo
echo "-----------"
echo "TEST NOBLOOM"
echo "-----------"
./test_all l "$match" nobloom &&\
python3 data_scripts/median.py "measurement/l_${match}_nobloom.txt" > "measurement/l_${match}_nobloom_median.txt"  &&\
python3 data_scripts/median.py "measurement/l_${match}_bloom.txt"> "measurement/l_${match}_bloom_median.txt" &&\
true