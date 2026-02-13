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

if ! dnf list installed nodejs &>>$LOG_FILE ; then 
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs" 
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs 20 th version"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"

    mkdir -p /app
    
    

    curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 

    VALIDATE $? "Downloading Roboshop is "

    cd /app
    rm -rf /app/*
    VALIDATE $? "Removing existing /app contents"

    unzip /tmp/user.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping "

    npm install 
    VALIDATE $? "Downloading dependencies.."

    
else
    echo "$Y User nodejs is already installed..$N " &>>$LOG_FILE

fi
if ! id roboshop &>>/dev/null ;then 
    useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop
    VALIDATE $? "Creating system user Roboshop"
else
    echo "Roboshop user is aleady there"
fi

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service 

VALIDATE $? "Creating Systemd service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading service "

systemctl enable user &>>$LOG_FILE
systemctl start user &>>$LOG_FILE
VALIDATE $? "Creating a Target to restart at boot and starting user"



systemctl status user
VALIDATE $?  "Usser"


