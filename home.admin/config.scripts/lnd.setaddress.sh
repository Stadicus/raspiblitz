#!/bin/bash

# command info
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "-help" ]; then
 echo "small config script to set a fixed domain or IP for LND"
 echo "internet.dyndomain.sh [domain|ip|off] [?address]"
 exit 1
fi

# 1. parameter [domain|ip|off]
mode="$1"

echo "number of args($#)"

# config file
configFile="/mnt/hdd/raspiblitz.conf"

# lnd conf file
lndConfig="/mnt/hdd/lnd/lnd.conf"

# check if config file exists
configExists=$(ls ${configFile} | grep -c '.conf')
if [ ${configExists} -eq 0 ]; then
 echo "FAIL - missing ${configFile}"
 exit 1
fi

# FIXED DOMAIN
if [ "${mode}" = "domain" ]; then

  address=$2
  if [ ${#address} -eq 0 ]; then
    echo "missing parameter"
    exit(1)
  fi

  echo "switching fixed LND Domain ON"
  echo "address(${address})"

  # setting value in raspi blitz config
  sudo sed -i "s/^lndAddress=.*/lndAddress='${address}'/g" /mnt/hdd/raspiblitz.conf

  echo "changing lnd.conf"

  # lnd.conf: uncomment tlsextradomain (just if it is still uncommented)
  sudo sed -i "s/^#tlsextradomain=.*/tlsextradomain=/g" /mnt/hdd/lnd/lnd.conf

  # lnd.conf: domain value
  sudo sed -i "s/^tlsextradomain=.*/tlsextradomain=${address}/g" /mnt/hdd/lnd/lnd.conf

  # refresh TLS cert
  sudo /home/admin/config.scripts/lnd.newtlscert.sh

  echo "fixedAddress is now ON"
fi

# FIXED IP
if [ "${mode}" = "ip" ]; then

  address=$2
  if [ ${#address} -eq 0 ]; then
    echo "missing parameter"
    exit(1)
  fi

  echo "switching fixed LND IP ON"
  echo "address(${address})"

  # setting value in raspi blitz config
  sudo sed -i "s/^lndAddress=.*/lndAddress='${address}'/g" /mnt/hdd/raspiblitz.conf

  echo "fixedAddress is now ON"
fi

# switch off
if [ "${mode}" = "off" ]; then
  echo "switching fixedAddress OFF"

  # stop services
  echo "making sure services are not running"
  sudo systemctl stop lnd 2>/dev/null

  # setting value in raspi blitz config
  sudo sed -i "s/^lndAddress=.*/lndAddress=/g" /mnt/hdd/raspiblitz.conf

  echo "changing lnd.conf"

  # lnd.conf: comment tlsextradomain out
  sudo sed -i "s/^tlsextradomain=.*/#tlsextradomain=/g" /mnt/hdd/lnd/lnd.conf

  # refresh TLS cert
  sudo /home/admin/config.scripts/lnd.newtlscert.sh

  echo "fixedAddress is now OFF"
fi

echo "may needs reboot to run normal again"
exit 0