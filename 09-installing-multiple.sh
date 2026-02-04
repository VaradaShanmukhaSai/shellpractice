#!/bin/bash

R=$'\e[31m'
G=$'\e[32m'
Y=$'\e[33m'
N=$'\e[0m'
LOG_FOLDER=/var/log/shell-script
LOG_FILE=$LOG_FOLDER/$(date +%F)-$0.log


if [ $(id -u) -ne 0 ]; then
    echo "Please run as root"
    exit 1
else
    echo "Running as root"
fi

Install(){

    if ! dnf list installed $1 &>>$LOG_FILE; then
        echo "$Y Installing $1... $N"
        dnf install $1 -y &>>$LOG_FILE;
        if [ $? -ne 0 ]; then
            echo "$R $1 installation is failure $N"
            exit 1
        else
            echo "$G $1 installation is success $N" 
        fi
    else
        echo "$Y $1 is already installed... $N"
    fi              
}

if [ $# -ge 1 ];then
    for i in $@; do
        Install $i
    done
else
    echo "$R Please give packages you want to install as arguments $N "
fi        
