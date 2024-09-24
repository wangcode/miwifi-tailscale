#!/bin/sh
releases_url="https://api.github.com/repos/wangcode/miwifi-tailscale/releases"
install_path="/data/tailscale"
bin_path="$install_path/bin"

response=$(curl -s "$releases_url")
latest_version=$(echo "$response" | grep '"tag_name":' | head -n 1 | awk -F '"' '{print $4}')

mkdir -p "$install_path/bin"
curl -SL https://github.com/wangcode/miwifi-tailscale/releases/download/v${latest_version}/tailscale_v${latest_version}_arm64_upx.tar.gz | tar -zxC "$bin_path"
ln -s "$bin_path/tailscaled" "$bin_path/tailscale"

cat > "$install_path/tailscaled.procd" <<EOF
#!/bin/sh /etc/rc.common

# Copyright 2020 Google LLC.
# SPDX-License-Identifier: Apache-2.0

USE_PROCD=1
START=90
STOP=1

start_service() {
  procd_open_instance
  procd_set_param env TS_DEBUG_FIREWALL_MODE=auto
  procd_set_param command $bin_path/tailscaled
  procd_append_param command --state $install_path/tailscaled.state
  procd_append_param command --statedir $install_path
  procd_set_param respawn
  procd_set_param stdout 1
  procd_set_param stderr 1

  procd_close_instance
}

stop_service() {
  $bin_path/tailscaled -cleanup
}
EOF

cat > "$install_path/start_up.sh" <<EOF
#!/bin/sh

if [ ! -f "/tmp/tailscale_version.txt" ]; then
  echo "$tailscale_version" > "/tmp/tailscale_version.txt"
  exit 0
fi

cp "$install_path/tailscaled.procd" /etc/init.d/tailscaled
chmod 755 /etc/init.d/tailscaled
/etc/init.d/tailscaled start
EOF

uci set firewall.tailscale=include
uci set firewall.tailscale.type='script'
uci set firewall.tailscale.path='/data/tailscale/start_up.sh'
uci set firewall.tailscale.enabled='1'
uci commit firewall

chmod +x "${install_path}/start_up.sh"
sh "${install_path}/start_up.sh"
