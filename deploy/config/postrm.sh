#!/bin/bash
if [ -f "/etc/auto-reboot.config" ] && [ "$1" == "remove" ]; then
  echo "Remove config file ..."
  rm -f "/etc/auto-reboot.config" >/dev/null 2>&1
fi
exit 0