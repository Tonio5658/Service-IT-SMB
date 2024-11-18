#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    ___                     __            ______                 __    ____  ____ 
   /   |  ____  ____ ______/ /_  ___     / ____/___  __  _______/ /_  / __ \/ __ )
  / /| | / __ \/ __ `/ ___/ __ \/ _ \   / /   / __ \/ / / / ___/ __ \/ / / / __  |
 / ___ |/ /_/ / /_/ / /__/ / / /  __/  / /___/ /_/ / /_/ / /__/ / / / /_/ / /_/ / 
/_/  |_/ .___/\__,_/\___/_/ /_/\___/   \____/\____/\__,_/\___/_/ /_/_____/_____/  
      /_/                                                                         
                                
EOF
}
header_info
echo -e "Loading..."
APP="Apache-CouchDB"
var_disk="10"
var_cpu="2"
var_ram="4096"
var_os="debian"
var_version="12"
VERBOSE="yes"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
check_container_storage
check_container_resources
if [[ ! -f /etc/systemd/system/couchdb.service ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_error "There is currently no update path available."
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:5984/_utils/${CL} \n"
