#!/usr/bin/env python3
from collections import defaultdict
from random import sample
from os import makedirs

makedirs('inputs/', exist_ok=True)

wsu = defaultdict(set)
with open('cities.txt') as f:
    for l in f.readlines():
        for w in l.split(','):
            w = w.strip()
            wsu[len(w.encode('utf-8'))].add(w)

for l in range(4, 20):
    with open(f'inputs/{l}.txt', 'w') as f:
        for w in sample(wsu[l], 1000):
            print(w, file=f)
        print(f'{f.name} written')