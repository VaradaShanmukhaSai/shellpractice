#!/bin/bash

echo "Please enter username:"
read USERNAME

echo "Please enter Password"
read -s Password

sudo useradd $USERNAME
sudo usermod -g  wheel $USERNAME 