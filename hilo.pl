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
# 01/10/04 njc - I've decided to switch the sheel script over to Perl. The
#                shell script had a few oddities I couldn't figure out so I
#                took the easy way out and rewrite it (w/comments) in Perl.
# ****************************************************************************

$TempHome = "~/hp/tempterature";
#
#cd ${TempHome}

# TFile="HiLo.today"
# YFile="HiLo.year"

# Today=`date "+%Y%m%d"`
$Change = 0;

$Current = `wx200 --temp diane:1130 |cut -d "F" -f 1`;	# Current Temperature

print "Current temp is: $Current";

# ****************************************************************************
# File format:
#
#   Today:
#	Hi <TAB> xx:xx <TAB> Lo <TAB> xx:xx
#
#   Year:
#	Hi <TAB> Mon dd <TAB> Lo <TAB> Mon dd
#
#
# ****************************************************************************

# *[ High/Low for the day ]***************************************************

# *[ High/Low Year to date ]**************************************************
