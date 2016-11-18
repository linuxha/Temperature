#!/bin/bash

################################################################################
# gettopicval.sh - get topic value
#                  read an MQTT topic, get the value, output the value to
#                  the device file
#                - this script should be run once an hour from cron
################################################################################
# There are 2 mosquitto_subs, use the /usr/local/bin/mosquitto_sub
export PATH=/usr/local/bin:${PATH}

TDIR="${HOME}/dev/Temperature/"
topics="${HOME}/dev/Temperature/topics"

################################################################################
rx=$(cat ${topics} | egrep -v '^#|^$')	# skip comments and blank lines
dateStr=$(date +%Y%m%d)			# 20161117

# ------------------------------------------------------------------------------
while IFS= read topic
do
    echo "Topic: $topic"

    # get the first part 'smartthings/device name/sensor'
    device="${topic%/*}"		# 'smartthings/device name'
    # get the last part
    device="${device##*/}"		# 'device name'
    # replace spaces with dashes
    device="${device// /-}"		# 'device-name'

    rx2=$(mosquitto_sub -v -C 1 -t "${topic}")
    v="${rx2##* }"
    nom="${TDIR}/temperature/${device}-${dateStr}.dat"
    echo "$v" >> ${nom}
done <<< "${rx}"
# Yes, the double qoutes around ${rx} are important
mosquitto_sub -h mozart.uucp -t "weather/metar/json" -C 1 >/tmp/metar.json
nom=$(${HOME}/bin/get-json.js '/tmp/metar.json' 'response.data[0].METAR[0].station_id[0]')
nom="${TDIR}/temperature/${nom}-${dateStr}.dat"
$(HOME}/bin//get-json.js '/tmp/metar.json' 'response.data[0].METAR[0].temp_c[0]' > "${nom}"
##[ Fini ]######################################################################
