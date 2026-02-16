#!/bin/bash

TEAM=$6
SUBJECT=$2
MESSAGE_BODY=$3
ALERT_TYPE=$4
SERVER=$5
TO_ADDRESS=$1

FINAL_MESSAGE=$(sed -e 's/TEAM/$TEAM/g' -e 's/SUBJECT/$SUBJECT/g' -e 's/MESSAGE/$MESSAGE_BODY/g' -e 's/SERVER/$SERVER/g' template.html)

{
echo "To: $TO_ADDRESS"
echo "Subject: $SUBJECT"
echo "Content-Type: text/html"
echo ""
echo "$FINAL_MESSAGE"
} | msmtp "$TO_ADDRESS"