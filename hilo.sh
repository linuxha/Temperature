:
# hilo.sh - uses wx200 programs to pull back temperature info from the weather station
# We then simply store the info in a file on the hour (run from cron).
#
# 58 23 * * * mv ${HOME}/HiLo.today ${HOME}/HiLo.yesterday
# 58 23 31 12 * mv ${HOME}/HiLo.ytd ${HOME}/HiLo.`date +"%Y"`
# 00 * * * * sh ~njc/bin/hilo.sh
#
# The first entry takes care of creating a new hilo file, while the second updates it
# and records the temperature on the hour.
#
# This version will have the high & log for the year and on what day. The hilo for the
# day will include the time of day it occured.

# *[ History ]****************************************************************
# 09/25/99 njc - Found out that expr doesn't support floating point numbers so
#		 I've switched to using bc which does.
# 03/02/00 njc - seems that I'm not handling the rollover from Dec 31 - Jan 1
#                this needs to be fixed.
# ****************************************************************************

TempHome=${HOME}/hp/temperature

# Create the correct date related file name
PATH=${PATH}:/usr/local/bin
#cd ${HOME}/home
cd ${TempHome}

TFile="HiLo.today"
YFile="HiLo.year"

Today=`date "+%Y%m%d"`
Change=0

Current=`wx200 --temp diane:1130 |cut -d "F" -f 1`	# Current Temperature

echo "##############################################################################"
echo ${Current}
echo "##############################################################################"

echo "${Current}" >> ${Today}.tmp		# Keep a tally of the hourly temps

# ****************************************************************************
# File format:
#
#	Today:
#
#	Hi <TAB> xx:xx <TAB> Lo <TAB> xx:xx
#
#	Year
#
#	Hi <TAB> Mon\ dd <TAB> Lo <TAB> Mon\ dd
#
# Bash's use of the readline will correctly interpret the backslash!
#
# ****************************************************************************

# *[ High/Low for the day ]***************************************************

if [ -f ${TFile} ]; then
  read T1 D1 T2 D2 <$TFile
  Hi=${T1}
  Lo=${T2}

  if [ `echo ${Current} \> ${Hi}|bc` -eq 1 ]; then
    Hi=${Current}
    HiTime=`date "+%H:%M"`
    Change=1
    LoTime=${D2}
  else
    HiTime=${D1}
    if [ `echo ${Current} \< ${Lo}|bc` -eq 1 ]; then
      Lo=${Current}
      LoTime=`date "+%H:%M"`
      Change=1
    else
      LoTime=${D2}
    fi
  fi

else
  Hi=${Current}
  HiTime=`date "+%H:%M"`
  Lo=${Current}
  LoTime=`date "+%H:%M"`
  Change=1
fi

if [ ${Change} -eq 1 ]; then
  echo -e "${Hi}\t${HiTime}\t${Lo}\t${LoTime}" > ${TFile}
  Change=0
fi

echo -e "Hi ${Hi} F @ ${HiTime}\nLo ${Lo} F @ ${LoTime}"

# *[ High/Low Year to date ]**************************************************

if [ -f ${YFile} ]; then
  read T1 D1 T2 D2 <$YFile
  Hi=${T1}
  Lo=${T2}

  if [ `echo ${Current} \> ${Hi}|bc` -eq 1 ]; then # Check for Hi date change
    Hi=${Current}
    HiDate=`date "+%b\\\\ %d"`
    Change=1
    LoDate=${D2}
  else
    HiDate=${D1}
    if [ `echo ${Current} \< ${Lo}|bc` -eq 1 ]; then # Check for Lo date change
      Lo=${Current}
      LoDate=`date "+%b\\\\ %d"`
      Change=1
    else
      LoDate=${D2}
    fi
  fi

else
  Hi=${Current}
  HiDate=`date "+%b\\\\ %d"`
  Lo=${Current}
  LoDate=`date "+%b\\\\ %d"`
  Change=1
fi

if [ ${Change} -eq 1 ]; then
  echo -e "${Hi}\t${HiDate}\t${Lo}\t${LoDate}" > ${YFile}
fi
