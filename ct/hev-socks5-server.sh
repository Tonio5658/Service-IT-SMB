#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: miviro
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/heiher/hev-socks5-server

APP="hev-socks5-server"
TAGS="proxy,socks5"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources

    if [[ ! -f /opt/hev-socks5-server ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    RELEASE=$(curl -s https://api.github.com/repos/heiher/hev-socks5-server/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
        msg_info "Stopping $APP"
        systemctl stop $APP
        msg_ok "Stopped $APP"

        msg_info "Creating Backup"
        tar -czf "/opt/${APP}_backup_$(date +%F).tar.gz" "/etc/${APP}"
        msg_ok "Backup Created"

        msg_info "Updating $APP to v${RELEASE}"
        curl -L -o "${APP}" "https://github.com/heiher/hev-socks5-server/releases/download/${RELEASE}/hev-socks5-server-linux-x86_64"
        mv ${APP} /opt/${APP}
        msg_ok "Updated $APP to v${RELEASE}"

        msg_info "Starting $APP"
        systemctl start $APP
        msg_ok "Started $APP"

        msg_info "Cleaning Up"
        msg_ok "Cleanup Completed"

        echo "${RELEASE}" >/opt/${APP}_version.txt
        msg_ok "Update Successful"
    else
        msg_ok "No update required. ${APP} is already at v${RELEASE}"
    fi
    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:1080${CL}"