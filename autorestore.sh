# wget -O autorestore.sh https://raw.githubusercontent.com/chuckmcilrath/scripts/refs/heads/main/autorestore.sh && chmod +x autorestore.sh && ./autorestore.sh

#!/bin/bash
set -e

### === CONFIGURATION === ###
PBS_HOST="69.10.39.173"
PBS_USER="pbsuser@pbs"
PBS_DATASTORE="Backups"
PBS_PASSWORD="1*Backup*1"     # You can also use a password file
PBS_NAME="Genteks-PBS"        # Name that will show up in Promox on the sidebar
VMID_RESTORE_TO="111"         # The new VMID (or same as original)
BACKUP_SNAPSHOT="backup/vm/111/2025-11-18T05:07:13Z"   # Snapshot to restore
RESTORE_STORAGE="local"       # Target storage on Proxmox host
RESTORE_FORMAT="qcow2"        # raw or qcow2

### === END CONFIG === ###


echo "===> Adding PBS storage to Proxmox (if not already present)..."
pvesm add pbs $PBS_NAME \
	--server $PBS_HOST \
	--datastore $PBS_DATASTORE \
	--username $PBS_USER \
	--password "$PBS_PASSWORD" \
	--fingerprint "b5:c8:bd:f2:f4:4d:4f:2c:37:4f:7b:84:f4:21:b3:4b:60:ab:e0:76:29:7a:1a:a1:92:69:d0:ba:f5:12:2b:be"


#echo "===> Starting VM restore from PBS..."
#echo "Restore source: $BACKUP_SNAPSHOT"
#echo "Target VMID: $VMID_RESTORE_TO"
#echo "Target Storage: $RESTORE_STORAGE"

#qmrestore \
#	$PBS_NAME:$BACKUP_SNAPSHOT \
#	$VMID_RESTORE_TO \
#	--storage $RESTORE_STORAGE \
#	--unique 1

#echo "===> Restore started successfully!"
#echo "Monitor via: qm status $VMID_RESTORE_TO"

#qm set 111 --delete ide0
#qm set 111 --delete ide1
#qm set 111 --delete ide2
#qm set 111 -net0 model=virtio,bridge=vmbr0

#echo "Starting VM..."
#qm start 111

#echo "Removing PBS Storage..."
#pvesm remove Genteks-PBS
#echo "Storage Removed."
#echo "Script Complete."
