#!/bin/bash
Source=$1
Backup=$2
Extension=$3
if [ $# -ne 3 ]; then
	echo "Usage $0 <source_dir> <backup_dir> <file_extension>"
	exit 1
fi
if [ ! -d $Source ]; then
	echo "Error. Source directory does not exist"
	exit 1
fi
if [ ! -d $Backup ];then
	mkdir -p $Backup
	if [ $? -ne 0 ]; then
		echo "Failed to create backup directory"
		exit 1
	fi
fi
files=("$Source"/*."$Extension")
if [ ! -e ${files[0]} ]; then
	echo "No files to backup"
	exit 0
fi
export BACKUP_COUNT=0
tot_size=0
for file in ${files[@]}; do
	size=$(wc -c < $file)
	echo "Size of $(basename $file) is $size bytes"
done
for file in ${files[@]}; do
	base=$(basename $file)
	dest_file="$Backup/$base"
	if [ -f $dest_file ];then
		if [ $file -nt $dest_file ]; then
			cp $file $dest_file
		else
			continue
		fi
	else
		cp $file $dest_file
	fi
	size=$(wc -c < $file)
	tot_size=$((tot_size+size))
	BACKUP_COUNT=$((BACKUP_COUNT+1))
done

REPORT_FILE="$Backup/backup_report.log"

{
    echo "Backup Summary Report"
    echo "====================="
    echo "Total files backed up : $BACKUP_COUNT"
    echo "Total backup size     : $tot_size bytes"
    echo "Backup directory      : $Backup"
    echo "Backup date           : $(date)"
} > "$REPORT_FILE"

echo "Backup completed successfully."
echo "Report saved at: $REPORT_FILE"

