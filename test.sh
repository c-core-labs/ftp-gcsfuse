#!/bin/sh
set -xe
export IMAGE_NAME=gcr.io/c-core-labs/ftp-gcsfuse

docker build --tag $IMAGE_NAME .
docker run --rm $IMAGE_NAME sh -c 'vsftpd -version 0>&1'

echo "\nOK"
