#########################################################################
# *************** REQUIRED section ****************                     #
# Set / modify the parameters in this section before launching the tool #
#########################################################################

# This will be the password for all LDAP and DB2 users
GLOBAL_PASSWORD=

# License review
LICENSE_ACCEPTED=false

# Docker store credentials
REGISTRY_USERNAME=
REGISTRY_PASSWORD=

# ECM containers downloaded from IBM Passport Advantage
# Images download location
DOWNLOAD_LOCATION=~/PPA
# CPE Container image file name
CPE_IMAGE_FILE=IBM_FNETCPE_5.5.6_LNX_X86_CML.tgz
# Content Navigator image file name
ICN_IMAGE_FILE=IBM_CN_V3.0.9_LINUX_X86_CML.tgz

# Downloaded DB2 container info
# To obtain this info run the command: sudo docker images
DB2_REGISTRY_URL=ibmcom
DB2_IMAGE_NAME=db2
DB2_IMAGE_TAG=latest

# Downloaded OpenLDAP container info
# To obtain this info run the command: sudo docker images
LDAP_REGISTRY_URL=osixia
LDAP_IMAGE_NAME=openldap
LDAP_IMAGE_TAG=latest

# CPE Domain and Object Store names
P8DOMAIN_NAME=P8Domain
P8OS_NAME=P8ObjectStore

# ICN Repository and Desktop parameters
REPOSITORY_NAME=P8Repository
DESKTOP_NAME=ECM
DESKTOP_ID=ecm
DESKTOP_DES="This is a Demo desktop"

#######################################################################
# --------------- Optional section -----------------                  #
# Do not change the parameter values in this section unless necessary #
#######################################################################

# Temporary folder to extract the downloaded ECM container images
TEMP_LOCATION=/tmp/cpit_ppa

# Operating system - will be set automatically at runtime
OS=
# Host name - will be set automatically at runtime
HOST_NAME=

# Minimum supported docker version
MIN_DOCKER_VERSION=20

# Container startup timeout - minutes
TIME_OUT=15

# User and Group Ids for running the containers
U_UID=50001
G_GID=50000

# CPE container mount volumes
CPE_CONFIGFILES_LOC=~/cpit_data/cpe_data
CPE_FILENET_FOLDER=FileNet
CPE_LOGS_FOLDER=logs
CPE_ASA_FOLDER=asa
CPE_TEXTEXT_FOLDER=textext
CPE_ICMRULES_FOLDER=icmrules
CPE_BOOTSTRAP_FOLDER=bootstrap
CPE_OVERRIDES_FOLDER=configDropins/overrides

# ICN container mount volumes
ICN_CONFIGFILES_LOC=~/cpit_data/icn_data
ICN_VIEWERLOG_FOLDER=viewerlog
ICN_VIEWERCACHE_FOLDER=viewercache
ICN_PLUGINS_FOLDER=plugins
ICN_ASPERA_FOLDER=Aspera
ICN_LOGS_FOLDER=logs
ICN_OVERRIDES_FOLDER=configDropins/overrides

# DB2 container mount volumes
DB2_CONFIGFILES_LOC=~/cpit_data/db2_data
DB2_SCRIPT=db2script
DB2_STORAGE_FOLDER=storage

# Common config files
DB2JCC_LICENSE_CU=db2jcc_license_cu.jar
DB2JCC4=db2jcc4.jar
DB2JCCDRIVER=DB2JCCDriver.xml
LDAP=ldap.xml

# CPE config files
FNGCDDS=FNGCDDS.xml
FNDOSDS=OS1DB.xml
PROPS=props.jar

# ICN config files
ICNDS=ICNDS.xml

# DB2 config files
GCDDB_SCRIPT=GCDDB.sh
OS1DB_SCRIPT=OS1DB.sh
ICNDB_SCRIPT=ICNDB.sh
ENV_LIST=.env_list
SETUP_DB=setup_db.sh
DB2_ONE_SCRIPT=DB2_ONE_SCRIPT.sql

# CPE container parameters
DOCKER_REGISTRY_URL=ibmcom
CPE_CONTAINER_NAME=cpe
CPE_HTTP_PORT=9080
CPE_HTTPS_PORT=9443
CPE_IMAGE_NAME=filenet_content_platform_engine
CPE_IMAGE_TAG=latest
CPE_CONTAINER_HOST_NAME=cpe-host1
CPE_RESTART=always

# ICN container parameters
ICN_CONTAINER_NAME=icn
ICN_HTTP_PORT=9081
ICN_HTTPS_PORT=9444
ICN_IMAGE_NAME=content_navigator
ICN_IMAGE_TAG=latest
ICN_RESTART=always

# DB2 container parameters
DB2_CONTAINER_NAME=db2
DB2_HOST_NAME=db2server_V11.5.0.0
DB2_HTTP_PORT=50000
DB2_RESTART=always
DB2_PRIVILEGED=true

# LDAP container parameters
LDAP_CONTAINER_NAME=ldap
LDAP_PORT=389
LDAP_HTTP_PORT=80
LDAP_RESTART=always

# JDK container parameters
JDK_IMAGE_NAME=ibmjava
JDK_IMAGE_TAG=8-sdk
JDK_CONTAINER_NAME=ibmjdk

# CPE domain parameters
P8ADMIN_USER=P8Admin
P8ADMIN_GROUP=P8Admins

# Workflow system parameters
ISOLATED_REGION=IR01
PE_CONNPT_NAME=P8ConnPt1
PE_REGION_NUMBER=1
SYSTEM_ADMIN_GROUP=P8Admins
SYSTEM_CONFIG_GROUP=P8Admins

# LDAP parameters
LDAP_BASE_DN="dc=ecm,dc=ibm,dc=com"
LDAP_DOMAIN="ecm.ibm.com"
LDAP_LDIF="
dn: cn=P8Admin,dc=ecm,dc=ibm,dc=com
cn: P8Admin
sn: P8Admin
userpassword: $GLOBAL_PASSWORD
objectclass: top
objectclass: organizationalPerson
objectclass: person

dn: cn=tester,dc=ecm,dc=ibm,dc=com
cn: tester
sn: tester
userpassword: $GLOBAL_PASSWORD
objectclass: top
objectclass: organizationalPerson
objectclass: person

dn: cn=P8Admins,dc=ecm,dc=ibm,dc=com
objectclass: groupOfNames
objectclass: top
cn: P8Admins
member: cn=P8Admin,dc=ecm,dc=ibm,dc=com

dn: cn=GeneralUsers,dc=ecm,dc=ibm,dc=com
objectclass: groupOfNames
objectclass: top
cn: GeneralUsers
member: cn=P8Admin,dc=ecm,dc=ibm,dc=com
member: cn=tester,dc=ecm,dc=ibm,dc=com
"
#read acl for everybody
LDAP_ACL="
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: to * by * read
"

########################
# For future releases  #
########################

# Bluemix credentials
GET_IMAGE_FROM_BLUEMIX=NO
APIKEY=
BLUEMIX_URL=registry.ng.bluemix.net/ecmcondev
