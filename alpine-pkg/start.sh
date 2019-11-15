#!/bin/sh
/usr/bin/domoticz -userdata /var/lib/domoticz -dbase /data/domoticz.db -approot /usr/share/domoticz -www ${WWW} -sslwww ${SSLWWW}
