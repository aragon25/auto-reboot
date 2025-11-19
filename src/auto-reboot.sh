#!/bin/bash
##############################################
##                                          ##
##  auto-reboot-service                     ##
##                                          ##
##############################################

#get some variables
SCRIPT_TITLE="auto-reboot-service"
SCRIPT_VERSION="1.4"
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
mountpoint -q /STATIC && STATIC_DIR="/STATIC" || STATIC_DIR="/etc"
CONFIG_FILE="/etc/auto-reboot.config"
STATE_FILE="$STATIC_DIR/${SCRIPT_TITLE}_poweroff"
HARDRESET="n"
OFSUPTIME=0
OFSDISKFREE=0
NRMUPTIME=0
EXITCODE=0

#check commands
for i in "$@"
do
  case $i in
    --HARDRESET=*)
    HARDRESET_T=${i#--HARDRESET=}
    safecfg=y
    shift # past argument
    ;;
    --OFSUPTIME=*)
    OFSUPTIME_T=${i#--OFSUPTIME=}
    safecfg=y
    shift # past argument
    ;;
    --OFSDISKFREE=*)
    OFSDISKFREE_T=${i#--OFSDISKFREE=}
    safecfg=y
    shift # past argument
    ;;
    --NRMUPTIME=*)
    NRMUPTIME_T=${i#--NRMUPTIME=}
    safecfg=y
    shift # past argument
    ;;
    -a|--activate)
    [ "$CMD" == "" ] && CMD="activate" || CMD="help"
    shift # past argument
    ;;
    -d|--deactivate)
    [ "$CMD" == "" ] && CMD="deactivate" || CMD="help"
    shift # past argument
    ;;
    --boot)
    [ "$CMD" == "" ] && CMD="boot" || CMD="help"
    shift # past argument
    ;;
    --shutdown)
    [ "$CMD" == "" ] && CMD="shutdown" || CMD="help"
    shift # past argument
    ;;
    --service)
    [ "$CMD" == "" ] && CMD="service" || CMD="help"
    shift # past argument
    ;;
    -v|--version)
    [ "$CMD" == "" ] && CMD="version" || CMD="help"
    shift # past argument
    ;;
    -h|--help)
    CMD="help"
    shift # past argument
    ;;
    *)
    if [ "$i" != "" ]
    then
      echo "Unknown option: $i"
      exit 1
    fi
    ;;
  esac
done
[ "$CMD" != "" ] && [ -n "$safecfg" ] && CMD="help"
[ "$CMD" == "" ] && [ -z "$safecfg" ] && CMD="help"

function do_check_start() {
  #check if superuser
  if [ $UID -ne 0 ]; then
    echo "Please run this script with Superuser privileges!"
    exit 1
  fi
  #check overlay status
  [ $(findmnt -n -o FSTYPE / 2>/dev/null) == "overlay" ] && overlayfs="true" || overlayfs="false"
  #check config files integrity
  [[ ! $(file -b --mime-type "$(readlink -f "$CONFIG_FILE")" 2>/dev/null) =~ "text" ]] && config_write_all >/dev/null 2>&1
}

function config_read(){ # path, key, defaultvalue -> value
  local val=$( (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=__UNDEFINED__") | head -n 1 | cut -d '=' -f 2-)
  #val=$(echo "${val}" | sed 's/ *$//g' | sed 's/^ *//g')
  val=$(echo "$val" | xargs)
  [ "${val}" == "__UNDEFINED__" ] && val="$3"
  printf -- "%s" "${val}"
}

function config_write(){ # path, key, value
  [ ! -e "$1" ] && touch "$1"
  sed -i "/^$(echo $2 | sed -e 's/[]\/$*.^[]/\\&/g').*$/d" "$1"
  echo "$2=$3" >> "$1"
}

function config_read_all(){
  HARDRESET=$(config_read "$CONFIG_FILE" REBOOT_AFTER_HARD_RESET n)
  HARDRESET=$(echo "$HARDRESET" | sed 's/ *$//g' | sed 's/^ *//g')
  [ "$HARDRESET" == "y" ] || HARDRESET="n"
  OFSUPTIME=$(config_read "$CONFIG_FILE" OVERLAYFS_UPTIME_LIMIT_SECONDS 0)
  [[ ! $OFSUPTIME =~ ^[0-9]+$ ]] && OFSUPTIME=0
  [ $OFSUPTIME -ne 0 ] && [ $OFSUPTIME -lt 30 ] && OFSUPTIME=30
  OFSDISKFREE=$(config_read "$CONFIG_FILE" OVERLAYFS_DISKFREE_LIMIT_BYTE 0)
  [[ ! $OFSDISKFREE =~ ^[0-9]+$ ]] && OFSDISKFREE=0
  NRMUPTIME=$(config_read "$CONFIG_FILE" NORMAL_UPTIME_LIMIT_SECONDS 0)
  [[ ! $NRMUPTIME =~ ^[0-9]+$ ]] && NRMUPTIME=0
  [ $NRMUPTIME -ne 0 ] && [ $NRMUPTIME -lt 30 ] && NRMUPTIME=30
}

function config_write_all(){
  rm -f "$CONFIG_FILE" >/dev/null 2>&1
  mkdir -p "$(dirname ""$CONFIG_FILE"")" >/dev/null 2>&1
  [ "$HARDRESET" == "y" ] || HARDRESET="n"
  config_write "$CONFIG_FILE" REBOOT_AFTER_HARD_RESET $HARDRESET
  [[ ! $OFSUPTIME =~ ^[0-9]+$ ]] && OFSUPTIME=0
  [ $OFSUPTIME -ne 0 ] && [ $OFSUPTIME -lt 30 ] && OFSUPTIME=30
  config_write "$CONFIG_FILE" OVERLAYFS_UPTIME_LIMIT_SECONDS $OFSUPTIME
  [[ ! $OFSDISKFREE =~ ^[0-9]+$ ]] && OFSDISKFREE=0
  config_write "$CONFIG_FILE" OVERLAYFS_DISKFREE_LIMIT_BYTE $OFSDISKFREE
  [[ ! $NRMUPTIME =~ ^[0-9]+$ ]] && NRMUPTIME=0
  [ $NRMUPTIME -ne 0 ] && [ $NRMUPTIME -lt 30 ] && NRMUPTIME=30
  config_write "$CONFIG_FILE" NORMAL_UPTIME_LIMIT_SECONDS $NRMUPTIME
  chown root:root "$CONFIG_FILE" >/dev/null 2>&1
  chmod 644 "$CONFIG_FILE" >/dev/null 2>&1
  echo "$SCRIPT_TITLE Settings:"
  echo "HARDRESET=$HARDRESET"
  echo "OFSUPTIME=$OFSUPTIME"
  echo "OFSDISKFREE=$OFSDISKFREE"
  echo "NRMUPTIME=$NRMUPTIME"
  echo "Settings saved!"
  if [[ "$(systemctl status auto-reboot 2>/dev/null)" =~ "active (running)" ]]; then
    systemctl restart auto-reboot
  fi
}

function cmd_boot() {
  if [ -f "$STATE_FILE" ] && [ "$HARDRESET" == "y" ]; then
    rm -f "$STATE_FILE" >/dev/null 2>&1
  elif [ "$HARDRESET" == "y" ]; then
    cmd_shutdown
    sync >/dev/null 2>&1
    vcgencmd display_power 0 >/dev/null 2>&1
    sleep 3
    reboot -f
  fi
}

function cmd_shutdown() {
  if [ ! -e "$STATE_FILE" ] && [ "$HARDRESET" == "y" ]; then
    touch "$STATE_FILE" >/dev/null 2>&1
  fi
}

function cmd_main() {
  root_avail="$(findmnt -n -b -o AVAIL / 2>/dev/null)"
  if [ "$overlayfs" == "true" ]; then
    DISKFREE=$OFSDISKFREE
    UPTIME=$OFSUPTIME
  else
    DISKFREE=0
    UPTIME=$NRMUPTIME
  fi
  [ $root_avail -lt $(($DISKFREE + 5000000)) ] && DISKFREE=0
  [ $UPTIME -lt 30 ] && UPTIME=0
  n=0
  while [ $root_avail -ge $DISKFREE ] && [ $n -le $UPTIME ]; do
    [ $DISKFREE -ne 0 ] && root_avail="$(findmnt -n -b -o AVAIL / 2>/dev/null)"
    [ $UPTIME -ne 0 ] && n=$(($n + 5))
    sleep 5
  done
  cmd_shutdown
  sync >/dev/null 2>&1
  vcgencmd display_power 0 >/dev/null 2>&1
  sleep 3
  reboot -f
}

function cmd_activate() {
  systemctl enable auto-reboot.service >/dev/null 2>&1
  systemctl start auto-reboot.service >/dev/null 2>&1
  echo "$SCRIPT_TITLE service activated!"
}

function cmd_deactivate() {
  systemctl stop auto-reboot.service >/dev/null 2>&1
  systemctl disable auto-reboot.service >/dev/null 2>&1
  echo "$SCRIPT_TITLE service deactivated!"
}

function cmd_print_version() {
  echo "$SCRIPT_TITLE v$SCRIPT_VERSION"
}

function cmd_print_help() {
  echo "Usage: $(basename ""$0"") [OPTION]"
  echo "$SCRIPT_TITLE v$SCRIPT_VERSION"
  echo " "
  echo "Current Settings:"
  echo "HARDRESET=$HARDRESET"
  echo "OFSUPTIME=$OFSUPTIME"
  echo "OFSDISKFREE=$OFSDISKFREE"
  echo "NRMUPTIME=$NRMUPTIME"
  echo " "
  echo "--HARDRESET=y/n         write setting reboot after hardreset (y/n)"
  echo "--OFSUPTIME=30-...      write setting reboot after uptime (seconds in overlaymode)"
  echo "--OFSDISKFREE=1-...     write setting reboot low diskfree (bytes in overlaymode)"
  echo "--NRMUPTIME=30-...      write setting reboot after uptime (seconds in normalmode)"
  echo "-a, --activate          start and activate service"
  echo "-d, --deactivate        stop and deactivate service"
  echo "-v, --version           print version info and exit"
  echo "-h, --help              print this help and exit"
  echo " "
  echo "Only one option at same time is allowed (except settings)!"
  echo " "
  echo "Author: aragon25 <aragon25.01@web.de>"
}

[ "$CMD" != "version" ] && [ "$CMD" != "help" ] &&  do_check_start
config_read_all
[ ! -z $HARDRESET_T ] && HARDRESET=$HARDRESET_T
[ ! -z $OFSUPTIME_T ] && OFSUPTIME=$OFSUPTIME_T
[ ! -z $OFSDISKFREE_T ] && OFSDISKFREE=$OFSDISKFREE_T
[ ! -z $NRMUPTIME_T ] && NRMUPTIME=$NRMUPTIME_T
[[ "$CMD" == "version" ]] && cmd_print_version
[[ "$CMD" == "help" ]] && cmd_print_help
[[ "$CMD" == "shutdown" ]] && cmd_shutdown
[[ "$CMD" == "boot" ]] && cmd_boot
[[ "$CMD" == "service" ]] && cmd_main
[[ "$CMD" == "activate" ]] && cmd_activate
[[ "$CMD" == "deactivate" ]] && cmd_deactivate
[[ "$CMD" == "" ]] && [ -n "$safecfg" ] && config_write_all

exit $EXITCODE
