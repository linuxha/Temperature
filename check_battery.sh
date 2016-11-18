#!/usr/bin/env bash

#
OKAY=0
WARNING=1
CRITICAL=2
UNKNOWN=3

# Defaults
host="mozart.uucp"
critical=25
warn=35
timeout=0
nDevices=14
topic='smartthings/+/battery'

version() {
    echo "check_battery.sh v1.1"
}

# # Interesting way to get a all the messages from a wild card topic
# # (know the # of topics)
# $ mosquitto_sub -v -C 14 -t 'smartthings/+/battery'
# smartthings/Motion Sensor/battery 100
# smartthings/Multipurpose Sensor A/battery 66
# smartthings/Multipurpose Sensor B/battery 55
# smartthings/Z-Wave Smoke Alarm 1/battery 92
# smartthings/iContact Sensor/battery 77
# smartthings/Z-Wave Smoke CO Alarm/battery 92
# smartthings/Z-Wave Smoke Alarm 2/battery 85
# smartthings/Crawl Space Contact Sensor/battery 77
# smartthings/Crawl Space Temp-Humidity Sensor/battery 66
# smartthings/Garge Side Door iContact Sensor/battery 77
# smartthings/Front Porch Temp-Humidity Sensor/battery 66
# smartthings/LR Multipurpose Sensor A/battery 66
# smartthings/Den Multipurpose Sensor B/battery 66
# smartthings/WR Motion Sensor/battery 100
# $

#
usage () {
cat << EOF
check_battery.sh

Plugin Options

A well written plugin should have –help as a way to get verbose help.

There are a few reserved options that should not be used for other purposes:

    -V version (--version) ;
    -h help (--help) ;
    -t timeout (--timeout) ;
    -w warning threshold (--warning) ;
    -c critical threshold (--critical) ;
    -H hostname (--hostname) ;
    -v verbose (--verbose).
    -n number of devices
    -T topic

In addition to the reserved options above, some other standard options are:

    -C SNMP community (--community) ;
    -a authentication password (--authentication) ;
    -l login name (--logname) ;
    -p port or password (--port or --passwd/--password) monitors operational ;
    -u url or username (--url or --username).
EOF
}


# Getopt here
# The leading colon turns on silent error reporting
while getopts ":H:c:w:t:T:n:vVh" OPTION
do
    case $OPTION in
	H)
	    host=${OPTARG}
	    ;;
        c)
            critical=${OPTARG}
            ;;
	w)
	    warn=${OPTARG}
	    ;;
	t)
	    timeout=${OPTARG}
	    ;;
	T)
	    topic=${OPTARG}
	    ;;
	n)
	    nDevices=${OPTARG}
	    ;;
	v)
	    verbose=1
	    ;;
	V)
	    version
	    exit ${UNKNOWN}
	    ;;
        h)
	    echo "Help ($@)"
            usage
            exit ${UNKNOWN}
            ;;
        *)
	    echo "CLI: $@"
            usage
            exit ${UNKNOWN}
            ;;
    esac
done
# shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

declare -A aarr=()

# rx will contain the values returned by the mqtt subscription
# there should be about 14 topics & values
# I'm assuming local host and port 1883 (defaults)
rx=$(mosquitto_sub -v -C ${nDevices} -t ${topic})

# take rx and parse it into line
while IFS= read line
do
    # Parse the topic from the value
    #echo "Line: ${line}"
    # get the value after the last space
    v="${line##* }"
    # get the topic (everything but last space and value)
    t="${line% *${v}}"
    # Grr, topics may contain spaces, convert or we can't de-index them later
    t="${t// /.}"
    # Take the topic and the value and put it into an array
    aarr["${t}"]="${v}"
done <<< "${rx}"

msg="CRITICAL - Device batteries need to be replaced:"
notOkay=0
# check that we have ${nDevices}
if [ ${nDevices} -ne ${#aarr[*]} ]; then
    echo "Incorrect number of devices: ${#aarr[*]}"
else
    for idx in ${!aarr[*]}
    do
        t=${aarr[$idx]}
	# 65.20 -> 65
	#t=${t%.*}
	t=${t%%.*}
	if [ ${t} -le ${critical} ]; then
	    IFS='/' read -r -a array <<< "$idx"
	    t="${array[1]//./ }"
	    #echo -e "Less than %25Replace:\nDevice: '${array[1]}' = ${aarr[$idx]}"
	    msg="${msg}\nCRITICAL - Replace device: '${t}' = ${aarr[$idx]}%"
	    notOkay=1
	fi
    done
fi

if [ ${notOkay} -ne 0 ]; then
    echo -e "${msg}"
    exit ${CRITICAL}
else
    echo "OKAY - Device batteries are okay"
    exit ${OKAY}
fi

# -[ Notes ]--------------------------------------------------------------------
#
# Hosts:
# Plugin  Host
# return  status
# code
# 0       UP
# 1       DOWN
# Other   Maintains last known state
# 
# Services:
# Return  Service
# code    status
# 0       OK
# 1       WARNING
# 2       CRITICAL
# 3       UNKNOWN
# Other   CRITICAL : unknown return code
