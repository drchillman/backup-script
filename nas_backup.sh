#!/bin/bash

config="false"


if [ "$2" = "delete" ]; then
echo "WARNING DELETE COMMAND ISSUED"
fi
 
if [ "$1" = "hdd" ]; then
rootdir="/home/chris/nasbackup/rsync/"
echo "Using HDD"
config="true"
fi

if [ "$1" = "usb" ]; then
rootdir="/media/backup_seagate/rsync/"
echo "Using Seagate USB drive"
config="true"
fi

if [ "$config" = "false" ]; then
echo "Usage: $0 hdd | usb"
exit 1
fi

if [ ! -d "$rootdir" ]; then
	echo "Backup path does not exist. Exit."
	exit 1
fi

logdir="logs/"
logfile="cjhbackup.log"

logpath="$rootdir$logdir$logfile"
echo "-------------------"  >> "$logpath"
echo "`date +%y%m%d:%H%M%S`: $0 $1 called." >> "$logpath"


for sharename in Scripts Music StaticStorage Documents Pictures; do
#for sharename in Scripts Music StaticStorage; do
#for sharename in Scripts; do
#for sharename in Scripts Music StaticStorage Documents; do
#for sharename in Scripts StaticStorage Pictures; do

echo -e "\033[0;31m`date` \033[0m"
echo -e "Backing up share: \033[0;31m$sharename\033[0m..."
echo "logpath=$logpath"

startdate=`date +%y%m%d`

destdir="$rootdir$sharename/"

if [ ! -d "$destdir" ]; then
	echo "$destdir does not exist - making"
	mkdir $destdir
fi

echo "destdir=$destdir"

rsync_err="$rootdir$logdir$sharename-rsync-err-$startdate.log"
rsync_prog="$rootdir$logdir$sharename-rsync-prog-$startdate.log"

#more directory checking?

echo "----"  >> "$logpath"
echo "`date +%y%m%d:%H%M%S`: Sharename=$sharename" >> "$logpath"
echo "`date +%y%m%d:%H%M%S`: startdate=$startdate" >> "$logpath"
echo "`date +%y%m%d:%H%M%S`: rsync_err=$rsync_err" >> "$logpath"
echo "`date +%y%m%d:%H%M%S`: rsync_prog=$rsync_prog" >> "$logpath"
echo "`date +%y%m%d:%H%M%S`: destdir=$destdir" >> "$logpath"

if [ ! -d "$destdir" ]; then
	echo "`date +%y%m%d:%H%M%S`: destdir not found - exit 1" >> "$logpath"
	exit 1
fi

echo "-------------------"  >> "$rsync_prog"
echo "`date +%y%m%d:%H%M%S`: $0 $1 called." >> "$rsync_prog"
echo "`date +%y%m%d:%H%M%S`: Sharename=$sharename" >> "$rsync_prog"
echo "`date +%y%m%d:%H%M%S`: startdate=$startdate" >> "$rsync_prog"
echo "`date +%y%m%d:%H%M%S`: destdir=$destdir" >> "$rsync_prog"

echo "-------------------"  >> "$rsync_err"
# Err Logging to reduce size of "empty" logfile (should be 20 bytes)
#echo "`date +%y%m%d:%H%M%S`: $0 $1 called." >> "$rsync_err"
#echo "`date +%y%m%d:%H%M%S`: Sharename=$sharename" >> "$rsync_err"
#echo "`date +%y%m%d:%H%M%S`: startdate=$startdate" >> "$rsync_err"
#echo "`date +%y%m%d:%H%M%S`: destdir=$destdir" >> "$rsync_err"


rsync --exclude '*.@__thumb*' -ave ssh "admin@192.168.0.8:/share/$sharename/" "$destdir"  2>> "$rsync_err" 1>> "$rsync_prog"
if [ $? -eq 0 ]; then
    echo "`date +%y%m%d:%H%M%S`: rsync ($sharename) returned OK($?)" >> "$logpath"
    echo "rsync ($sharename) returned OK($?)"
else
    echo "`date +%y%m%d:%H%M%S`: rsync ($sharename) returned FAIL ($?)" >> "$logpath"
    echo "rsync ($sharename) returned FAIL($?)"
	final_data=`tail $rsync_err`
	echo -e "`date +%y%m%d:%H%M%S`: ERR: \033[0;31m $final_data £\033[0m" >> "$logpath"
	echo -e "`date +%y%m%d:%H%M%S`: ERR: \033[0;31m $final_data £\033[0m"
	final_data=`tail $rsync_prog`
	echo "`date +%y%m%d:%H%M%S`: Prog: $final_data" >> "$logpath"
	echo "`date +%y%m%d:%H%M%S`: Prog: $final_data"
fi

echo -e "\033[0;31m`date` \033[0m"
echo
sync
done


echo "`date +%y%m%d:%H%M%S`: $0 $1 finished." >> "$logpath"
echo "-------------------"  >> "$logpath"


