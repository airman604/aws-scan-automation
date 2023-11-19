#!/bin/bash

# Stop on error
set -e

# need ENV: S3_BUCKET, S3_PREFIX
if [ -z "$S3_BUCKET" -o -z "$S3_PREFIX" ]; then
    echo "ERROR: missing S3_BUCKET and/or S3_PREFIX environment variables"
    exit 1
fi

DT=$(date '+%Y-%m-%d-%H%M')
OUTPUT_DIR="scout-${DT}"
OUTPUT_FILE="$OUTPUT_DIR.tar.gz"
S3_DEST="s3://$S3_BUCKET/$S3_PREFIX/$OUTPUT_FILE"

echo "Running ScoutSuite scan"
# output directory
[ -d "$OUTPUT_DIR" ] || mkdir "$OUTPUT_DIR"
scout aws --report-dir "$OUTPUT_DIR" "$@"

# save report to S3
echo "Saving ScoutSuite report to $S3_DEST"
tar czf "$OUTPUT_FILE" "$OUTPUT_DIR"
aws s3 cp --quiet "$OUTPUT_FILE" "$S3_DEST"
