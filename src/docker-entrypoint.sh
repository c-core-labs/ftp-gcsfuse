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
chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

touch /var/log/vsftpd.log
tail -f /var/log/vsftpd.log | tee /dev/stdout &
touch /var/log/xferlog
tail -f /var/log/xferlog | tee /dev/stdout &

exec "$@"
