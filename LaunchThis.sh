#!/bin/bash
#This section from here: http://www.cyberciti.biz/tips/shell-root-user-check-script.html
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
./wii-u-gc-adapter&
cd ".."

#find the controller(s)
NumberOfEvents=$(ls /dev/input/ | grep event* -c)

printf(NumberOfEvents)

#launch xboxdrv for each controller



printf "\n\n\nYou can now play games and reconnect controllers. Hit ENTER here when you're done playing.\n"
pause

#clean up the other processes
killall xboxdrv
killall wii-u-gc-adapter
