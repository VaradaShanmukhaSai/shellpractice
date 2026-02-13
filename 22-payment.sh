#!/bin/bash
set -u
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
MONGO_HOST="mongodb.saidevops.online"
SCRIPT_DIR=$PWD
R=$'\e[31m'
G=$'\e[32m'
Y=$'\e[33m'
N=$'\e[0m'
if [ $(id -u) -ne 0 ]; then
    echo "Please run as root user"
    exit 1
else
    echo "Running the script as Root user"
fi
mkdir -p $LOG_FOLDER
VALIDATE(){
    if [ $1 -eq 0 ]; then 
        echo "$G $2 is success.. $N" | tee -a $LOG_FILE
    else
        echo "$R $2 is failure.. $N" | tee -a $LOG_FILE
    fi        
}


if ! dnf list installed python3 ;then
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python.."
else
    echo "Already installed "&>>$LOG_FILE
fi

i=$( id -u roboshop &>>$LOG_FILE)

if [ $? -eq 0 ]; then 
   echo "Roboshop user already exists.."
else
    useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop
fi

mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 

VALIDATE $? "Downloading payment code from S3"
cd /app 
rm -rf /app/*
unzip /tmp/payment.zip

VALIDATE $? "Unzipping Payment "

pip3 install -r requirements.txt

cp $SCRIPT_DIR/Payment.service /etc/systemd/system/payment.service

VALIDATE $? "Creating Payment  Systemd service"

systemctl daemon-reload &>>$LOG_FILE
 VALIDATE $? "Reloading Systemd-daemon"

 systemctl enable payment &>>$LOG_FILE

 VALIDATE $? "Enabling Payment"
systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting Payment"