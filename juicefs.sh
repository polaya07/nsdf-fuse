#!/bin/bash
set -e # exit when any command fails

source ./utils.sh
source ./disk.sh
InitFuseBenchmark juicefs


echo "///////////////////////////////////////////////////////////////////////"
echo "WARNING the JuiceFs file system must have been created in juicefs      "
echo "WARNING the File system to create must have a name nsdf-test-juicefs   "
echo "WARNING see https://juicefs.com/console/create                         "
echo "WARNING the token must be set as environment variable                  "
echo "///////////////////////////////////////////////////////////////////////"

export JUICE_TOKEN=${JUICE_TOKEN:-XXXXX}

# install juicefs
if [[ ! -f /usr/bin/juicefs ]] ; then
    wget -q https://juicefs.com/static/juicefs
    chmod +x juicefs 
    sudo mv juicefs /usr/bin
fi
echo $(which juicefs)

# IMPORTANT: internally the real bucket name will be juicefs-${BUCKET_NAME}
juicefs auth \
    ${BUCKET_NAME} \
    --token ${JUICE_TOKEN} \
    --accesskey ${AWS_ACCESS_KEY_ID} \
    --secretkey ${AWS_SECRET_ACCESS_KEY} 

function FuseUp() {
    # TODO: make sure juicefs is not using RAM cache
    echo "FuseUp"
    juicefs mount \
        ${BUCKET_NAME} \
        ${TEST_DIR} \
        --log=${LOG_DIR}/log.log \
        --max-uploads=150 \
        --cache-dir=${CACHE_DIR} \
        --cache-size=${DISK_CACHE_SIZE_MB}  
    mount | grep ${TEST_DIR} # to make sure it's mounted
}

RunDiskTest ${TEST_DIR}
aws s3 rb --force s3://juicefs-${BUCKET_NAME}  
rm -Rf ${BASE_DIR}



