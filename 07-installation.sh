#!/bin/bash

if [ $(id -u) -ne 0 ]; then 
echo "Run this script as root user"
exit 1
else
echo "Executing as Root.."
fi

dnf install nginx -y
if [ $? -ne 0 ]; then 
echo "Installing Nginx is failure"
exit 1
else
echo "Installing Nginx is success"
