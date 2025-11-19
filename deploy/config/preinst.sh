#!/bin/bash
if [ "$(which auto-reboot)" != "" ] && [ "$1" == "install" ]; then
  echo "The command \"auto-reboot\" is already present. Can not install this."
  echo "File: \"$(which auto-reboot)\""
  exit 1
fi
exit 0