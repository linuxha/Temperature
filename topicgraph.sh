#!/bin/bash

############################################################################
# topicgraph.sh - graph the data in the files ...
############################################################################
#
# This program started out with simple intentions, plot the seonsors to
# allow comparision of temperatures in different parts of the house (and
# outside) using gnuplot.
#
# I've started playing around with gnuplot and it's various features. Very
# powerful (even though I don't comprehend all the features).
#
############################################################################
export PATH=/usr/local/bin:${PATH}

TDIR="${HOME}/dev/Temperature/temperature"

# ------------------------------------------------------------------------------
# take 6:46 and convert it to 6.76 hours
math() {
    s=$(echo "scale=2; ${1//:/+}/60" | bc -l)
    echo $s
}
    
# ------------------------------------------------------------------------------
sunrise=$(sunrise)
sunset=$(sunset)
# Magic math to go from 6:46 to 6.75 goes here
srise=$(math ${sunrise})
sset=$(math ${sunset})

#
dateStr1=$(date +%Y%m%d)
dateStr2=$(date +%c)

# mediumspringgreen	#00FA9A
# 
Arg1="\"${TDIR}/Computer-Room-Temperature-${dateStr1}.dat\" smooth csplines title \"CR_Temp\""
Arg2="\"${TDIR}/Crawl-Space-Contact-Sensor-${dateStr1}.dat\" smooth csplines title \"Crawl_Contact\""
Arg3="\"${TDIR}/Crawl-Space-Temp-Humidity-Sensor-${dateStr1}.dat\" smooth csplines title \"Crawl_Temp\""
Arg4="\"${TDIR}/Front-Porch-Temp-Humidity-Sensor-${dateStr1}.dat\" smooth csplines title \"Porch_Temp\""
Arg5="\"${TDIR}/Garage-Side-Door-iContact-Sensor-${dateStr1}.dat\" smooth csplines title \"Garage_Contact\" lw 2"
Arg6="\"${TDIR}/KTTN-${dateStr1}.dat\" smooth csplines title \"KTTN\" lt rgb '#00FA9A' lw 2"
Arg7="\"${TDIR}/LR-Multipurpose-Sensor-A-${dateStr1}.dat\" smooth csplines title \"LR_Sensor\""

# commands to send to gnuplot

# size 600, 400
#set term png color small \n
#gnuplot> set term png color small 
#                            ^
#         line 0: unrecognized terminal option

# https://www2.uni-hamburg.de/Wiss/FB/15/Sustainability/schneider/gnuplot/colors.htm
COLOR="rgb '#FFFFFF'" # White     #FFFFFF
#COLOR="rgb '#C0C0C0'" # silver    #C0C0C0
#COLOR="rgb '#F0F8FF'" # aliceblue #F0F8FF
#COLOR="rgb '#F0FFFF'" # azure     #F0FFFF
#COLOR="rgb '#F0FFF0'" # honeydew  #F0FFF0
#COLOR="rgb '#FFFFF0'" # ivory     #FFFFF0
#COLOR="rgb '#F5F5DC'" # beige     #F5F5DC
#COLOR="rgb '#FFF0F5'" # lavenderblush #FFF0F5
#COLOR="rgb '#FFF0FF'" # lavender? #FFF0FF
#COLOR="rgb '#E0FFFF'" # lightcyan #E0FFFF
#COLOR="rgb '#D0FFFF'" # lightcyan #E0FFFF

# set term png color background ${COLOR} size 1200, 900 \n
#PNG="pngcairo dashed"
PNG="pngcairo"		# Same as png
#PNG="png"
# \xc2\xB0 is the URF 2 byte degree symbol
File="
set term ${PNG} color background ${COLOR} size 1200, 900 \n
set output \"temp.png\" \n
set title 'Temperature Sensors for ${dateStr2}' \n
set linestyle 1 lt 8 \n
set grid \n
set arrow from ${srise},0 to ${srise},80 nohead lc rgb 'red' \n
set arrow from ${sset},0 to ${sset},80 nohead lc rgb 'blue' \n

set xlabel 'Time ' \n
set ylabel 'F\xC2\xB0' \n

set xrange [-1:23] \n
set xtics ('' -1, 'Midnight' 0, '' 1, '2' 2, '' 3, '4' 4, '' 5, '6' 6, '' 7, '8' 8, '' 9, '10' 10, '' 11, 'Noon' 12, '' 13, '2' 14, '' 15, '4' 16, '' 17, '6' 18, '' 19, '8' 20, '' 21, '10' 22, '' 23)  \n

plot ${Arg1}, ${Arg2}, ${Arg3}, ${Arg4}, ${Arg5}, ${Arg6}, ${Arg7}\n
\n
"
#

/bin/echo -e ${File} | gnuplot 

# Thanks! Just for the benefit of the total n00bs and to be pedantic, the
# complete example to draw a vertical line at x=1 spanning from
#     y=0 to y=100
# would be just:
#     set arrow from 1,0 to 1,100 nohead lc rgb 'red'
# – JJC Dec 6 '13 at 1:53
# set arrow from $x1,$y1 to $x1,$y2 nohead lc rgb \'red\'\n
# set arrow from 7,0 to 7,80 nohead lc rgb \'red\'\n
# I don't understand this one
# p '< echo "x y"' w impulse
