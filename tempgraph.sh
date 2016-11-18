#!/bin/bash
############################################################################
#
# This program started out with simple intentions, figure out what today,
# yesterday and the day previous were. Create a plot script file and let
# gnuplot plot the data. But month/year/leap year rollovers have caused a
# lot of problems. I should probably sit down and re-think this progam and
# perhaps program it in a language other than shell (which has great
# limitations).
#
############################################################################
#
# Priorities:
#
# A	Day rollover, 1st & 2nd trigger a month rollover
# B	Month rollover, 1st causes a year rolover
# C     year rollovers just use subtraction
# 
############################################################################
export PATH=${PATH}:/usr/local/bin

#TDIR="/usr2/home/njc/home/"
TDIR="${HOME}/dev/Temperature/temperature"

#This tell sh that we're dealing with int numbers
typeset -i D2 D3 M2 M3 Day Mon Year Y2 Y3 Num
Num="$#"

if [ ${Num} != 0 ]; then
    M=${1}
    Day=${2}
    Year=${3}
else
    M=`date +"%m"`
    Day=`date +"%e"`
    Year=`date +"%Y"`
fi

# Interesting problem, what is 08? According to shell it doesn't exists it
# thinks the number is octal!

case "x${M}" in
    "x08")
	Mon=8
	;;
    "x09")
	Mon=9
	;;
    *)
	Mon=${M}
	;;
esac

D2=${Day}-1
D3=${Day}-2
M2="${Mon}"
M3="${Mon}"
Y2="${Year}"
Y3="${Year}"

##############################################################################

# This is broken, it fails for Jan 1-3

# Here we handle leap year (we won't worry about the next century)
# Months that have 30 or 31 days and February
# Also we handle year wrap

if [ ${Day} = 1 ]; then
  M2=${Mon}-1
  M3=${M2}
  case ${M2} in
    1|3|5|7|8|10|12)		# Months that have 31 days
	D2=31
	;;
    4|6|9|11)			# Months that have 30 days
	D2=30

	;;
    2)				# February (leap year)
	typeset -i ans1 ans2
	ans1=${M2}/4		# Ignore Century rules
	ans2=${ans1}*4
	
	if [ $M2 = $ans2 ]; then
	    D2=29
	else
	    D2=28
	fi
	;;
    0)				# Jan-Dec wrap
	D2=31
	M2=12
	M3=12
	Y2=${Year}-1
	Y3=${Year}-1
	;;
  esac

  D3=${D2}-1
else if [ ${Mon} = 1 ] && [ ${Day} -lt 3 ]; then
  if [ ${Day} = 1 ]; then
    M2=12
  fi
  M3=12
#  Y3=${Year}-1
fi
fi

if [ ${D2} = 1 ]; then
  M3=${Mon}-1
  case ${M3} in
      1|3|5|7|8|10|12)		# Months that have 31 days
	  D3=30
	  ;;
      4|5|9|11)			# Months that have 30 days
	  D3=29
	  ;;
      2)			# February (leap year)
	  typeset -i ans1 ans2
	  ans1=${M3}/4		# Ignore Century rules
	  ans2=${ans1}*4
	
	  if [ $M3 = $ans2 ]; then
	      D3=28
	  else
	      D3=27
	  fi
	  ;;
      0)				# Jan-Dec wrap
	  D3=30
	  M3=12
	  Y3=${Year}-1
	  ;;
    esac
fi
###############################################################

# File names YYYYmmdd.tmp

N1=`printf "%04d%02d%02d" ${Year} ${Mon} ${Day}`
N2=`printf "%04d%02d%02d" ${Y2} ${M2} ${D2}`
N3=`printf "%04d%02d%02d" ${Y3} ${M3} ${D3}`

if [ ! -f "${TDIR}/${N1}.tmp" ]; then
  N1="empty.dat"
fi

if [ ! -f "${TDIR}/${N2}.tmp" ]; then
  N2="empty.dat"
fi

if [ ! -f "${TDIR}/${N3}.tmp" ]; then
  N3="empty.dat"
fi

# Command line arguements

Arg1="\"${TDIR}/${N1}.tmp\" smooth csplines title \"${Mon}/${Day}\""
Arg2="\"${TDIR}/${N2}.tmp\" smooth csplines title \"${M2}/${D2}\" with lines ls 1"
Arg3="\"${TDIR}/${N3}.tmp\" smooth csplines title \"${M3}/${D3}\""

# commands to send to gnuplot

#set term png color small \n
#gnuplot> set term png color small 
#                            ^
#         line 0: unrecognized terminal option

File="
set term png color \n
set output \"temp.png\" \n
set title 'Temperatures' \n
set linestyle 1 lt 8 \n
set grid \n

set xlabel 'Time (Today & 2 days previous)' \n
set ylabel 'Degrees F' \n

set xrange [-1:23] \n
set xtics ('' -1, 'Midnight' 0, '' 1, '2' 2, '' 3, '4' 4, '' 5, '6' 6, '' 7, '8' 8, '' 9, '10' 10, '' 11, 'Noon' 12, '' 13, '2' 14, '' 15, '4' 16, '' 17, '6' 18, '' 19, '8' 20, '' 21, '10' 22, '' 23)  \n

plot ${Arg1}, ${Arg2}, ${Arg3} \n
\n
"

/bin/echo -e ${File} | gnuplot 
