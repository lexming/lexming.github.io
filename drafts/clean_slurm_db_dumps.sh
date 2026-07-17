#!/bin/bash

# Cleanup script for old slurm database dumps
# Retention policy:
# - Keep 1 dump per hour for the past day
# - Keep 1 dump per day for the past week
# - Keep 1 dump per week for the past month

DUMP_DIR="${1:-/mnt/slurm_storage_privat/slurmdbd_dumps}"
SLURM_DB="slurm_acct_db"

# Find all dump files in current directory
DUMP_FILES=$(find "$DUMP_DIR" -maxdepth 1 -name "$SLURM_DB-*.sql.gz" -type f | sort)

if [ -z "$DUMP_FILES" ]; then
    echo "No dump files found to clean up."
    exit 0
fi

echo "Cleaning up old dump files..."

# Function to extract timestamp from filename
extract_timestamp() {
    # format $SLURM_DB-YYYYMMWWDDThhmmss.sql.gz
    echo "${1/*${SLURM_DB}-}" | cut -c-17
}
list_unique_timestamps() {
    while read -r filename; do
        extract_timestamp "$filename" | cut -c 1-"$1"
    done <<< "$DUMP_FILES" | sort -u -r
}

# Function to process files by time period
process_files() {
    local label="$1"
    local keep_count="$2"
    local ignore_interval="$3"

    echo "Processing $label interval..."

    # Get unique timestamps for this interval
    readarray -t unique_timestamps < <(list_unique_timestamps "$keep_count")

    # Keep only the latest file for each interval
    for ((t="$ignore_interval"; t<${#unique_timestamps[@]}; t++)); do
        bucket="${unique_timestamps[$t]}"
        readarray -t matching_files < <(find "${DUMP_DIR}" -name "${SLURM_DB}-${bucket}*" -print | sort -r)

        # Keep only the most recent file
        if [ ${#matching_files[@]} -gt 1 ]; then
            echo "  Keeping: ${matching_files[0]}"
            for ((i=1; i<${#matching_files[@]}; i++)); do
                echo "  Removing: ${matching_files[$i]}"
                rm -f "${matching_files[$i]}"
            done
        fi
    done
}

# Process files by different time intervals
process_files "hour" 13 0  # YYYYMMWWDDThh format (13 chars); ignore first 0 hours
process_files "day" 10 1  # YYYYMMWWDD format (10 chars); ignore first 1 days
process_files "week" 8 4 # YYYYMMWW format (8 chars); ignore first 4 weeks
process_files "month" 6 6 # YYYYMM format (6 chars); ignore first 6 months

echo "Cleanup completed."
