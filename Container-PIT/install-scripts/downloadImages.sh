#!/bin/bash
#
# Licensed Materials - Property of IBM
# 5725A15, 5724R81
# (c) Copyright IBM Corp. 2010, 2021  All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
echo "=========================================="
echo "Begin downloadImages.sh"
date
if [[ $ScriptsDir = "" ]]; then
	source ./d_utils.sh
	echo $ScriptsDir
fi
start_time_2=$(date +%s)
filename=$ScriptsDir/"status.log"
source $ScriptsDir/../setProperties.sh

function downloadImages_BMX() {
        echo "docker login start..."
        bx api https://api.ng.bluemix.net
        bx login --apikey $APIKEY
        if [ $? -eq 0  ] ;then
            echo "docker login successfully."
        else
            echo "docker authentication error."
            exit_script
        fi
        bx cr login
        docker pull $ARTIFACTORY_URL/$CPE_IMAGE_NAME:$CPE_IMAGE_TAG
        docker pull $ARTIFACTORY_URL/$ICN_IMAGE_NAME:$ICN_IMAGE_TAG
        docker pull $ARTIFACTORY_URL/$DB2_IMAGE_NAME:$DB2_IMAGE_TAG
        docker pull $ARTIFACTORY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG
}

function downloadImages_IBMJDK() {
	jdk_version=$(docker image inspect $JDK_IMAGE_NAME:$JDK_IMAGE_TAG)
	if [ $? -ne 0 ]; then
		echo "Downloading IBM SDK container"
#		docker logout
#		if [[ $REGISTRY_USERNAME != "" ]] && [[ $REGISTRY_PASSWORD != "" ]]; then
#			docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD
#		fi
		docker pull $JDK_IMAGE_NAME:$JDK_IMAGE_TAG
	else
		echo "IBM SDK container already loaded....skipping download"
	fi
}

function downloadImages_Artifatory() {
	# OpenLDAP container download
	req_openldap_version=$(docker image inspect $LDAP_REGISTRY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG)
	if [ $? -ne 0 ]; then
        	echo "Downloading OpenLDAP container from Artifactory: $LDAP_REGISTRY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG"
        	docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $LDAP_REGISTRY_URL
         	if [ $? -eq 0  ] ;then
            		echo "login docker store successfully."
        	else
            		echo "docker authentication error."
            		exit_script
        	fi
        	docker pull $LDAP_REGISTRY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG
	else
					echo "OpenLDAP container already loaded....skipping download"
	fi

	# DB2 container download
	req_db2_version=$(docker image inspect $DB2_REGISTRY_URL/$DB2_IMAGE_NAME:$DB2_IMAGE_TAG)
	if [ $? -ne 0 ]; then
        	echo "Downloading DB2 Container from Artifactory: $DB2_REGISTRY_URL/$DB2_IMAGE_NAME:$DB2_IMAGE_TAG"
		if [[ "Mac"x = "$OS"x ]]; then
        		docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $DB2_REGISTRY_URL
        	fi
        	docker pull $DB2_REGISTRY_URL/$DB2_IMAGE_NAME:$DB2_IMAGE_TAG
	else
					echo "DB2 container already loaded....skipping download"
	fi

	# CPE container download
	cpe_version=$(docker image inspect $CPE_REGISTRY_URL/$CPE_IMAGE_NAME:$CPE_IMAGE_TAG)
  if [ $? -ne 0 ]; then
        	echo "Downloading CPE container from Artifactory:"
        	if [[ "Mac"x = "$OS"x ]]; then
        		docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $DOCKER_REGISTRY_URL
        	fi
					docker pull $CPE_REGISTRY_URL/$CPE_IMAGE_FILE
					docker image tag `docker images | grep cpe | awk '{print $1}'`:`docker images | grep cpe | awk '{print $2}'` $CPE_REGISTRY_URL/$CPE_IMAGE_NAME:$CPE_IMAGE_TAG
					docker rmi `docker images | grep cpe | awk '{print $1}'`:`docker images | grep cpe | awk '{print $2}'`
	else
				echo "CPE container already loaded....skipping download"
	fi

	# ICN container download
	icn_version=$(docker image inspect $ICN_REGISTRY_URL/$ICN_IMAGE_NAME:$ICN_IMAGE_TAG)
  if [ $? -ne 0 ]; then
        	echo "Downloading ICN container from Artifactory:"
        	if [[ "Mac"x = "$OS"x ]]; then
        		docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD $DOCKER_REGISTRY_URL
        	fi
					docker pull $ICN_REGISTRY_URL/$ICN_IMAGE_FILE
					docker image tag `docker images | grep navigator | awk '{print $1}'`:`docker images | grep navigator | awk '{print $2}'` $ICN_REGISTRY_URL/$ICN_IMAGE_NAME:$ICN_IMAGE_TAG
					docker rmi `docker images | grep navigator | grep -v content | awk '{print $1}'`:`docker images | grep navigator | grep -v content | awk '{print $2}'`
	else
					echo "Navigator container already loaded....skipping download"
	fi
}

function extractImages() {
    ########## Validate and load CPE container image ##############
    if [ -f "$DOWNLOAD_LOCATION/$CPE_IMAGE_FILE" ]; then
    	cpe_version=$(docker image inspect $DOCKER_REGISTRY_URL/$CPE_IMAGE_NAME:$CPE_IMAGE_TAG)
#    	if [ $? -ne 0 ]; then
    	if [ 0=1 ]; then

	    	# Create a temp folder to store image archive
		    if [ -d "$TEMP_LOCATION/cpe" ]; then
			    echo "Removing existing $TEMP_LOCATION/cpe folder..."
			    rm -fr "$TEMP_LOCATION/cpe"
		    fi
		    echo "Create a temporary folder to extract CPE container image"
		    mkdir -p $TEMP_LOCATION/cpe

		    # Extract CPE image archive .tar.gz file
		    echo "Extracting CPE container image ..."
		    tar xvzf $DOWNLOAD_LOCATION/$CPE_IMAGE_FILE -C $TEMP_LOCATION/cpe

		    # Load CPE image to docker
		    echo "Loading CPE container image ..."
			echo `ls $TEMP_LOCATION/cpe/images/*.tar.gz`
		    #docker load -i `ls $TEMP_LOCATION/cpe/images/*.tar.gz`
			docker load -i /tmp/cpit_ppa/cpe/images/cpe-sso_ga-558-p8cpe-amd64.tar.gz 
			docker load -i /tmp/cpit_ppa/cpe/images/cpe_ga-558-p8cpe-amd64.tar.gz

		    # Tag CPE docker image
		    echo "Tagging CPE container image...."
#		    docker image tag `docker images | grep cpe | awk '{print $1}'`:`docker images | grep cpe | awk '{print $2}'` $DOCKER_REGISTRY_URL/$CPE_IMAGE_NAME:$CPE_IMAGE_TAG

		    # Remove redundant CPE image
		    docker rmi `docker images | grep cpe | awk '{print $1}'`:`docker images | grep cpe | awk '{print $2}'`

		    # Verify CPE image loaded successfully
		    cpe_version=$(docker image inspect $DOCKER_REGISTRY_URL/$CPE_IMAGE_NAME:$CPE_IMAGE_TAG)
		    if [ $? -ne 0 ]; then
			    echo -e "\033[31mUnable to load the CPE container image\033[0m"
			    echo -e "\033[31mPlease verify the image was downloaded successfully\033[0m"
			    exit_script
		    fi
	    else
		    echo -e "\033[36mCPE container already loaded...skipping extraction and load\033[0m"
	    fi
    else
	    echo -e "\033[31mDownloaded CPE container image $CPE_IMAGE_FILE was not found in $DOWNLOAD_LOCATION\033[0m"
	    echo -e "\033[31mPlease verify the file has been loaded in the specified location\033[0m"
	    exit_script
    fi

    ######### Validate and load ICN container image ###################
    if [ -f "$DOWNLOAD_LOCATION/$ICN_IMAGE_FILE" ]; then
	    icn_version=$(docker image inspect $DOCKER_REGISTRY_URL/$ICN_IMAGE_NAME:$ICN_IMAGE_TAG)
#	    if [ $? -ne 0 ]; then
	    if [ 0=1 ]; then		
            # Create a temp folder to store image archive
            if [ -d "$TEMP_LOCATION/icn" ]; then
			    echo "Removing existing $TEMP_LOCATION/icn folder..."
			    rm -fr "$TEMP_LOCATION/icn"
			fi
            echo "Create a temporary folder to extract ICN container image"
            mkdir -p $TEMP_LOCATION/icn
   
            # Extract ICN image archive .tar.gz files
            echo "Extracting ICN container image ..."
            tar xvzf $DOWNLOAD_LOCATION/$ICN_IMAGE_FILE -C $TEMP_LOCATION/icn

            # Load ICN images - SSO and non-SSO - to docker
            echo "Loading ICN container image ..."
            docker load -i `ls $TEMP_LOCATION/icn/images/*.tar.gz | head -n 1`
            docker load -i `ls $TEMP_LOCATION/icn/images/*.tar.gz | tail -n 1`

            # Tag non-SSO ICN image
            echo "Tagging ICN container image...."
            docker image tag `docker images | grep navigator | grep -v sso | awk '{print $1}'`:`docker images | grep navigator | grep -v sso | awk '{print $2}'` $DOCKER_REGISTRY_URL/$ICN_IMAGE_NAME:$ICN_IMAGE_TAG

            # Remove redundant ICN images
            docker rmi `docker images | grep navigator-sso | grep -v ibmcom | awk '{print $1}'`:`docker images | grep navigator-sso | grep -v ibmcom | awk '{print $2}'`
            docker rmi `docker images | grep navigator | grep -v ibmcom | awk '{print $1}'`:`docker images | grep navigator | grep -v ibmcom | awk '{print $2}'`

            # Verify ICN image loaded successfully
            icn_version=$(docker image inspect $DOCKER_REGISTRY_URL/$ICN_IMAGE_NAME:$ICN_IMAGE_TAG)
            if [ $? -ne 0 ]; then
                echo -e "\033[31mUnable to load the ICN container image\033[0m"
                echo -e "\033[31mPlease verify the image was downloaded successfully\033[0m"
                exit_script
            fi
        else
            echo -e "\033[36mICN container already loaded...skipping extraction and load\033[0m"
        fi
    else
	    echo -e "\033[31mICN container image $ICN_IMAGE_FILE was not found in $DOWNLOAD_LOCATION\033[0m"
	    echo -e "\033[31mPlease verify the file has been loaded in the specified location\033[0m"
	    exit_script
    fi
}


if [[ $GET_IMAGE_FROM_BLUEMIX = "true" ]] || [[ $GET_IMAGE_FROM_BLUEMIX = "yes" ]]; then
	downloadImages_IBMJDK
	downloadImages_BMX
else
	downloadImages_IBMJDK
#	downloadImages_Artifatory
	extractImages
fi

end_time_2=$(date +%s)
duration_2=$((($end_time_2-$start_time_2)/60))
echo "Downloading docker containers and images took $duration_2 minutes"

if [ $? -eq 0 ] ;then
    echo -e "\033[36mFinished downloading/extracting all the images successfully \033[0m"
	  sed -i.bak 's/downloadImages: NotCompleted/downloadImages: Completed/g' $filename
else
    exit_script
fi
echo "=========================================="
