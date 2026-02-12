#!/bin/bash
set -e
ami_id="ami-0220d79f3f480ecf5"
sg_id="sg-0302f0f6b2b791c61"
ZONE_ID="Z10085282I8SI65NGA9QJ"
DOMAIN_NAME="saidevops.online"

for instance in $@; do
    INSTANCE_ID=$( aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type t3.micro \
        --security-group-ids $sg_id \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' \
        --query 'Instances[0].InstanceId' \
        --output text )
    echo "$INSTANCE_ID is created for instance $instance"    

    if [ $instance == "frontend" ]; then
          IP=$( aws ec2 describe-instances \
          --instance-ids $INSTANCE_ID \
          --query 'Reservations[].Instances[].PublicIpAddress' \
          --output text )
          RECORD_NAME=$DOMAIN_NAME
    else
        IP=$( aws ec2 describe-instances \
        --instance-ids i-0a1b2c3d4e5f6g7h8 \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text )
        RECORD_NAME=$instance.$DOMAIN_NAME
    fi

    echo "$instance is created with IP: $IP"
       aws route53 change-resource-record-sets \
       --hosted-zone-id $ZONE_ID \
       --change-batch '
       {
        "Comment": "Update A record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
        }
        '
    echo "$instance A record is created with $RECORD_NAME"

done
