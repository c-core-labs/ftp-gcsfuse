#!/bin/bash

HOME_DIRECTORY="/home/$FTP_USER"
# Gcsfuse mount fails when set to user home directory in ContainerOS.
# We mount to a subdirectory instead
FUSE_MOUNT_DIRECTORY="/home/$FTP_USER/bucket"

echo "HOME_DIRECTORY"
echo $HOME_DIRECTORY
echo "FUSE_MOUNT_DIRECTORY"
echo $FUSE_MOUNT_DIRECTORY

addgroup \
	--gid $GID \
	--system \
	$FTP_USER

adduser \
        --gid $GID \
	--home /home/$FTP_USER \
	--uid $UID \
	--gecos "" \
	--disabled-password \
	$FTP_USER


mkdir -p $HOME_DIRECTORY
mkdir -p $FUSE_MOUNT_DIRECTORY

chown -R $FTP_USER:$FTP_USER $HOME_DIRECTORY
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

echo "Mounting $BUCKET to $FUSE_MOUNT_DIRECTORY"
echo $BUCKET
gcsfuse -o allow_other --gid $GID --uid $UID $BUCKET $FUSE_MOUNT_DIRECTORY
echo "Mounting completed."

# Substitute vsftpd local_root to use directory mounted to bucket
sed -i 's#^\(local_root\s*=\s*\).*$#\1'"$FUSE_MOUNT_DIRECTORY"'#' /etc/vsftpd.conf

# Substitute vsftpd passive address with public IP address
IP_ADDRESS=$(curl ipinfo.io/ip)
sed -i 's#^\(pasv_address\s*=\s*\).*$#\1'"$IP_ADDRESS"'#' /etc/vsftpd.conf

cat /etc/vsftpd.conf

echo ""

echo "Starting vsftpd"
/usr/sbin/vsftpd
