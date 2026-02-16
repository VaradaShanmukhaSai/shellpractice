#1/bin/bash
user=$(id -u)
R=$'\e[31m'
G=$'\e[32m'
Y=$'\e[33m'
N=$'\e[0m'
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}

USAGE(){
    echo "USAGE: sudo backup Source_dir Dest_dir days ( default 14 )"
}

check_user(){
    if [ $user -ne 0 ]; then
        echo "Please run the command as Sudo"
    fi    
}

if [[ -d $SOURCE_DIR ]]; then
    echo "$SOURCE_DIR exists"
    files=$(find -type f -name "*.log" -mtime +$DAYS)
    if [[ -z $files ]]; then 
        echo "No files in the $SOURCE_DIR older thean $DAYS"
        exit 1
    else
        echo "Found out $files older than $DAYS"
    fi
else
    echo "$SOURCE_DIR does not exist"
    exit 1
fi    

if [[ -d $DEST_DIR ]]; then
    echo "$DEST_DIR exists"
    
else
    echo "$DEST_DIR does not exist"
    exit 1
fi    

BACKUP_FILE="$DEST_DIR/file-$(date +%F %T).tar.gz"

if [[ -f "$BACKUP_FILE "]]; then 
    echo "Backup file created"
else
    echo "Backup file is not created"
    exit 1
fi        

find $SOURCE_DIR -type f -name "*.log" -mtime +$DAYS -print0 | while IFS= read -r -d '' file; do
    echo "Deleting $file"
    tar czf $BACKUP_FILE $file
    echo "
    rm -rf $file 
    done
    