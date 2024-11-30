#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/quantumryuu/ProxmoxVE/build/misc/build.func)
#source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 community-scripts ORG
# Author: kristocopani
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
    _______           ______         ____________
   / ____(_)_______  / __/ /_  __   /  _/  _/  _/
  / /_  / / ___/ _ \/ /_/ / / / /   / / / / / /  
 / __/ / / /  /  __/ __/ / /_/ /  _/ /_/ /_/ /   
/_/   /_/_/   \___/_/ /_/\__, /  /___/___/___/   
                        /____/                   

EOF
}
header_info
echo -e "Loading..."
APP="Firefly"
var_disk="2"
var_cpu="1"
var_ram="1024"
var_os="debian"
var_version="12"
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

  if [[ ! -d /opt/firefly-iii ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/firefly-iii/firefly-iii/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping Apache2"
    systemctl stop apache2
    msg_ok "Stopped Apache2"

    msg_info "Updating ${APP} to v${RELEASE}"
    cp /opt/firefly-iii/.env /opt/.env
    cp -r /opt/firefly-iii/storage /opt/storage
    rm -rf /opt/firefly-iii
    cd /opt
    wget -q "https://github.com/firefly-iii/firefly-iii/releases/download/${RELEASE}/FireflyIII-${RELEASE}.tar.gz"
    mkdir -p /opt/firefly-iii
    tar -xzf FireflyIII-${RELEASE}.tar.gz -C /opt/firefly-iii --exclude='storage'
    mv /opt/.env /opt/firefly-iii/.env
    mv /opt/storage /opt/firefly-iii/storage
    chown -R www-data:www-data /opt/firefly-iii
    chmod -R 775 /opt/firefly-iii/storage
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev  &>/dev/null
    php artisan migrate --seed &>/dev/null
    php artisan firefly-iii:decrypt-all &>/dev/null
    php artisan cache:clear &>/dev/null
    php artisan view:clear &>/dev/null
    php artisan firefly-iii:upgrade-database &>/dev/null
    php artisan firefly-iii:laravel-passport-keys &>/dev/null 
    echo "${RELEASE}" >"/opt/${APP}_version.txt" &>/dev/null
    msg_ok "Updated ${APP} to v${RELEASE}"

    msg_info "Starting Apache2"
    systemctl start apache2
    msg_ok "Started Apache2"

    msg_info "Cleaning up"
    rm -rf /opt/FireflyIII-${RELEASE}.tar.gz
    msg_ok "Cleaned"
    msg_ok "Updated Successfully"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}."
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}${CL} \n"