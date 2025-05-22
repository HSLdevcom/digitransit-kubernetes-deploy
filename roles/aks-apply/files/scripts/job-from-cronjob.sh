#!/usr/bin/env bash

# Exit script if errors occur.
set -e

SCRIPT_DIRECTORY="$(dirname "$(realpath "$0")")"

usage() {
  echo "usage: $0 path/to/cron/job.yml new-job-name-here"
}

# Check if two arguments are given.
if [ -z "$2" ] ; then
  usage
  exit 1
fi

# Create the output file path.
OUTPUT_JOB_NAME=$2
mkdir -p $SCRIPT_DIRECTORY/output
OUTPUT_FILE_PATH=$SCRIPT_DIRECTORY/output/$OUTPUT_JOB_NAME.yml

# Copy the file.
cp $1 $OUTPUT_FILE_PATH

# Change kind: CronJob to kind: Job.
sed -z "s/kind: CronJob/kind: Job/" -i $OUTPUT_FILE_PATH

# Remove CronJob-specific spec fields.
sed -z "s/spec:.*\n  jobTemplate:\n    spec:/spec:/" -i $OUTPUT_FILE_PATH

# Change CronJob name to the given job name.
sed -z "s/otp-[A-Za-z]*-builder-[A-Za-z]*-v[0-9]/$OUTPUT_JOB_NAME/g" -i $OUTPUT_FILE_PATH

# Change split build type.
sed -z "s/USE_PREBUILT_STREET_GRAPH/NO_SPLIT_BUILD/" -i $OUTPUT_FILE_PATH

echo "Created file: $OUTPUT_FILE_PATH"
