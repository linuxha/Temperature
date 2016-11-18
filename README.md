# Ping-Check

## Description
My tools for getting and plotting the information from SmartThings sensors and a local Airport

## Background
This is for my notes as to why we got here.

I've been playing with SmartThings and MQTT for a while. I have a number of custom (my own design) and ZigBee sensors that publish to MQTT. I've wanted to plot the data for a while and finally just sat down and started. Here's the results.

As is normal for someone who writes one simple script after another. I end up with lots of scripts that each can do a little. I then pair them up into one monster collection that does something useful but if left undocumented can never be replicated in a million years. Well here's my attempt at documenting this collection.

So I decided to start with a set of scripts (hilo.*, from 1999) I wrote a long time ago to get data from my weather station and save it to a text file (24 entries, 1 for everyhour). I had used gnuplot and was able to plot each day's graph as a png image (still using png).

### MQTT topics

* smartthings/Computer Room Temperature/temperature
* smartthings/Crawl Space Contact Sensor/temperature
* smartthings/Crawl Space Temp-Humidity Sensor/temperature
* smartthings/Front Porch Temp-Humidity Sensor/temperature
* smartthings/LR Multipurpose Sensor A/temperature
* smartthings/Garage Side Door iContact Sensor/temperature
* weather/metar/json

### Scripts

* several node-red scripts (need to figure out how to add them to this repos)
** http://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&hoursBeforeNow=3&mostRecent=true&stationString={{{payload}}} (where {{{payload}}} is set to KTTN)
* mmove.sh
* mosquitto_sub (part of the mosquitto tools)
* gettopicval.sh
* topicgraph.sh
* clean-topicval.sh
* hilo.sh
* hilo.pl
* tempgraph.sh
* check_battery.sh

## Crontab

```
# Stuff for
# mosquitto_sub -h mozart.uucp -t "weather/metar/json" -C 1 >/tmp/metar.json & ~/bin/get-json.js /tmp/metar.json 'response.data[0].METAR[0].temp_c[0]'my graphs
# 
2 0 * * *	${HOME}/dev/Temperature/mmove.sh
3 * * * *	/usr/local/bin/mosquitto_sub -h mozart.uucp -t "weather/metar/json" -C 1 >/tmp/metar.json && ${HOME}/bin/gettopicval.sh && ${HOME}/bin/topicgraph.sh
4 1 * * *	${HOME}/bin/clean-topicval.sh
```

## Notes

* Verified with Firefox, Node.js v0.10.29, and Bash under Linux.
* I won't make any attempt to make this portable.
* This really is a learning exercise to learn a little about gnuplot and scratch an itch (see how tempertures around the house relate to each other and other environmental factors).
* Yes this is a kludge of one script pulled into duty to work with another (I'm a lazy programmer).

## Installation


## ToDo

* You're kidding right? ;-)
* Add more sensor data to the plot until it's useful (or totally unreadable)
* add a bit more labeling# Temperature Readem
