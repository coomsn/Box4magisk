#!/system/bin/sh
clear; cd ${0%/*}

  MODDIR="/data/adb/modules/box-module"
  SCRIPTS_DIR="/data/adb/Box/scripts"
  busybox="/data/adb/magisk/busybox"
  normal=$(printf '\033[0m'); green=$(printf '\033[0;32m'); red=$(printf '\033[91m')
  
  source ./box.scripts
  
  inot_gid=20002
  
  [ ! -f ${MODDIR}/disable ] && run_proxy
  
  pgrep inotifyd > /dev/null 2>&1 && pkill -g ${inot_gid}
  
  ${busybox} setuidgid 0:${inot_gid} inotifyd "${SCRIPTS_DIR}/box.inotify" "${MODDIR}" > /dev/null 2>&1 &
