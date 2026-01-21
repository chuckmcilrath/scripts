#!/bin/bash

wg_config1="/etc/wireguard/wg0.conf"
wg_config2="/etc/wireguard/wg1.conf"

wg1_private="/etc/wireguard/wg0_private.key"
wg2_private="/etc/wireguard/wg1_private.key"

wg1_public="/etc/wireguard/wg0_public.key"
wg2_public="/etc/wireguard/wg1_public.key"

dcm_conf="etc/wireguard/dcm.conf"
dcm_private="etc/wireguard/dcm_private.key"
dcm_public="etc/wireguard/dcm_public.key"

wan_peer_change="dcm.genteks.net"

if grep -q "AllowedIPs = 10.100.100.0/24" "$wg_config1"; then
	cp "$wg_config1" "$wg_config1".bak
	sed -i -E "s/(Endpoint = )([^:]+)(:[0-9]+)/\1$wan_peer_change\3/" "$wg_config1"
	mv "$wg_config1" "$dcm_conf"
	mv "$wg1_private" "$dcm_private"
	mv "$wg1_public" "$dcm_public"
	sed -i 's/wg0/dcm/' ~/.bashrc
elif grep -q "AllowedIPs = 10.100.100.0/24" "$wg_config2"; then
	cp "$wg_config2" "$wg_config2".bak
	sed -i -E "s/(Endpoint = )([^:]+)(:[0-9]+)/\1$wan_peer_change\3/" "$wg_config2"
	mv "$wg_config2" "$dcm_conf"
	mv "$wg2_private" "$dcm_private"
	mv "$wg2_public" "$dcm_public"
	sed -i 's/wg1/dcm/' ~/.bashrc
else
	echo "error"
fi
