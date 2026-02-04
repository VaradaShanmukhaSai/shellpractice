#!/bin/bash

NUM1=100
NUM2=200

SUM=$(($NUM1+$NUM2))
echo "$SUM"



NAMES=("Shanmukha" "Virat" "Dhoni")
echo "All names are : ${NAMES[@]}"
echo "All names are : ${NAMES[0]}"
echo "All names are : ${NAMES[1]}"
echo "All names are : ${NAMES[2]}"