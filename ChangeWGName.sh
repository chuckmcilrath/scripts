#!/bin/bash

# wget -O wgrename.sh https://raw.githubusercontent.com/chuckmcilrath/scripts/refs/heads/main/ChangeWGName.sh && chmod +x wgrename.sh && ./wgrename.sh

wg_config1="/etc/wireguard/wg0.conf"
wg_config2="/etc/wireguard/wg1.conf"

wg1_private="/etc/wireguard/wg0_private.key"
wg2_private="/etc/wireguard/wg1_private.key"

wg1_public="/etc/wireguard/wg0_public.key"
wg2_public="/etc/wireguard/wg1_public.key"

dcm_conf="/etc/wireguard/dcm.conf"
dcm_private="/etc/wireguard/dcm_private.key"
dcm_public="/etc/wireguard/dcm_public.key"

wan_peer_change="dc.genteks.net"

if [ -f "$wg_config1" ] && grep -q "AllowedIPs = 10.100.100.0/24" "$wg_config1"; then
	systemctl stop wg-quick@wg0
	systemctl disable wg-quick@wg0
	cp "$wg_config1" "$wg_config1".bak
	sed -i -E "s/(Endpoint = )([^:]+)(:[0-9]+)/\1$wan_peer_change\3/" "$wg_config1"
	mv "$wg_config1" "$dcm_conf"
	mv "$wg1_private" "$dcm_private"
	mv "$wg1_public" "$dcm_public"
	sed -i 's/wg0/dcm/g' ~/.bashrc
	systemctl enable wg-quick@dcm
	systemctl start wg-quick@dcm
	sed -i '/export/d' ~/.bashrc
	echo "alias dcm_public_key=\"cat /etc/wireguard/dcm_public.key\"" >> ~/.bashrc
	echo "alias dcm_private_key=\"cat /etc/wireguard/dcm_private.key\"" >> ~/.bashrc
elif [ -f "$wg_config2" ] && grep -q "AllowedIPs = 10.100.100.0/24" "$wg_config2"; then
	systemctl stop wg-quick@wg1
	systemctl disable wg-quick@wg1
	cp "$wg_config2" "$wg_config2".bak
	sed -i -E "s/(Endpoint = )([^:]+)(:[0-9]+)/\1$wan_peer_change\3/" "$wg_config2"
	mv "$wg_config2" "$dcm_conf"
	mv "$wg2_private" "$dcm_private"
	mv "$wg2_public" "$dcm_public"
	sed -i 's/wg1/dcm/g' ~/.bashrc
	systemctl enable wg-quick@dcm
	systemctl start wg-quick@dcm
	sed -i '/export/d' ~/.bashrc
	echo "alias dcm_public_key=\"cat /etc/wireguard/dcm_public.key\"" >> ~/.bashrc
	echo "alias dcm_private_key=\"cat /etc/wireguard/dcm_private.key\"" >> ~/.bashrc
else
	echo "error"
fi

rm wgrename.sh

# Changed these to use dc.genteks.net
# apex, hillpointe, sandhill, fine-remote-pbs
