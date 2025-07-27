for f in "$(dirname ${BASH_SOURCE})/completions/"*; do
    . "$f"
done
