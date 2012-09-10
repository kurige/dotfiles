#!/usr/bin/env bash
# Prints the local network IP address for a staticly defined NIC or search for an IP address on all active NICs.

nics=$(ifconfig | cut -s -d ':' -f1 | grep -v '[[:space:]]' | grep -v 'lo0')
for nic in ${nics[@]}; do
  lan_ip=$(ipconfig getifaddr "$nic")
  [ -n "$lan_ip" ] && break
done

if [ -n "$lan_ip" ]; then
  #echo "Ⓛ ${lan_ip}"
  echo "ⓛ ${lan_ip}"
  exit 0
else
  exit 1
fi
