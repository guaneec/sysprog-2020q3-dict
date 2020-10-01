#!/usr/bin/env bash
set -e
echo
echo "-----------"
echo "TEST BLOOM"
echo "-----------"
./test_all n "$match" bloom
echo
echo "-----------"
echo "TEST NOBLOOM"
echo "-----------"
./test_all n "$match" nobloom
python3 data_scripts/median.py "measurement/n_${match}_nobloom.txt" > "measurement/n_${match}_nobloom_median.txt"
python3 data_scripts/median.py "measurement/n_${match}_bloom.txt"> "measurement/n_${match}_bloom_median.txt"