#!/bin/bash

R=$'\e[31m'
G=$'\e[32m'
Y=$'\e[33m'
N=$'\e[0m'

LOG_FOLDER="/home/ec2-user/old-logs"
file_name=$(basename "$0" .sh)

LOG_FILE=$LOG_FOLDER/$file_name

if [[ -d $LOG_FOLDER ]]; then 
    echo "$(date "+%Y-%m-%d %H:%M:%S") |$LOG_FOLDER exists" | tee -a $LOG_FILE
    FILES=$(find $LOG_FOLDER -type f -mtime +14)
    if [[ ! -z $FILES ]]; then 
        echo "$(date "+%Y-%m-%d %H:%M:%S") |Files exist in $LOG_FOLDER older than 14 days" | tee -a $LOG_FILE
        while IFS= read -r file; do
            echo "$(date "+%Y-%m-%d %H:%M:%S") |Removing $file" | tee -a $LOG_FILE
            rm -rf $file
        done <<<$FILES
     else
        echo "$(date "+%Y-%m-%d %H:%M:%S") |There are no files in $LOG_FOLDER older than 14 days" | tee -a $LOG_FILE
     fi
else
    echo " $(date "+%Y-%m-%d %H:%M:%S") | $LOG_FOLDER the directory doesn't exist" | tee -a $LOG_FILE
fi


