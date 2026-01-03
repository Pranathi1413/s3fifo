#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="dirs.txt"
OUT_FILE="urls.txt"
SUFFIX_REGEX='\.zst$'   # only files that end with this

: > "$OUT_FILE"

while IFS= read -r DIR_URL; do
    if [ -z "$DIR_URL" ]; then
        continue
    fi

    first_char=$(printf %s "$DIR_URL" | cut -c1)
    if [ "$first_char" = "#" ]; then
        continue
    fi

    if [ "${DIR_URL%/}" = "$DIR_URL" ]; then
        DIR_URL="$DIR_URL/"
    fi

    curl -fsSL "$DIR_URL" \
    | grep -Eo 'href="[^"]+"' \
    | sed -E 's/^href="//; s/"$//' \
    | grep -v '^\.\./' \
    | grep -E "$SUFFIX_REGEX" \
    | sed -E "s|^|${DIR_URL%/}/|" \
    >> "$OUT_FILE"

done < "$INPUT_FILE"

echo "Found $(wc -l < "$OUT_FILE") URLs to $OUT_FILE"
