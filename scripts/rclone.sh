#!/bin/bash


# //////////////////////////////////////////////////////////////////////////
function Install_rclone() {
	wget https://downloads.rclone.org/v1.57.0/rclone-v1.57.0-linux-amd64.deb
	sudo dpkg -i rclone-v1.57.0-linux-amd64.deb
	rm rclone-v1.57.0-linux-amd64.deb

	mkdir -p ~/.config/rclone/
	cat << EOF >> ~/.config/rclone/rclone.conf
[nsdf-test-rclone]
type=s3
provider=Other
access_key_id=${AWS_ACCESS_KEY_ID}
secret_access_key=${AWS_SECRET_ACCESS_KEY}
region=${AWS_DEFAULT_REGION} 
endpoint=https://s3.${AWS_DEFAULT_REGION}.amazonaws.com
EOF
	chmod 600 ~/.config/rclone/rclone.conf

	# check the version
	rclone --version	
}

# //////////////////////////////////////////////////////////////////////////
function Uninstall_rclone() {
	rm -f ~/.config/rclone/rclone.conf
}

# //////////////////////////////////////////////////////////////////
function FuseUp() {
    echo "FuseUp rclone..."
    sync && DropCache
    mkdir -p ${TEST_DIR}

	# note: disabling the cache
    rclone mount \
        nsdf-test-rclone:${BUCKET_NAME} \
        ${TEST_DIR} \
        --uid $UID \
        --daemon \
        --vfs-cache-mode off \
        --use-server-modtime \
        --cache-dir ${CACHE_DIR} 
    
    CheckMount ${TEST_DIR}
    echo "FuseUp rclone done"
}


# //////////////////////////////////////////////////////////////////
function FuseDown() {
    echo "FuseDown rclone..."
    sync && DropCache
    Retry umount ${TEST_DIR}
    Retry rm -Rf ${BASE_DIR}
    echo "FuseDown rclone done"
}