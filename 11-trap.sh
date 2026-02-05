#!/bin/bash
set -e
trap 'echo "Hi there is an error in $LINENO at command $BASH_COMMAND"' ERR

echo "This is good"
snf install nginx
echo "Bye"
