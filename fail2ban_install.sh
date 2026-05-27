#!/bin/bash

#
# wget -O fail2ban_install.sh https://raw.githubusercontent.com/chuckmcilrath/scripts/refs/heads/main/fail2ban_install.sh && chmod +x fail2ban_install.sh && ./fail2ban_install.sh
#
#

#VARIABLES
defaults_jail_path=(/etc/fail2ban/jail.d/defaults.local)
ssh_jail_path=(/etc/fail2ban/jail.d/sshd.local)
proxmox_jail_path=(/etc/fail2ban/jail.d/proxmox.local)
proxmox_filter_path=/etc/fail2ban/filter.d/proxmox.conf
f2b_local_path=/etc/fail2ban/fail2ban.local

filter_def="[Definition]\nfailregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*\nignoreregex ="

#FUNCTIONS
check_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root. Please use sudo or log in as root." >&2
		exit 1
	fi
}

check_fail2ban_client_install() {
    if ! which fail2ban-client &> /dev/null; then
            echo "fail2ban not found. Installing..."
            apt update && apt install fail2ban -y
        if which fail2ban-client &> /dev/null; then
                echo "fail2ban has been successfully installed."
            else
                echo "Installation failed."
                exit 1
        fi
    else
        echo "fail2ban is already installed."
    fi
}

# User Input
user_input() {
    read -rp "Enter an email for fail2ban to use as a \"sender\". (e.g. fail2ban@name-of-company.com)" sender_email
    read -rp "Enter the amount of time to ban offenders? (e.g. 5m, 12h, 50d, 10y etc)." bantime_input
    read -rp "Enter the maximum amount of retries before banning." maxretry_input
}

defaults() {
		cat <<EOF > "$defaults_jail_path"
[DEFAULT]
bantime = "$bantime_input"
bantime = "$maxretry_input"
findtime = 10m
backend = systemd
destemail = root@localhost
sender = "$sender_email"
mta = sendmail
action = %(action_mwl)s
ignoreip = 127.0.0.1/8 ::1
EOF
}

ssh_jail() {
		cat <<EOF > "$ssh_jail_path"
[sshd]
enabled = true
port = ssh
filter = sshd
EOF
}

proxmox_jail() {
		cat <<EOF > "$proxmox_jail_path"
[proxmox]
enabled = true
port = https,http,8006
filter = proxmox
EOF
}

Proxmox_filter() {
    if [ ! -f "$proxmox_filter_path" ]; then
        touch $proxmox_filter_path
        echo -e "$filter_def" > $proxmox_filter_path
    fi
}

fail2ban_local_add_for_IPV6() {
    if [ ! -f "$f2b_local_path" ]; then
        touch $f2b_local_path
    fi

    cat <<EOF > "$f2b_local_path"
[DEFAULT]
allowipv6 = no
loglevel = INFO
logtarget = /var/log/fail2ban.log
syslogsocket = auto
socket = /var/run/fail2ban/fail2ban.sock
pidfile = /var/run/fail2ban/fail2ban.pid
dbfile = /var/lib/fail2ban/fail2ban.sqlite3
dbpurgeage = 1d
dbmaxmatches = 10
[Definition]
[Thread]
EOF
}

finish() {
    systemctl restart fail2ban
    echo -e "Fail2ban has been successfully started\nTo see status of the server, please type: \"systemctl status fail2ban\""
    echo -e "USEFUL COMMANDS\nfail2ban-client status proxmox\nfail2ban-client unban ip (IP ADDRESS)"
}

# MAIN
check_root
check_fail2ban_client_install
user_input
defaults
ssh_jail
proxmox_jail
Proxmox_filter
fail2ban_local_add_for_IPV6
finish

## END OF SCRIPT
