#!/bin/bash

# Defines the GCP Project in which in VM instances will be created in
PROJECT_ID="tubccassignment01" 

# Defines the Zone in which the VM instances will be created in (europe-west4-a supports c3 type machines)
ZONE="europe-west4-a" 

# Defines the Boot Images: Ubuntu 22.04 (Long-Term-Support) 
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"

# Defines the username for SSH access
SSH_USERNAME="ubuntu"

# "standard-4" means it uses 4 vCPUs and balanced vCPUs/memory (e.g. 4GB memory per vCPU)
# "c3"         means family=computer-optimized   and generation=3
# "c4"         means family=computer-optimized   and generation=3
# "n4"         means family=general-purpose      and generation=4
MACHINE_TYPES=(
  "c3-standard-4"
  "c4-standard-4"
  "n4-standard-4"
)


echo "--- Starte die VM-Erstellung in GCP Projekt: ${PROJECT_ID} in Zone: ${ZONE} ---"

# Setze das aktive Projekt für gcloud
gcloud config set project "${PROJECT_ID}"
if [ $? -ne 0 ]; then
    echo "FEHLER: Konnte das gcloud Projekt nicht setzen. Bitte Projekt-ID überprüfen."
    exit 1
fi

# --- SSH Key Pair Generation ---
# Generate a local SSH key pair and name the output files id_rsa and id_rsa.pub
# Make sure to specify a valid username as the comment in the public key
if [ ! -f id_rsa ]; then
    echo "-> Generiere SSH-Key-Paar..."
    ssh-keygen -t rsa -b 4096 -f id_rsa -C "${SSH_USERNAME}" -N ""
fi

# --- Hauptschleife zur Erstellung der Instanzen ---

for MACHINE_TYPE in "${MACHINE_TYPES[@]}"; do

    # defines a name that is then used for the VM
    INSTANCE_NAME="vm-${MACHINE_TYPE}" # vm zu cc ändern
    
    echo "-> Starte Instanz: ${INSTANCE_NAME} mit Typ ${MACHINE_TYPE}..."

    gcloud compute instances create "${INSTANCE_NAME}" \
        # defines the Zone we are in (vm's are zono-specific)
        --zone="${ZONE}" \
        # defines the machine type 
        --machine-type="${MACHINE_TYPE}" \
        # defines the boot image
        --image-project="${IMAGE_PROJECT}" \
        --image-family="${IMAGE_FAMILY}" \
        # defines how much disk size we need 
        --boot-disk-size="100GB" \
        # defines the tags
        --tags="cc" \
        # enable nested virtualization
        --enable-nested-virtualization \
        # defines that we dont need a public IP for the VM's
        --no-address

    # checks if the VM was succesfully created
    if [ $? -eq 0 ]; then
        echo "   [SUCCESS] Instance ${INSTANCE_NAME} was started successfully."
    else
        echo "   [ERROR] Instance ${INSTANCE_NAME} could not be started."
    fi

done

