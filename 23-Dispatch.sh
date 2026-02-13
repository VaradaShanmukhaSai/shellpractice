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


if ! dnf list installed golang ;then
    dnf install golang -y &>>$LOG_FILE
    VALIDATE $? "Installing GoLang.."
else
    echo "Already installed "&>>$LOG_FILE
fi

i=$( id -u roboshop)

if [ $i -eq 0 ]; then 
   echo "Roboshop user already exists.."
else
    useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop
fi

mkdir -p /app

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip 

VALIDATE $? "Downloading dispatch code from S3"
cd /app 
unzip /tmp/dispatch.zip

VALIDATE $? "Unzipping Dispatch "

go mod init dispatch
go get 
go build

VALIDATE $? "Dispatch Built "

cp $SCRIPT_DIR/Dispatch.service /etc/systemd/system/dispatch.service

VALIDATE $? "Creating Dispatch  Systemd service"

systemctl daemon-reload &>>$LOG_FILE
 VALIDATE $? "Reloading Systemd-daemon"

 systemctl enable dispatch &>>$LOG_FILE

 VALIDATE $? "Enabling dispatch"
systemctl start dispatch &>>$LOG_FILE
VALIDATE $? "Starting dispatch"