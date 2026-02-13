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
    echo "Please run as root cart"
    exit 1
else
    echo "Running the script as Root cart"
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
    
    

    curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 

    VALIDATE $? "Downloading Roboshop is "

    cd /app
    rm -rf /app/*
    VALIDATE $? "Removing existing /app contents"

    unzip /tmp/cart.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping "

    npm install 
    VALIDATE $? "Downloading dependencies.."

    
else
    echo "$Y cart nodejs is already installed..$N " &>>$LOG_FILE

fi
if ! id roboshop &>>/dev/null ;then 
    cartadd --system --home /app --shell /sbin/nologin --comment "Roboshop cart" roboshop
    VALIDATE $? "Creating system cart Roboshop"
else
    echo "Roboshop cart is aleady there"
fi

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service 

VALIDATE $? "Creating Systemd service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading service "

systemctl enable cart &>>$LOG_FILE
systemctl start cart &>>$LOG_FILE
VALIDATE $? "Creating a Target to restart at boot and starting cart"



systemctl status cart
VALIDATE $?  "Cart"


