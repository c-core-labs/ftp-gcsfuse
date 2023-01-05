#!/bin/sh

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


mkdir -p /home/$FTP_USER
# Create mount directory for service
mkdir -p $MNT_DIR

chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

echo "Getting ready."
echo "Mounting GCS Fuse."
echo $BUCKET
gcsfuse --debug_gcs --debug_fuse -o allow_other --gid $GID --uid $UID $BUCKET $MNT_DIR 
echo "Mounting completed."
echo $(ls $MNT_DIR)
echo $(ls)
echo "Done."
# chown -R $FTP_USER:$FTP_USER $MNT_DIR

echo "Starting vsftpd"
exec /usr/sbin/vsftpd &
echo "Vsftpd started."

# touch /var/log/vsftpd.log
# tail -f /var/log/vsftpd.log | tee /dev/stdout &
# touch /var/log/xferlog
# tail -f /var/log/xferlog | tee /dev/stdout &

# exec "$@"

# Exit immediately when one of the background processes terminate.
/bin/bash
