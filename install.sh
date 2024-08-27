#!/bin/sh

uci set firewall.tailscale=include
uci set firewall.tailscale.type='script'
uci set firewall.tailscale.path='/data/tailscale/start_up.sh'
uci set firewall.tailscale.enabled='1'
uci commit firewall

chmod 755 /etc/init.d/tailscaled
/etc/init.d/tailscaled start