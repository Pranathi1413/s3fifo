#!/usr/bin/env bash
set -euo pipefail

MANIFEST="trace.manifest"
CACHESIM="./libCacheSim/_build/bin/cachesim"
ALGO="s3fifo"
SIZES="0.001,0.01,0.1"
THREADS="${SLURM_CPUS_PER_TASK:-1}"
OUTDIR="results1"
mkdir -p "$OUTDIR"

N=$(wc -l < "$MANIFEST")
echo "$N traces in total"
proc=${SLURM_PROCID:-0}
ntasks=${SLURM_NTASKS:-1}
echo "This is proc $SLURM_PROCID"

for ((i=proc; i<N; i+=ntasks)); do
  trace=$(sed -n "$((i+1))p" "$MANIFEST")
  filename="${trace##*/}"
  outname="${filename%%.*}"
  echo "Starting $trace Output in $outname"
  "$CACHESIM" "$trace" oracleGeneral "$ALGO" "$SIZES" --ignore-obj-size 1 --num-thread "$THREADS" > "$OUTDIR/${outname}-${ALGO}.txt" 2>&1
  echo "Done $trace"
done
