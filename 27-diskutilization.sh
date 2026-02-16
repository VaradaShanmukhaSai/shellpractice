#!/bin/bash

DISK_FREE=$(df -hT | awk 'NR>1 {print}')
IP=$(hostname -i)
MESSAGE=''
if [[ ! -z $DISK_FREE ]]; then 
    echo "Executing command df "
    while IFS= read -r line ; do
        USAGE=$(echo $line | awk '{print $6}' | cut -d '%' -f1 )
        if [[ $USAGE -ge 3 ]]; then 
            PARTITION=$(echo $line | awk '{print $7}')
            MESSAGE+="High Disk Usage in $PARTITION : $USAGE% <br>"
        fi
    done <<<$DISK_FREE
else
    echo "No mounts on the disk "
fi 


sh 28-mail.sh "varadashanmukhasai7@gmail.com" "HIGH DISK ALERT ON $IP" "$MESSAGE" "HIGH DISK USAGE" "$IP" "DevOps Team"
