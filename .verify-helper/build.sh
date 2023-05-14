filename="$1"; shift
output="$1"; shift

echo "[INFO] Building Crystal project ${filename}..."
crystal build "$filename" -o "${output}" --error-trace $@ || exit 1

echo "[INFO] Build completed."