#!/usr/bin/env bash
set -euo pipefail

trace_dir="libCacheSim/data1"
out_dir="results1"
mkdir -p "$out_dir"

for trace in "$trace_dir"/*; do
	base="$(basename "$trace")"
	out="$out_dir/${base%%.*}.txt"
	echo "\nRunning $trace and storing result in $out"
	./libCacheSim/_build/bin/cachesim "$trace" oracleGeneral s3fifo 0 --ignore-obj-size 1 > "$out" 2>&1
	echo "\nDone running $trace"
done
