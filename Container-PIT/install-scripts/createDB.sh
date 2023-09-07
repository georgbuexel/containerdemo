#!/bin/bash
#
# Licensed Materials - Property of IBM
# 5747-SM3
# (c) Copyright IBM Corp. 2017, 2021  All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
echo "=========================================="
date
echo "Creating databases: GCDDB,ICNDB,OS1DB..."
sleep 3
containerID=`docker ps -aqf "name=$DB2_CONTAINER_NAME"`
docker cp $DB2_CONFIGFILES_LOC/$DB2_SCRIPT/DB2_ONE_SCRIPT.sql $containerID:/home/db2inst1/
docker cp $DB2_CONFIGFILES_LOC/$DB2_SCRIPT/GCDDB.sh $containerID:/home/db2inst1/
docker cp $DB2_CONFIGFILES_LOC/$DB2_SCRIPT/ICNDB.sh $containerID:/home/db2inst1/
docker cp $DB2_CONFIGFILES_LOC/$DB2_SCRIPT/OS1DB.sh $containerID:/home/db2inst1/
docker cp $DB2_CONFIGFILES_LOC/$DB2_SCRIPT/setup_db.sh $containerID:/home/db2inst1/
docker exec -d $DB2_CONTAINER_NAME /bin/bash /home/db2inst1/setup_db.sh

exit_script(){
    exit
}

if [ $? -eq 0 ] ;then
        echo -e "\033[36m$0 Databases created uccessfully. \033[36m"
else
        echo -e "\033[31m$0 Database creation failed. \033[36m"
        exit_script
fi
echo "=========================================="
