#!/bin/bash


IP=$(hostname -i)
MESSAGE=''

echo "Executing command df "
 while IFS= read -r usage part; do
    USAGE=$(echo "$usage" | cut -d '%' -f1)
    if [[ $USAGE -ge 3 ]]; then
        PARTITION=$part
        MESSAGE+="High Disk Usage in $PARTITION : $USAGE% <br>"
    fi
done < <(df -hT | awk 'NR>1{print $6,$7}') 




sh 28-mail.sh "varadashanmukhasai7@gmail.com" "HIGH DISK ALERT ON $IP" "$MESSAGE" "HIGH DISK USAGE" "$IP" "DevOps Team"
