#!/usr/bin/env bash

today=$(date '+%Y%m%d-%H%M%S')

case "$1" in
  --help | -h)
    echo "Usage: start-google-cloud-compute-vm-instance.sh {project} {instance-name} {service-account} {availability-zone}"
    exit 1
  ;;
  _ | *)
    PROJECT="${1:-pa-dpatel}"
    SERVICE_ACCOUNT="${2:-462840544147-compute@developer.gserviceaccount.com}"
    INSTANCE_NAME="${3:-instance-$today}"
    ZONE="${4:-us-west1-b}"
  ;;
esac

echo "I will now create a VM instance"

gcloud beta compute instances create \
  $INSTANCE_NAME \
  --project=$PROJECT \
  --zone=$ZONE \
  --machine-type=n2d-standard-4 \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --no-restart-on-failure \
  --maintenance-policy=TERMINATE \
  --provisioning-model=SPOT \
  --instance-termination-action=DELETE \
  --max-run-duration=3600s \
  --service-account=$SERVICE_ACCOUNT \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240319,mode=rw,size=60,type=projects/$PROJECT/zones/$ZONE/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

echo "To connect to this VM, try executing this command in your terminal shell:"
echo "» gcloud compute ssh --zone $ZONE $INSTANCE_NAME --project $PROJECT"
