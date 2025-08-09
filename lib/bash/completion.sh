# Only run in interactive bash
if [[ -z ${BASH_VERSION:-} || $- != *i* ]]; then
  return 0 2>/dev/null || exit 0
fi

for f in "$(dirname ${BASH_SOURCE})/completions/"*; do
    . "$f"
done
