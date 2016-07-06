#!/bin/bash
#set -x

# Based on https://gist.github.com/2206527
# S3 based backup, modified for on disk

# Be pretty
echo -e " "
echo -e "               ______________________________"
echo -e "              |    MySQL Backup Running....  |"
echo -e "              |______________________________|"
echo -e " "

# Basic variables
mysqlpass="XXXXXX"
bucket="s3://bucketname"

# Timestamp (sortable AND readable)
stamp=`date +"%m%d%Y"`

# List all the databases
databases=`mysql -u root -p$mysqlpass -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)"`

# Feedback
echo -e "Dumping to \e[1;32m$bucket/$stamp/\e[00m"

# Loop the databases
for db in $databases; do

  # Define our filenames
  filename="${stamp}_${db}.sql.gz"
  tmpfile="/tmp/$filename"
  object="$bucket/$stamp/$filename"

  # Feedback
  echo -e "\e[1;34m$db\e[00m"

  # Dump and zip
  echo -e "  creating \e[0;35m$tmpfile\e[00m"
  mysqldump -u root -p$mysqlpass --force --opt --databases "$db" | gzip -c > "$tmpfile"

  # Upload
  echo -e "  uploading..."
  # s3cmd put "$tmpfile" "$object"
  cp $tmpfile /backup/SQL/$filename

  # Delete
  rm -f "$tmpfile"

done;

echo -e " "
echo -e "               ______________________________"
echo -e "              |    MySQL Backup Complete!    |"
echo -e "              |______________________________|"
echo -e " "
