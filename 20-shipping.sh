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
if ! dnf list installed maven &>>$LOG_FILE ; then 
    echo "Installing Maven "
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"

else
   echo "Maven is already installed..$Y Skipping $N"
fi

i=$( id roboshop )

if [ $i -eq 0 ]; then
    echo "Roboshop user already exists"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
fi

mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Downloading Shipping..."
cd /app 
rm -rf /app/*
unzip /tmp/shipping.zip
VALIDATE $? "Unzipping Shipping.."


cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service

VALIDATE $? "Creating Shipping service"

systemctl daemon-reload &>>$LOG_FILE

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling Shipping service"
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting Shipping service"


if ! dnf list installed mysql &>>$LOG_FILE; then

    dnf install mysql -y &>>$LOG_FILE
    VALIDATE $? "Installing MySQL "
else
    echo "MySQL already exists $Y Skipping $N"
fi

INDEX=$( mysql -h mysql.saidevops.online -uroot -pRoboShop@1 -e 'use cities')
if [ $INDEX -ne 0 ]; then 
    mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/master-data.sql
else
    ech "Products alraedy loaded.."
fi

systemctl restart shipping

VALIDATE $? "Starting Shipping"
