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
    dnf install $1 -y
    if [ $? -ne 0 ]; then 
        echo "Installing $1 is failure"
        exit 1
    else
        echo "Installing $1 is success"
    fi 
else
    echo "$1 is already installed"
fi    