#!/bin/bash

# Set strict modes (optional)
# set -euo pipefail

# 1. Configuration
# ----------------
BACKUP_DIR="/var/backups/mariadb"             # local backup directory
LOGFILE="/var/log/mariadb_backup.log"         # log file path
RCLONE_REMOTE="gdrive:MySQLBackups"           # rclone remote:path (replace gdrive with your remote name)
RETENTION_DAYS=7                              # how many days to keep backups

# List of databases to back up (space-separated)
DATABASES=("CRM") 

# Ensure backup and log directories exist
mkdir -p "$BACKUP_DIR"
touch "$LOGFILE"
chmod 600 "$LOGFILE"

# 2. Initialize logging
echo "===== Backup started at $(date) =====" >> "$LOGFILE" 2>&1

# 3. Loop through databases and dump
for DB in "${DATABASES[@]}"; do
    TIMESTAMP=$(date +"%F_%H%M")
    DUMP_FILE="${BACKUP_DIR}/${DB}_${TIMESTAMP}.sql"

    echo "[$(date)] Dumping database: $DB" >> "$LOGFILE" 2>&1
    # Use mysqldump to create a plain .sql file
    mysqldump --databases "$DB" > "$DUMP_FILE"
    if [ $? -ne 0 ]; then
        echo "[$(date)] ERROR: mysqldump failed for $DB" >> "$LOGFILE"
        continue
    fi

    echo "[$(date)] Uploading $DUMP_FILE to Google Drive (${RCLONE_REMOTE})" >> "$LOGFILE" 2>&1
    # Upload the dump to Google Drive with rclone
    rclone copy "$DUMP_FILE" "$RCLONE_REMOTE"
    if [ $? -ne 0 ]; then
        echo "[$(date)] ERROR: rclone upload failed for $DUMP_FILE" >> "$LOGFILE"
        continue
    fi

    echo "[$(date)] Successfully backed up $DB" >> "$LOGFILE" 2>&1
done

# 4. Cleanup old backups (optional)
echo "[$(date)] Cleaning up backups older than $RETENTION_DAYS days" >> "$LOGFILE" 2>&1
find "$BACKUP_DIR" -maxdepth 1 -mtime +$RETENTION_DAYS -type f -name '*.sql' -delete

echo "===== Backup finished at $(date) =====" >> "$LOGFILE" 2>&1