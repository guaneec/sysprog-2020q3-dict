import sys
from collections import defaultdict

if len(sys.argv) > 2:
    print(f"Usage: python3 {sys.argv[0]} <filename>")
    sys.exit(1)


d = defaultdict(list)
with open(sys.argv[1], "r") if len(sys.argv) == 2 else sys.stdin as f:
    for line in f:
        label, value = [float(x) for x in line.split()]
        d[label].append(value)


def median(xs):
    n = len(xs)
    return xs[n // 2] if n % 2 else (xs[n // 2] + xs[n // 2 - 1]) / 2


for label, values in d.items():
    print(f"{int(label)} {median(values)}")
