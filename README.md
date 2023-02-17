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
	--privileged \
	--env FTP_PASS=123 \
	--env FTP_USER=user \
	--env BUCKET=c-core-labs-ftp \
	--publish 20-21:20-21/tcp \
	--publish 40000-40009:40000-40009/tcp \
	--volume "$PWD/data:/home/user" \
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

## Start script
```bash
METADATA=http://metadata.google.internal/computeMetadata/v1
SVC_ACCT=$METADATA/instance/service-accounts/default
ACCESS_TOKEN=$(curl -H 'Metadata-Flavor: Google' $SVC_ACCT/token | cut -d'"' -f 4)
docker login -u oauth2accesstoken -p $ACCESS_TOKEN https://gcr.io
docker run --rm -it --privileged --env FTP_PASS=123 --env FTP_USER=user --env BUCKET=c-core-labs-ftp --env MNT_DIR=/home/user --publish 20-21:20-21/tcp --publish 40000-40009:40000-40009/tcp --volume "$PWD/data:/home/user" gcr.io/c-core-labs/ftp-gcsfuse
```

## Deploy to GCP Compute
This also deploys [autoheal](https://github.com/willfarrell/docker-autoheal), which restarts the ftp-gcsfuse container if port 21 is not responsive.

```bash
gcloud compute instances create-with-container ftp-cis-ice-charts \
    --project=c-core-labs \
    --zone=us-central1-a \
    --machine-type=f1-micro \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=455917761237-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=ftp \
    --image=projects/cos-cloud/global/images/cos-stable-101-17162-127-8 \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --boot-disk-device-name=ftp-cis-ice-charts \
    --container-image=gcr.io/c-core-labs/ftp-gcsfuse \
    --container-restart-policy=always \
    --container-privileged \
    --container-env=FTP_USER=ftp-user,FTP_PASS=password1,BUCKET=c-core-labs-ftp \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=container-vm=cos-stable-101-17162-127-8 \
    --metadata=startup-script='#! /bin/bash
    docker run -d \
      --name autoheal \
      --restart=always \
      -e AUTOHEAL_CONTAINER_LABEL=all \
      -v /var/run/docker.sock:/var/run/docker.sock \
      willfarrell/autoheal
    EOF'
```


## Update container via cli
```bash
gcloud compute instances update-container ftp-cis-ice-charts --zone us-central1-a --container-image gcr.io/c-core-labs/ftp-gcsfuse
```


## Notes

### Directories
From https://cloud.google.com/storage/docs/gcs-fuse :
By default, only directories that are explicitly defined (that is, they are their own object in Cloud Storage) will appear in the file system. Implicit directories (that is, ones that are only parts of the pathname of other files or directories) will not appear by default. If there are files whose pathname contain an implicit directory, they will not appear in the overall directory tree (since the implicit directory containing them does not appear). A flag is available to change this behavior. For more information, see the semantics documentation.
