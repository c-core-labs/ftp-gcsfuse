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
mkdir -p $MNT_DIR

chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

echo "Mounting GCS Fuse."
echo $BUCKET
gcsfuse --debug_gcs --debug_fuse -o allow_other --gid $GID --uid $UID $BUCKET $MNT_DIR 
echo "Mounting completed."



echo "Starting vsftpd"
exec /usr/sbin/vsftpd &
echo "Vsftpd started."

# Exit immediately when one of the background processes terminate.
wait
