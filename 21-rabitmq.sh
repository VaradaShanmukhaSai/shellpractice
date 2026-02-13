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

cp rabitmq.repo /etc/yum.repos.d/rabitmq.repo
if ! dnf list installed rabbitmq-server &>>$LOG_FILE; then

    dnf install rabbitmq-server -y &>>$LOG_FILE
    VALIDATE $? "Installing RabitMQ "
else
    echo "RabitMQ is already installed"
fi

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling and starting RabitMQ "

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

VALIDATE $? "Creating RabitMQ user and setting password "
