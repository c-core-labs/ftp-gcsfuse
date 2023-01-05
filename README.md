# Ftp-gcsfuse
An FTP server backed by a cloud storage bucket. Adapted from:
- https://github.com/garethflowers/docker-ftp-server
- https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/filesystem

For a guide on using gcsfuse to mount a cloud storage bucket, see:
https://cloud.google.com/run/docs/tutorials/network-filesystems-fuse
	
## Run
```bash
docker run \
	--detach \
	--env FTP_PASS=123 \
	--env FTP_USER=user \
	--env BUCKET=c-core-labs-ftp \
	--publish 20-21:20-21/tcp \
	--publish 40000-40009:40000-40009/tcp \
	--volume /data:/home/user \
	gcr.io/c-core-labs/ftp-gcsfuse
```


## Run interactive
```bash
docker run \
	--rm \
	-it \
	--privileged \
	--env FTP_PASS=123 \
	--env FTP_USER=user \
	--env BUCKET=c-core-labs-ftp \
	--publish 20-21:20-21/tcp \
	--publish 40000-40009:40000-40009/tcp \
	--volume "$PWD/data:/home/user" \
	gcr.io/c-core-labs/ftp-gcsfuse
```


## Service account
To generate a credentials json file:
```bash
gcloud iam service-accounts keys create credentials.json --iam-account=ftp-gcsfuse@c-core-labs.iam.gserviceaccount.com
```
