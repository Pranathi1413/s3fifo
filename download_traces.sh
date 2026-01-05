#!/usr/bin/env bash
set -euo pipefail
set -o errtrace
trap 'code=$?; echo "ERR: code=$code  task=${SLURM_PROCID:-NA}  line=$LINENO  cmd: $BASH_COMMAND" >&2' ERR

URLS_FILE="urls.txt"
ROOT_DIR="libCacheSim/alldata"
DELIM="-" # delimiter to replace inner '/' in filenames
BASE="https://ftp.pdl.cmu.edu/pub/datasets/twemcacheWorkload/cacheDatasets"

: "${SLURM_PROCID:=0}"
: "${SLURM_NTASKS:=1}"

BASE="${BASE%/}"

mkdir -p "$ROOT_DIR"

download_one_url() {
  url="$1"

  # ensure URL starts with BASE + "/" (otherwise skip)
  rel="${url#"$BASE/"}"
  if [ "$rel" = "$url" ]; then
    echo "skip (outside BASE): $url" >&2
    return 0
  fi
  # Now rel is like "twitter/sample100/file.oracleGeneral.zst"

  # splitting rel into:
  # top => first path segment like twitter
  # rest => everything after the first slash like sample100/file.oracleGeneral.zst
  top="${rel%%/*}"
  rest="${rel#*/}"

  # replace all '/' in $rest with the DELIM
  new_filename="$(printf %s "$rest" | tr '/' "$DELIM")"

  dest_dir="$ROOT_DIR/$top"
  dest="$dest_dir/$new_filename"
  mkdir -p "$dest_dir"

  # if a non-empty file already exists at dest, skip
  if [ -s "$dest" ]; then
    echo "Skip (exists): $dest"
  else
    echo "Starting download $url -> $dest"
    # curl flags:
    #  -f => fail on HTTP errors (4xx/5xx)
    #  -sS => be quiet, but still show errors
    #  -L => follow redirects
    #  -C - => resume a partial download if it exists
    curl -fsSLC - "$url" -o "$dest"
    echo "Downloaded $url -> $dest"
  fi
}

# assuming SLURM_NTASKS and SLURM_PROCID are set by srun/sbatch
total_lines="$(wc -l < "$URLS_FILE")"
echo "Slurm PROC=$SLURM_PROCID NTASKS=$SLURM_NTASKS TOTAL FILES TO DOWNLOAD=$total_lines"

i="$SLURM_PROCID"
while [ "$i" -lt "$total_lines" ]; do
  line_number=$((i + 1))
  url="$(sed -n "${line_number}p" "$URLS_FILE")"
  if [ -n "$url" ]; then
    download_one_url "$url"
  fi
  i=$((i + SLURM_NTASKS))
done

echo "Done. Files are under: $ROOT_DIR"
