#!/bin/bash
#
# Licensed Materials - Property of IBM
# 5747-SM3
# (c) Copyright IBM Corp. 2017, 2021  All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
os_type=`uname -a | awk '{ print $1 }'`
source $ScriptsDir/../setProperties.sh

function exit_script(){
    exit
}

function mini_requirement(){
	echo -e "\033[32mMinimum system requirements are:
	* 2 CPU cores
	* 8 GB of memory
	* 50 GB disk
	* Ubuntu 18.04 or 20.04
	* Mac OS X 10.15.x 
	* Docker CE or EE 19.x
	* OpenLDAP 1.4.0 container from:
	 	https://hub.docker.com/r/osixia/openldap/
	* DB2 Container v11.5.5.0 from:
		https://hub.docker.com/r/ibmcom/db2
	* IBM FileNet Content Platform Engine 5.5.6 and
	  IBM Content Navigator 3.0.9 containers from:
	 	IBM Passport Advantage - https://www.ibm.com/software/passportadvantage/pao_customer.html \033[0m"
	exit_script
}

if [[ "Linux" = "$os_type" ]]; then
		echo "The script are running on a Linux OS, below is the system info:"
		os_version=`/bin/cat /etc/issue.net`
		os_kernel=`lsb_release -c | grep "Codename" | awk '{ print $2 }'`
		hostname=`uname -n`
		ip=`hostname --all-ip-addresses`
		cpu_info=`cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c`
		number_of_cpu=`grep -c 'model name' /proc/cpuinfo`
		free=`/usr/bin/free -h | /bin/sed 's/Mem:   /Memory:/g' | /usr/bin/awk 'NR < 4'`
		total_memory=`/usr/bin/free -h | /bin/sed 's/Mem:   /Memory:/g' | /usr/bin/awk 'NR < 4' | grep "Memory" | awk '{print $2}' | cut -f 1 -d "G" | awk '{printf("%0.f\n",$0)}'`
		disk=`/bin/df --sync -h -l -t 'ext4'`
		avail_disk=`/bin/df --sync -h -l -t 'ext4' | grep dev | awk '{print $4}' | cut -f 1 -d "G"`
		disk_usage_rate=`/bin/df --sync -h -l -t 'ext4' | grep dev | awk '{print $5}' | cut -f 1 -d "%"`
		cpu_load=`/usr/bin/uptime | /bin/sed 's/, /\//g' | /usr/bin/awk '{print $(NF-0)}'`
		cpu_load_15=`/usr/bin/uptime | /bin/sed 's/, /\//g' | /usr/bin/awk '{print $(NF-0)}' | awk -F '/' '{print $3}'`
		cpu_usage_left=`top -b -n 1 | grep Cpu | awk -F ',' '{print $4}' | cut -f 1 -d "."`
		cpu_usage_rate=`expr 100 - $cpu_usage_left`
		/bin/echo "================================================================================"
		/bin/echo "${bold}Host  name:${normal} $hostname"
		/bin/echo "${bold}IP address:${normal} $ip"
		/bin/echo "${bold}OS version:${normal} $os_version"
		/bin/echo "${bold}Kernel:    ${normal} $os_kernel"
		/bin/echo "${bold}CPU:       ${normal} $cpu_info"
		/bin/echo "${bold}CPU load average (1/5/15 mins): ${normal}$cpu_load"
		/bin/echo "${bold}CPU usage: ${normal}$cpu_usage_rate%"
		/bin/echo "--------------------------------------------------------------------------------"
		/bin/echo "$free"
		/bin/echo -e "\r"
		/bin/echo "--------------------------------------------------------------------------------"
		/bin/echo "$disk"
		/bin/echo "================================================================================"
		sed -i 's/OS=.*$/OS=Linux/g' $ScriptsDir/../setProperties.sh

		if [ 2 -gt $number_of_cpu ]; then
		  echo "\033[31mYou need at least 2 CPU cores\033[0m"
		  mini_requirement
		fi

		minimum_disk=50
		if (($avail_disk < $minimum_disk)); then
		  echo "\033[31mThe avail disk of $hostname is $avail_disk GB\033[0m"
		  mini_requirement
		fi

		minimum_total_memory=7
		if (($total_memory < $minimum_total_memory)); then
		  echo -e "\033[31mThe RAM of $hostname is $total_memory GB\033[0m"
		  mini_requirement
		fi

	elif [[ "Darwin" = "$os_type" ]]; then
		echo "The script are running on a Mac OS, below is the system info:"
		os_name=`sw_vers | grep "ProductName" | awk -F ':' '{ print $2 }'`
		os_product_version=`sw_vers | grep "ProductVersion" | awk -F ':' '{ print $2 }' | sed 's/[[:space:]]//g'`
		host_name=`uname -n`
		os_kernel=`uname -v | awk -F ':' '{print $1}'`
		cpu_count=`sysctl -n machdep.cpu.core_count`
		cpu_info=`sysctl -n machdep.cpu.brand_string`
		cpu_load=`/usr/bin/uptime | awk -F 'averages:' '{ print $2 }'`
		disk_info=`df -h`
		avail_disk_space=`df -h | grep "disk1" | awk '{ print $4 }' | head -1 | cut -f 1 -d "G" | sed 's/[[:space:]]//g'`
		memory=`top -l 1 -s 0 | grep PhysMem`
		total_memory=`python3 ./install-scripts/config-files/Mac/mac_free.py | grep "Real Mem Total" | awk -F ":" '{ print $2 }' | cut -f 1 -d "G" | sed 's/[[:space:]]//g'`
		/bin/echo "================================================================================"
		/bin/echo "${bold}Host  name:${normal} $host_name"
		/bin/echo "${bold}OS version:${normal} $os_name ${normal} $os_product_version"
		/bin/echo "${bold}Kernel:    ${normal} $os_kernel"
		/bin/echo "${bold}CPU:       ${normal} $cpu_count ${normal} $cpu_info"
		/bin/echo "${bold}CPU load average (1/5/15 mins): ${normal}$cpu_load"
		/bin/echo "--------------------------------------------------------------------------------"
		/bin/echo "$memory"
		/bin/echo "--------------------------------------------------------------------------------"
		/bin/echo "$disk_info"
		/bin/echo "================================================================================"
		sed -i "" 's/OS=.*$/OS=Mac/g' $ScriptsDir/../setProperties.sh

		if [[ 2 -gt $((cpu_count)) ]]; then
		  echo "\033[31mYou need at least 2 CPU cores\033[0m"
		  mini_requirement
		fi

		minimum_disk=50
		if [[ $((avail_disk_space)) -lt $((minimum_disk)) ]]; then
		  echo "\033[31mThe avail disk of $host_name is $avail_disk_space GB\033[0m"
		  mini_requirement
		fi

		# minimum_total_memory=4
		# if [[ $((total_memory)) -lt $((minimum_total_memory)) ]]; then
		#   echo -e "\033[31mThe RAM of $host_name is $total_memory GB\033[0m"
		#   mini_requirement
		# fi

        minimum_os_product_version=10.15.5
        OLD_IFS="$IFS"
        IFS='.'
        minimum_version_arr=($minimum_os_product_version)
        product_version_arr=($os_product_version)
        IFS=$OLD_IFS
        length=0
        for x in ${product_version_arr[@]}; do
        	let length++
        done

        if [ ${product_version_arr[0]} -lt ${minimum_version_arr[0]} ]; then
        	echo -e "\033[31mYour MacOS production version is $os_product_version\033[0m"
          	mini_requirement
        elif [ ${product_version_arr[0]} -eq ${minimum_version_arr[0]} ]; then
        	if [ ${product_version_arr[1]} -lt ${minimum_version_arr[0]} ]; then
        		echo -e "\033[31mYour MacOS production version is $os_product_version\033[0m"
          		mini_requirement
          	elif [ ${product_version_arr[1]} -eq ${minimum_version_arr[1]} ]; then
          		if [ ${product_version_arr[2]} -lt ${minimum_version_arr[2]} ]; then
          			echo -e "\033[31mYour MacOS production version is $os_product_version\033[0m"
          			mini_requirement
          		fi
          	fi
        fi
	else
				echo "\033[31mNot supported OS, exit now...\033[0m"
				mini_requirement
fi

source $ScriptsDir/../setProperties.sh

###### Validate Docker version #############
# Is docker installed?
if [ -f /usr/bin/docker -o -f /usr/local/bin/docker ]; then
        req_docker_version=$(docker version -f '{{.Client.Version}}'|head -c 2)
        if [ $? -ne 0 ]; then
        echo -e "\033[31mUnable to execute the 'docker version' command.  Is it installed and added to your system PATH?\033[0m"
        echo -e "\033[31mMore information can be found at https://docs.docker.com/install/\033[0m"
        mini_requirement
        else
                if [ $req_docker_version -lt $MIN_DOCKER_VERSION ]; then
                        echo -e "\033[31mYour Docker version is $req_docker_version and must be at least ${MIN_DOCKER_VERSION}\033[0m"
                        echo -e "\033[31mMore information can be found at https://docs.docker.com/install/\033[0m"
                        mini_requirement
                fi
        fi
else
        echo -e "\033[31mDocker not found.  Is it installed and in your system PATH?\033[0m"
        echo -e "\033[31mMore information can be found at https://docs.docker.com/install/\033[0m"
        mini_requirement
fi

######### Validate OpenLDAP container image ################
req_openldap_version=$(docker image inspect $LDAP_REGISTRY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG)
if [ $? -ne 0 ]; then
    echo -e "\033[31mOpenLDAP container not found. Did you pull the latest image from Docker Hub?\033[0m"
    echo -e "\033[31mE.g., docker pull $LDAP_REGISTRY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG\033[0m"
    mini_requirement
else
	echo -e "\033[36mFound correct OpenLDAP container\033[0m"
fi

######### Validate DB2 container image ################
req_db2_version=$(docker image inspect $DB2_REGISTRY_URL/$DB2_IMAGE_NAME:$DB2_IMAGE_TAG)
if [ $? -ne 0 ]; then
    echo -e "\033[31mDB2 container not found. Did you pull the latest image from Docker Hub?\033[0m"
    echo -e "\033[31mE.g., docker pull $LDAP_REGISTRY_URL/$LDAP_IMAGE_NAME:$LDAP_IMAGE_TAG\033[0m"
    mini_requirement
else
	 echo -e "\033[36mFound correct DB2 container\033[0m"
fi
