# wget -O autorestore.sh https://raw.githubusercontent.com/chuckmcilrath/scripts/refs/heads/main/autorestore.sh && chmod +x autorestore.sh && ./autorestore.sh

#!/bin/bash
set -e

### === CONFIGURATION === ###
PBS_HOST="10.100.100.215"
PBS_USER="pbsuser@pbs"
PBS_DATASTORE="Backups"
PBS_PASSWORD="1*Backup*1"     # You can also use a password file
PBS_NAME="Genteks-PBS"        # Name that will show up in Promox on the sidebar
VMID_RESTORE_TO="111"         # The new VMID (or same as original)
BACKUP_SNAPSHOT="backup/vm/111/2026-01-13T05:04:27Z" # Snapshot to restore
RESTORE_STORAGE="local"       # Target storage on Proxmox host
RESTORE_FORMAT="qcow2"        # raw or qcow2

### === END CONFIG === ###


echo "===> Adding PBS storage to Proxmox (if not already present)..."
pvesm add pbs $PBS_NAME \
	--server $PBS_HOST \
	--datastore $PBS_DATASTORE \
	--username $PBS_USER \
	--password "$PBS_PASSWORD" \
	--fingerprint "e8:c8:ba:36:2e:51:3e:c7:d3:cd:88:a9:c2:f8:f9:e1:9c:6b:6c:57:9e:09:03:36:d7:5f:cb:c1:a2:70:dd:50"


echo "===> Starting VM restore from PBS..."
echo "Restore source: $BACKUP_SNAPSHOT"
echo "Target VMID: $VMID_RESTORE_TO"
echo "Target Storage: $RESTORE_STORAGE"

qmrestore \
	$PBS_NAME:$BACKUP_SNAPSHOT \
	$VMID_RESTORE_TO \
	--storage $RESTORE_STORAGE \
	--unique 1

echo "===> Restore started successfully!"
echo "Monitor via: qm status $VMID_RESTORE_TO"

qm set 111 --delete ide0
qm set 111 --delete ide1
qm set 111 --delete ide2
qm set 111 -net0 model=virtio,bridge=vmbr0

echo "Starting VM..."
qm start 111

echo "Removing PBS Storage..."
pvesm remove Genteks-PBS
echo "Storage Removed."
echo "Script Complete."
