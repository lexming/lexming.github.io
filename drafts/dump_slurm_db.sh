#!/bin/bash

# Database dump script for slurm_acct_db
# Output format: slurm_acct_db-YYYYMMWWDDTHHmmss.sql.gz

# Check if mysqldump is available
if ! command -v mysqldump &> /dev/null; then
    echo "Error: mysqldump command not found. Please install MySQL client tools."
    exit 1
fi

DUMP_DIR="${1:-/mnt/slurm_storage_privat/slurmdbd_dumps}"

SLURM_DB="slurm_acct_db"
SLURM_USER="slurm"
eval "$(slurmdbd_token)"
SLURM_PWD="$TOKEN"

# Generate timestamp of dump file
TIMESTAMP=$(date +"%Y%m%W%dT%H%M%S")
OUTPUT_FILE="${DUMP_DIR}/${SLURM_DB}-${TIMESTAMP}.sql.gz"

# Dump the database
echo "Dumping ${SLURM_DB} to ${OUTPUT_FILE}..."
mysqldump -u "${SLURM_USER}" --password="${SLURM_PWD}" --single-transaction "${SLURM_DB}" | gzip > "${OUTPUT_FILE}"
DUMP_STATE=$?

# Check if dump was successful
if [ $DUMP_STATE -ne 0 ]; then
    echo "Error: Database dump failed"
    rm -f "${OUTPUT_FILE}"
fi

if [ ! -s "${OUTPUT_FILE}" ]; then
    echo "Error: Database dump is empty"
    rm -f "${OUTPUT_FILE}"
    DUMP_STATE=1
fi

# report to infludb
/usr/local/bin/send_influxdb_slurm --data-binary "slurmdb_dump value=$DUMP_STATE $(date +%s%N)"

echo "Database dump completed successfully: ${OUTPUT_FILE}"
