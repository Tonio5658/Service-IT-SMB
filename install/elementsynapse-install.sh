#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: tremor021
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y
  sudo \
  curl \
  mc \
  lsb-release \
  wget \
  apt-transport-https \
  debconf-utils
msg_ok "Installed Dependencies"

msg_info "Installing Element Synapse"
wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/matrix-org.list
$STD apt update
echo "matrix-synapse-py3 matrix-synapse/server-name string matrix" | debconf-set-selections
echo "matrix-synapse-py3 matrix-synapse/report-stats boolean false" | debconf-set-selections
$STD apt install matrix-synapse-py3 -y
systemctl stop matrix-synapse
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/matrix-synapse/homeserver.yaml
systemctl start matrix-synapse
msg_ok "Installed Element Synapse"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
