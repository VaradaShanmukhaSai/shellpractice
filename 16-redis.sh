#!/bin/bash
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
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

if ! dnf list installed redis &>>$LOG_FILE; then
    dnf module disable redis -y &>>$LOG_FILE
    VALIDATE $? "Disabling redis default"
    dnf module enable redis:7 -y &>>$LOG_FILE
    VALIDATE $? "Enabling redis 7th version"

    dnf install redis -y &>>$LOG_FILE
    VALIDATE $? "Installing redis "

    sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/protected-mode/protected-mode no' /etc/redis/redis.conf
else
    echo "Redis is already installed"
fi
systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis"
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"
