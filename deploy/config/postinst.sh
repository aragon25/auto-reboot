#!/bin/bash
if [ -f "/lib/systemd/system/auto-reboot.service" ]; then
  echo "Start and enable service ..."
  systemctl daemon-reload >/dev/null 2>&1
  systemctl enable auto-reboot.service >/dev/null 2>&1
  systemctl start auto-reboot.service >/dev/null 2>&1
fi
exit 0