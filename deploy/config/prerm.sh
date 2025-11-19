#!/bin/bash
if [ -f "/lib/systemd/system/auto-reboot.service" ]; then
  echo "Stop and disable service ..."
  systemctl stop auto-reboot.service >/dev/null 2>&1
  systemctl disable auto-reboot.service >/dev/null 2>&1
  systemctl daemon-reload >/dev/null 2>&1
fi
if [ -f "/usr/bin/auto-reboot" ]; then
  echo "Prepare to remove ..."
  /usr/bin/auto-reboot --shutdown >/dev/null 2>&1
  /usr/bin/auto-reboot --boot >/dev/null 2>&1
fi
exit 0