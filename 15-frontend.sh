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

if ! dnf list installed nginx &>>$LOG_FILE; then 
    echo "Nginx is not installed"
    dnf module disable nginx -y &>>$LOG_FILE
    VALIDATE $? "Disabling nginx..."
    dnf module enable nginx:1.24 -y
    VALIDATE $? "Enabling Nginx 1.24..."
    dnf install nginx -y
    VALIDATE $? "Installing Nginx.."

    rm -rf /usr/share/nginx/html/*

    VALIDATE $? "Removing existing nginx content"

    curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

    VALIDATE $? "Downloading the frontend"

    cd /usr/share/nginx/html
    unzip  /tmp/frontend.zip

    rm -rf /etc/nginx/nginx.conf

    cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf

    systemctl restart nginx &>>$LOG_FILE

    VALIDATE $? "Nginx is configured for first time"

else
    echo "Nginx is already installed ..$Y Skipping $N"
fi


systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling nginx"
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting Nginx is "

systemctl status nginx &>>$LOG_FILE

VALIDATE $? "Nginx"

