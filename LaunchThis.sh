#!/bin/bash


#DOUBLE CHECK THESE VALUES IF YOU HAVE PROBLEMS:


#the "Input device name" from "sudo evtest /dev/input/eventXX", after drivers run and the proper event number is determined via "ls /dev/input | grep event*"
WiiUGCName="Wii U GameCube Adapter Port"
#the time (in seconds) your computer will take to add a controller to the list of input devices
SleepTime=1
#The time (in seconds) your computer will take to print the output of a single device
evtestTime=0.1




#functions section
#This root-check copied from here: http://www.cyberciti.biz/tips/shell-root-user-check-script.html
# Init
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

#this function copied from user4815162342 here: http://stackoverflow.com/questions/33517928/linux-and-bash-how-can-i-get-the-device-name-of-an-input-device-event/33527233#33527233
evtest_and_exit() {
    local evtest_pid
    evtest /dev/input/event$i &
    evtest_pid=$!
    sleep $evtestTime  # give evtest time to produce output
    kill $evtest_pid
}


function pause(){
	read -p "Press ENTER to continue\n"
}

#THE KEY BINDINGS ARE DOWN HERE
function Launch_xboxdrv(){
	xboxdrv --evdev /dev/input/event$i --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RX=x2,ABS_RY=y2 --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_B=x,BTN_X=y,BTN_A=a,BTN_Y=b,BTN_START=start,BTN_TL=lb,BTN_TR2=rb --mimic-xpad --silent --evdev-no-grab &
}
#544=du,545=dd,546=dl,547=dr


#main code here

cd "$(dirname "$0")"
#install prerequisites
apt-get install libudev-dev libusb-dev xboxdrv evtest git

#git clone the gamecube adapter drivers
git clone https://github.com/ToadKing/wii-u-gc-adapter

#load module
modprobe uinput

#make GC adapter driver
cd "wii-u-gc-adapter"
make
cd ".."

NumberOfEventsWithoutAdapter=$(ls /dev/input | grep -c event*)

#run the GC adapter driver
cd "wii-u-gc-adapter"
./wii-u-gc-adapter >../log.log 2>../log.log &
cd ".."

sleep $SleepTime

#find the controller(s)
NumberOfEvents=$(ls /dev/input | grep -c event*)

echo "Events before adapter: $NumberOfEventsWithoutAdapter"
echo "Events after adapter: $NumberOfEvents"

#launch xboxdrv for each controller
i=$NumberOfEventsWithoutAdapter
while [ $i -lt $NumberOfEvents ]; do
	OccurrencesOfName=$(evtest_and_exit | grep -c "$WiiUGCName")
	if [ $OccurrencesOfName -gt 0 ]; then
		echo "Controller found. Launching Xboxdrv."
		Launch_xboxdrv
	fi
	let i=i+1
done

sleep 1
printf "\n\nYou can now play games and reconnect controllers. Hit ENTER here when you're done playing.\n"
pause

#clean up the other processes
killall xboxdrv
killall wii-u-gc-adapter
