#!/bin/sh
version="1.72.1"
install_path="/data/tailscale"
bin_path="$install_path/bin"

mkdir -p "$install_path/bin"
curl -SL https://github.com/wangcode/miwifi-tailscale/releases/download/v$version/tailscale_v$version_arm64_upx.tar.gz | tar -zxC "$bin_path"
ln -s "$bin_path/tailscaled" "$bin_path/tailscale"

uci set firewall.tailscale=include
uci set firewall.tailscale.type='script'
uci set firewall.tailscale.path='/data/tailscale/start_up.sh'
uci set firewall.tailscale.enabled='1'
uci commit firewall

chmod 755 /etc/init.d/tailscaled
/etc/init.d/tailscaled start