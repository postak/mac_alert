#/bin/bash



if [ -z "$TOKEN_ID" ] 
then
	echo "Please set Telegram TOKEN_ID environment variable"
	exit 0
fi


CLAMCLOSED=INIT
POWERSUPPLY=INIT

function prevent_sleep() {

    sudo pmset -b disablesleep 1

}

function reset_sleep_and_stop_music() {

    echo "TRAP"
    sudo pmset -b disablesleep 0
#    sudo pmset -b sleep $BATTERY_SLEEP
	kill $PLAY_ALARM_LOOP_PID >/dev/null 2>&1

	exit 0

}

function play_alarm_loop() {

	while :; do afplay sirena.mp3; done 

}

function play_alarm() {
	play_alarm_loop &
	PLAY_ALARM_LOOP_PID=$!
}


function check_powersupply() {

# check if power supply is connected

	LAST_POWERSUPPLY=$POWERSUPPLY
	POWERSUPPLY=`ioreg -l | grep ExternalPowerConnected| cut -d '=' -f2 | sed 's/ //g'`

	if [ $POWERSUPPLY == "Yes" ]
	then
		if [ $POWERSUPPLY != $LAST_POWERSUPPLY ]
		then
			echo "Cable is connected"
		fi
	else

		if [ $POWERSUPPLY != $LAST_POWERSUPPLY ]
		then

			echo "Cable is disconnected"

			# play alarm

			play_alarm

			# send push notification via telegram

			curl -s -X POST "https://api.telegram.org/bot$TOKEN_ID/sendMessage"  \
				-d "chat_id=868584948" -d text="attenzione il cavo della batteria del mba13 e' stato scollegato" > /dev/null
		fi
	fi

}

function check_clam () {

	LAST_CLAMCLOSED=$CLAMCLOSED
	CLAMCLOSED=`ioreg -l | grep 'AppleClamshellState.*='  | cut -d '=' -f2| sed 's/ //g'`

	if [ $CLAMCLOSED == "No" ]
	then
		if [ $CLAMCLOSED != $LAST_CLAMCLOSED ]
		then
			echo "Clam is open"
		fi
	else

		if [ $CLAMCLOSED != $LAST_CLAMCLOSED ]
		then
			echo "Clam is close"

			# play alarm

			play_alarm

			# send message via SMS
			curl -s -X POST "https://api.telegram.org/bot$TOKEN_ID/sendMessage" \
				-d "chat_id=868584948" -d text="Attenzione il coperchio del mba13 e' stato chiuso" > /dev/null
		fi
        fi
}

#--------------------------------------------------------
# main LOOP
#--------------------------------------------------------

CHECK_CLAM=1
CHECK_POWER=1

while(($#)) ; do
	if [ $1 == "-c" ] ; then
		CHECK_CLAM=0
	elif [ $1 == "-p" ] ; then
		CHECK_POWER=0
	elif [ $1 == "-h" ] ; then
		echo "Usage : $0 [-p] [-c]"
		echo "-p do not check for power supply"
		echo "-c do not check for clam closed"
	else
		echo "Usage : $0 [-p] [-c]"
		exit 1
	fi
    shift
done

if [[ $CHECK_POWER -eq 0 && $CHECK_CLAM -eq 0 ]]
then
	echo "Nothing to check"
	exit 1
fi

prevent_sleep

trap reset_sleep_and_stop_music INT


while True
do

	if [[ $CHECK_POWER -eq 1 ]]
	then 
		check_powersupply
	fi

	if [[ $CHECK_CLAM -eq 1 ]]
	then 
		check_clam
	fi

	sleep 1

done
