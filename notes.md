FileNet Container Demo
===

https://www.reddit.com/r/IBM/comments/yk2nvt/ibm_filenet_docker_image/?rdt=59638

```
FileNet CPE container is supported on CNCF kube (beside OCP)

here the latest image (need a login to the IBM registry)

cp.icr.io/cp/cp4a/fncm/cpe:ga-5511-p8cpe

here a LTSR cp.icr.io/cp/cp4a/fncm/cpe:ga-558-p8cpe-if004

Must be deployed via Operator for an supported Env.

IBM had a quick start/demo for docker but pulled it: https://github.com/ibm-ecm/container-demo

here GH forks https://github.com/weilaiprft/container-demo

and https://github.com/TiloGit/container-demo
```


[IBM GitHub](https://github.com/ibm-ecm)

(https://github.com/ibm-ecm/container-demo)


Clones of the pulled official container-demo repo:

* https://github.com/weilaiprft/container-demo
* https://github.com/TiloGit/container-demo


    git clone -b 5.5.x https://github.com/ibm-ecm/container-samples


IBM DD download client:

Install brew

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> /Users/inzitzma/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"

Install OpenJDK + OpenWebStart (run .jnlp)

    brew install openjdk

https://openwebstart.com/docs/OWSGuide.html#_installation

    brew install --cask openwebstart




# Prep

Mac Prep:

    brew install python
    python3 -V


## LDAP
OpenLDAP with TLS, multi master replication and easy bootstrap.

    docker pull osixia/openldap

## DB/2

    docker pull icr.io/db2_community/db2 

Note:

    Community Edition is automatically enabled and has the following limitations, which are automatically enforced:

    Memory limit: 16GB
    Core limit: 4 cores


(old via dockerhub) https://hub.docker.com/r/ibmcom/db2




## ICN

    docker pull icr.io/cpopen/icn/navigator:ga-3014-icn


## FileNet P8 LTS:

    docker login cp.icr.io -u ingo.zitzmann@btc-ag.ch -p <password>
    docker pull cp.icr.io/cp/cp4a/fncm/cpe:ga-558-p8cpe-if004



https://www.ibm.com/docs/en/filenet-p8-platform/5.5.x?topic=operators-getting-access-new-container-images

### 5.5.6:

https://www.ibm.com/support/pages/download-ibm-filenet-content-manager-version-556

|Component Description|eSD Part Number|
|---|---|
IBM FileNet Content Platform Engine V5.5.6 Linux x86 Container Multilingual|CC8SVML
IBM Content Navigator V3.0.9 Linux x86 Container Multilingual|CC8SJML

### 5.5.8:

https://www.ibm.com/support/pages/download-ibm-filenet-content-manager-version-558

|Component Description|eSD Part Number|
|---|---|
IBM FileNet Content Platform Engine V5.5.8 ML Linux x86 Container|M03N7ML
IBM Content Navigator V3.0.11 Linux x86 Container Multilingual|M03NVML

~~Download via [Find Downloads and Media](http://www.ibm.com/software/howtobuy/passportadvantage/pao_customers.htm)~~

https://partnerportal.ibm.com/s/software-access-catalog



docker login <registry url> -u <ADMINISTRATOR> -p <password>





    docker load -i  /tmp/cpit_ppa/cpe/images/cpe-sso_ga-558-p8cpe-amd64.tar.gz 
    

docker tag cpe-sso:ga-558-p8cpe-amd64 cpe-sso:latest

# Run

## Load images manually

This one seems to work (otherwise authentication)

    docker load -i cpe_ga-558-p8cpe-amd64.tar.gz
    docker load -i navigator_ga-3011-icn-amd64.tar.gz

    docker tag cpe:ga-558-p8cpe-amd64 ibmcom/filenet_content_platform_engine:latest
    docker tag navigator:ga-3011-icn-amd64 ibmcom/content_navigator:latest

## Disable download in install script

Skip downloadImages as not working any longer (TODO: revisit: docker login etc.)

__cpit.sh:__

```sh
if grep -q "downloadImages: Completed" $filename; then
    echo "Skipping downloadImages.sh, as it was completed during previous execution!"
else
    echo "downloadImages.sh was not run before, running now!"
#    source $ScriptsDir/downloadImages.sh
fi
```

__*.sh:__

remove "s" after 30:

```sh
        else
                echo "$i. Navigator has not started yet, wait 30 seconds and try again...."
                sleep 30
                let i++
```


## Run script


./cpit.sh

```Start CPE docker container now...```


cpe-host1



# Test

"Ping Page":
<server>/FileNet/Engine


- Administration Console for Content Platform Engine: https://<hostname>:9443/acce
	- User name: P8Admin
	- Password: GLOBAL_PASSWORD

- IBM Content Navigator: https://<hostname>:9444/navigator
	- User name: P8Admin
	- Password: GLOBAL_PASSWORD


---

"WebSphere Liberty" ("light")



DB/2


Begin to create ICNDB database
==========================================
Executing CreateICNDB Commands ...
Wed Sep  6 08:24:05 UTC 2023
Starting DB operations...
SQL1024N  A database connection does not exist.  SQLSTATE=08003
Creating ICNDB database and tablespaces...
/db2fs/ICNDB
DB20000I  The CREATE DATABASE command completed successfully.

   Database Connection Information

 Database server        = DB2/LINUXX8664 11.5.8.0
 SQL authorization ID   = DB2INST1
 Local database alias   = ICNDB

DB20000I  The UPDATE DATABASE CONFIGURATION command completed successfully.
SQL1363W  One or more of the parameters submitted for immediate modification
were not changed dynamically. For these configuration parameters, the database
must be shutdown and reactivated before the configuration parameter changes
become effective.
DB20000I  The SQL command completed successfully.

---

SSO

    docker load -i  ~/Temp/images/cpe-sso_ga-558-p8cpe-amd64.tar.gz
    docker load -i  ~/Temp/images/navigator-sso_ga-3011-icn-amd64.tar.gz

    docker tag cpe-sso:ga-558-p8cpe-amd64 ibmcom/filenet_content_platform_engine:latest
    docker tag navigator-sso:ga-3011-icn-amd64 ibmcom/content_navigator:latest
