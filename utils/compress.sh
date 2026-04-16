#!/bin/bash
# Compress NetCDF files in the etienne_restart3_temporal_cadence directory

set -euo pipefail

# Define the source and destination directories
SRC="/rds/project/rds-DKRMHAHoC3M/nemo/data/DINO/etienne_restart3_temporal_cadence"
DST="$SRC/compressed"

# Define the compression level and number of parallel workers
DEFLATE_LEVEL=4   # 1-9; 4 is a good balance of speed vs compression
NPROC=8           # parallel workers (match --cpus-per-task)

# Define the path to the nccopy command
NCCOPY="/rds/project/rds-5mCMIDBOkPU/ma595/miniforge3/bin/nccopy"

echo "=== Starting compression at $(date) ==="
echo "Source:      $SRC"
echo "Destination: $DST"
echo "Deflate level: $DEFLATE_LEVEL"

# Function to compress a single file
compress_file() {
    src_file="$1"
    # Build destination path by replacing SRC prefix with DST
    rel="${src_file#$SRC/}"
    dst_file="$DST/$rel"

    # Create destination directory if needed
    mkdir -p "$(dirname "$dst_file")"

    echo "[$(date +%H:%M:%S)] Compressing: $rel"
    "$NCCOPY" -d "$DEFLATE_LEVEL" -s "$src_file" "$dst_file"
    status=$?
    if [ $status -ne 0 ]; then
        echo "ERROR: nccopy failed for $rel (exit $status)" >&2
    else
        src_size=$(du -sh "$src_file" | cut -f1)
        dst_size=$(du -sh "$dst_file" | cut -f1)
        echo "  Done: $src_size -> $dst_size"
    fi
}

export -f compress_file
export SRC DST NCCOPY DEFLATE_LEVEL

# Find all NetCDF files and compress in parallel
find "$SRC" -name "*.nc" | \
    xargs -P "$NPROC" -I{} bash -c 'compress_file "$@"' _ {}

echo "=== Compression complete at $(date) ==="
echo ""
echo "=== Size summary ==="
echo "Source total:      $(du -sh "$SRC" | cut -f1)"
echo "Destination total: $(du -sh "$DST" | cut -1)"