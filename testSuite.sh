#!/bin/bash

#./testSuite.sh -t ftkImager -v -s ee -d xx -o f

launchCommand(){
	#launchCommand (command, command_explenation, output_path)
	eval command="$1"
	eval output_path=$3
	STARTTIME=$(date +%s)
	command_result=$(eval ${command} 2>&1)
	ENDTIME=$(date +%s)
	if [ $verbose ]; then eval command_explenation="$2"
	else command_explenation="\n" 
	fi
	echo -e "\n>> $(($ENDTIME - $STARTTIME))s\t"${command}"\t"$command_result"\t"${command_explenation} >> $output_path.log
}

#LOG_PATH=$(pwd)/logs
#LOG_FILE=$LOG_PATH/logFile

LOG_PATH="./logs/"
rm -r $LOG_PATH
mkdir -p $LOG_PATH -v

#Test options#
ALL="all"
VERACRYPT=veraCrypt
GUYMAGER=guymager
FTKIMAGER=ftkImager
FLAGS='t:o:s:d:v'

while getopts $FLAGS flag;
do
    case "$flag" in
	t)	test=${OPTARG}
		echo "test: $test"
	;;
    o)	output=${OPTARG}
		echo "output: $output"
	;;
    s) 	source=${OPTARG}
		echo "source $source"
	;;
    d) 	destination=${OPTARG}
		echo "destination $destination"
	;;
	v) 	verbose=1
	;;
    esac
done

if [ ! "$test" ]; then
  	echo "test option -t {"$ALL, $VERACRYPT, $GUYMAGER, $FTKIMAGER"} must be provided"
    echo "$usage" >&2
	exit 1
fi
#if [ ! "$output" ]; then 
#	$output=${LOG_PATH}logFile
#fi

if [ ! "$source" ] && [ ! "$destination"]; then
	echo "Locate source and destination device from: "
	lsblk -e07
	read -p "Indicate source's path: " source
	echo "You selected '$source' as source."
	read -p "Indicate drive's path: " destination
	echo "You selected '$destination' as destination."
elif [ ! "$source" ]; then
	echo "Locate source device from: "
	lsblk -e07
	read -p "Indicate drive's path: " source
	echo "You selected '$source' as source device."

elif [ ! "$destination" ]; then
	echo "Locate destination device from: "
	lsblk -e07
	read -p "Indicate drive's path: " $destination
	echo "You selected '$destination' as destination."
fi

echo -e "<$test> :: $(date)\n" >> ${output}.log

case $test in

  veraCrypt)
	#Mount volume
	command="veracrypt --volume $source -l x -a -p Password -e -b"
	command_explenation="\n\tMount a --volume called $source using the -p password Password, as the drive letter X -a automatically. When finnished open an explorer window -e and beep -b\n"
	launchCommand "\${command}" "\${command_explenation}" "\${output}"
	#Create volume
	command="veracrypt -t -c --volume-type=normal /dev/sdb1 --encryption=aes --hash=sha-512 --filesystem=ext4 -p XXXXXXX --pim=0 -k "" --random-source=/dev/urandom"
	command_explenation="\n\tCreate a 'normal' volume in $source using aes encrytion, sha-512, filesystem ext4, password XXXXXXX, pim 0 and no keyFile\n"
	launchCommand "\${command}" "\${command_explenation}" "\${output}"
	#Dismount volume
	command="veracrypt -d $source"
	command_explenation="\n\tDismount $source volume\n"
	launchCommand "\${command}" "\${command_explenation}" "\${output}"
	;;

  ftkImager)
	#Image
  	command="ftkimager $source $destination --case-number PESAE001 --evidence-number 001 --verify --frag 2GB --e01"
	command_explenation="\n\tAcquire and verify $source image (.e0 format) in $destination with maximum size of 2GB\n"
	launchCommand "\${command}" "\${command_explenation}" "\${output}"	
	
	#Image
	command="ftkimager $source $destination --case-number 1700345498 --evidence-number ITEM001 --e01 --compress 9"
	command_explenation="\n\tThe decrypted logical volume $source is being captured live at $destination because the container is encrypted with Bitlocker"
	launchCommand "\${command}" "\${command_explenation}" "\${output}"	
    ;;

  guymager)
   	command="sleep 2"
	command_explenation="\n\tsleep tool\n"
	launchCommand "\${command}" "\${command_explenation}" "\${output}"
    ;;

    all)

    ;;

esac