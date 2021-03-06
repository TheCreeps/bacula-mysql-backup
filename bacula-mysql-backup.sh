#!/bin/bash

#Include conf file
. /etc/bacula/bacula-mysql-backup.conf

#check if the dump directory exist , if not , we create him
if [ ! -d "$dump_dir" ]
then
   mkdir -p "$dum_pdir"
fi

#check if the tmp directory exist , if not , we create him
if [ ! -d "$tmp_dir" ]
then
   mkdir -p "$tmp_dir"
fi

#check if the version directory exist , if not , we create him
if [ ! -d "$version_dir" ]
then
   mkdir -p "$version_dir"
fi

       echo "Performing full backup"
      for db in $(echo 'show databases;' | /usr/bin/mysql -s -u "$dbuser" -p"$dbpass" | /bin/egrep -v "$ignreg");
      do
         /usr/bin/mysqldump  --single-transaction --events --opt -u "$dbuser" -p"$dbpass" "$db" > "$tmp_dir/$db.zzz"
         Fosize=`stat -c%s "$tmp_dir/$db.zzz"`
         Cosize=$(<"$version_dir/$db.version")
         echo "Compare bases versions : $db"
         if [ "$Fosize" != "$Cosize" ]; then
           echo "New version detected : Version Backup : $Cosize != new : $Fosize"
           stat -c%s "$tmp_dir/$db.zzz" > "$version_dir/$db.version"
           echo "Backing up ${db} to $dump_dir/$db.sql.bz2"
           echo $(<"$tmp_dir/$db.zzz") | /usr/bin/pbzip2 -9 -c > "$dump_dir/$db.sql.bz2"
         else
           echo "No new version for $db"
         fi done

#Delete all tmp file
rm "$tmp_dir"/*.zzz