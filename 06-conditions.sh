#!/bin/bash

num=$1

if [ $num -gt 20 ]; then 
echo "$num is greater than 20"
elif [ $num -eq 20 ]; then 
echo "$num is equal to 20"
else
echo "num is less than 20"
fi