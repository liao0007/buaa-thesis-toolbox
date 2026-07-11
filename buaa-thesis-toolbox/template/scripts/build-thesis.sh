#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

output_file="${1:-毕业论文.pdf}"

files=()
while IFS= read -r file; do
  files+=("$file")
done < <(find chapters -maxdepth 1 -type f -name '*.md' | sort)

if [ "${#files[@]}" -eq 0 ]; then
  echo "No Markdown files found under chapters/." >&2
  exit 1
fi

pandoc "${files[@]}" --defaults "./pandoc-thesis.yaml" -o "$output_file"
