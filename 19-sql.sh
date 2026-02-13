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

if ! dnf list installed mysql-server &>>$LOG_FILE; then
    dnf install mysql-server -y &>>$LOG_FILE
    VALIDATE $? "Installing MySQL"
else
    echo "MySQL is already installed..$Y Skipping $N"
fi
systemctl enable mysqld &>>$LOG_FILE

VALIDATE $? "Enabling sqld"
systemctl start mysqld 
VALIDATE $? "Starting sqld" 
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting password for MySQL Root User"
