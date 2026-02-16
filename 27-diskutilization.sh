#!/bin/bash


IP=$(hostname -i)
MESSAGE=''
if [[ ! -z $DISK_FREE ]]; then 
    echo "Executing command df "
   df -hT | awk 'NR>1{print $6,$7}' |while IFS= read -r usage part ; do
        USAGE=$(echo "$usage" |cut -d '%' -f1 )
        if [[ $USAGE -ge 3 ]]; then 
            PARTITION=$part
            MESSAGE+="High Disk Usage in $PARTITION : $USAGE% <br>"
        fi
    done 
else
    echo "No mounts on the disk "
fi 


sh 28-mail.sh "varadashanmukhasai7@gmail.com" "HIGH DISK ALERT ON $IP" "$MESSAGE" "HIGH DISK USAGE" "$IP" "DevOps Team"
