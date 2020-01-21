#!/bin/sh
#
# Event handler script for sending an email when a state reaches a value
#
# What state is the HTTP service in?
case "$1" in
OK)
	# Everything is OK, so don't do anything...
	;;
WARNING)
    # Aha!  The disk service appears to have a problem - perhaps we should send the warning email...
    mail -s "$2 (IP $3) disk warning" jakyandras@gmail.com
	;;
UNKNOWN)
	# We don't know what might be causing an unknown error, so don't do anything...
	;;
CRITICAL)
	# Aha!  The disk service appears to have a problem - perhaps we should send the warning email...
    mail -s "$2 (IP $3) disk critical" jakyandras@gmail.com
	;;
esac
exit 0