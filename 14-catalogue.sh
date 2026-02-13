#!/bin/bash
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
MONGO_HOST="mongodb.saidevops.online"
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

if ! dnf list installed nodejs &>>$LOG_FILE ; then 
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs" 
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs 20 th version"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"

    mkdir -p /app
    
    useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop

    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

    VALIDATE $? "Downloading Roboshop is "

    cd /app


    unzip /tmp/catalogue.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping "

    npm install 
    VALIDATE $? "Downloading dependencies.."

    cp catalogue.service /etc/systemd/system/catalogue.service 

    VALIDATE $? "Creating Systemd service"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Reloading service "

    cp mongodb.repo /etc/yum.repos.d/mongo.repo

    

    dnf install mongodb-mongosh -y &>>$LOG_FILE

    VALIDATE $? "Installing mongodb client "

    mongosh --host $MONGO_HOST </app/db/master-data.js &>>$LOG_FILE

    VALIDATE $? "Running master-data"

else
    echo "$Y Catalogue nodejs is already installed..$N " &>>$LOG_FILE

systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Creating a Target to restart at boot and starting catalogue"

fi