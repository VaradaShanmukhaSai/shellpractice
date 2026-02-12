#!/bin/bash
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGFOLDER/$0.log"
if [ $(id -u) -ne 0 ]; then
    echo "Please run as root user"
    exit 1
else
    echo "Running the script as Root user"
fi

VALIDATE(){
    if [ $1 -eq 0 ]; then 
        echo "$2 is success.." &>>$LOG_FILE
    else
        echo "$2 is failure.." &>>$LOG_FILE
    fi        
}

cp mongodb.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb.repo"

dnf install mongodb -y

VALIDATE $? "Installing mongodb "

systemctl enable mongod 
systemctl start mongod 

VALIDATE $? "Starting mongodb "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod

VALIDATE $? "Restarting mongodb "

