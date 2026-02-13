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
        echo "$G $2 is success.. $N" &>>$LOG_FILE
    else
        echo "$R $2 is failure.. $N" &>>$LOG_FILE
    fi        
}

if ! dnf list installed mongodb-org &>>$LOG_FILE ; then

    cp mongodb.repo /etc/yum.repos.d/mongo.repo

    VALIDATE $? "Copying mongodb.repo"

    dnf install mongodb-org -y &>>$LOG_FILE

    VALIDATE $? "Installing mongodb "

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
else
    echo "$Y Mongodb is already installed $N"

fi    

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE

VALIDATE $? "Starting mongodb " 
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting mongodb " 

