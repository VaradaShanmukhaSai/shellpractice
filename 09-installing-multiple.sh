#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Please run as root"
    exit 1
else
    echo "Running as root"
fi

Install(){

    if ! dnf list installed $1>/dev/null; then
        echo "Installing $1..."
        dnf install $1 -y>/dev/null
        if [ $? -ne 0 ]; then
            echo "$1 installation is failure"
            exit 1
        else
            echo "$1 installation is success" 
        fi
    else
        echo "$1 is already installed..."
    fi              
}

if [ $# -ge 1 ];then
    for i in $@; do
        Install $i
    done
else
    echo "Please give packages you want to install as arguments"
fi        
