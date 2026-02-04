#!/bin/bash

mod=$1

if [ $(id -u) -ne 0 ]; then 
echo "Run this script as root user"
exit 1
else
echo "Executing as Root.."
fi

dnf list installed $1
if [ $? -ne 0 ]; then 
    dnf install nginx -y
    if [ $? -ne 0 ]; then 
        echo "Installing Nginx is failure"
        exit 1
    else
        echo "Installing Nginx is success"
    fi 
else
    $1 is already installed
fi    