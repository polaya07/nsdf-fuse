#!/bin/bash

# IMPORTANT: internally the real bucket name will be juicefs-${BUCKET_NAME}



# //////////////////////////////////////////////////////////////////////////
function Install_juicefs() {
	echo "NOTE you need to create a File System named `juicefs-nsdf-fuse-test-juicefs` (see https://juicefs.com/console/)."
	wget -q https://juicefs.com/static/juicefs
	sudo mv juicefs /usr/bin
	chmod +x /usr/bin/juicefs

	# check the version
	juicefs version	
}

# //////////////////////////////////////////////////////////////////////////
function Uninstall_juicefs() {
	sudo rm -f /usr/bin/juicefs
}


# //////////////////////////////////////////////////////////////////
function CreateBucket() {
    echo "CreateBucket  juicefs..."
    aws --endpoint-url ${END_POINT:?} s3api create-bucket --bucket ${BUCKET_NAME:?}s --region ${AWS_DEFAULT_REGION:?}
    echo "CreateBucket  juicefs done"
}

# //////////////////////////////////////////////////////////////////
function RemoveBucket() {
    # note: there is a prefix (!)
	aws s3 rb s3://juicefs-${BUCKET_NAME}--force
}

# //////////////////////////////////////////////////////////////////
function FuseUp() {
    echo "FuseUp juicefs ..."
    sync && DropCache
    mkdir -p ${TEST_DIR}
    juicefs mount \
        ${BUCKET_NAME}s \
        ${TEST_DIR} \
        --cache-dir=${CACHE_DIR} \
        --log=${LOG_DIR}/log.log \
        --max-uploads=150 
    CheckMount ${TEST_DIR}
    echo "FuseUp juicefs done"
}

# //////////////////////////////////////////////////////////////////
function FuseDown() {
    echo "FuseDown juicefs..."
    sync && DropCache
    Retry umount ${TEST_DIR}
    Retry rm -Rf ${BASE_DIR}
    echo "FuseDown juicefs done"
}
