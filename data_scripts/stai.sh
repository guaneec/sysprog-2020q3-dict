set -e
cat cities_split_uniq.txt \
    | cut -c 1-4 | awk '{print("s");print;}'\
    | ./test_common "$CPYREF" \
    | grep -a 'searched prefix in' \
    | awk '{print $(NF-1);}' > "measurement/stai_${CPYREF}.txt"