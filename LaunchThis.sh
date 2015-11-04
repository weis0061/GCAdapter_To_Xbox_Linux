#!/bin/bash

#DOUBLE CHECK THESE VALUES IF YOU HAVE PROBLEMS:

#the "Input device name" from "sudo evtest /dev/input/eventXX", after drivers run and the proper event number is determined via "ls /dev/input | grep event*"
WiiUGCName="Wii U GameCube Adapter Port"

#the time (in seconds) your computer will take to add a controller to the list of input devices
SleepTime=1;









#This root-check copied from here: http://www.cyberciti.biz/tips/shell-root-user-check-script.html
# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi


function pause(){
	read -p "Press ENTER to continue\n"
}


cd "$(dirname "$0")"
#install prerequisites
apt-get install libudev-dev libusb-dev xboxdrv evtest

#git clone the other stuff
git clone https://github.com/ToadKing/wii-u-gc-adapter

#load module
modprobe uinput

#make GC adapter driver
cd "wii-u-gc-adapter"
make
cd ".."

#run the GC adapter driver
cd "wii-u-gc-adapter"
./wii-u-gc-adapter >/dev/null 2>/dev/null &
cd ".."

sleep $SleepTime

#find the controller(s)
NumberOfEvents=$(ls /dev/input | grep -c event*)

echo "Number of input devices: $NumberOfEvents"

#launch xboxdrv for each controller
NumberOfEvents=$(ls /dev/input | grep -c event*)
i=0
while [ $i < $NumberOfEvents ]; do
	echo "loop"
	OccurrencesOfName=$(evtest /dev/input/event$i | grep -c "$WiiUGCName"&)
	echo "Occurrences: $OccurrencesOfName"
	if [ $OccurrencesOfName>0 ]; then
		echo "Controller found"
		#launch xboxdrv here
	else
		echo "no controller found"
	fi
	let i=i+1
done
	
sleep 1


printf "\n\n\nYou can now play games and reconnect controllers. Hit ENTER here when you're done playing.\n\n"
pause

#clean up the other processes
killall xboxdrv
killall wii-u-gc-adapter
