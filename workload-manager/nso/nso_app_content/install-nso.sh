#!/bin/bash
. /usr/local/osmosix/service/utils/agent_util.sh
source /usr/local/osmosix/etc/userenv
exec > >(tee -a /var/tmp/FILENAME_$$.log) 2>&1

#run everything as root
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

agentSendLogMessage "Installing NSO..."

#install necessary packages
yum install java -y
yum install ant -y
yum install wget -y
yum install make -y
yum install python -y

#set variables
nso_version=$(basename "$nso_install_bin" .bin)

#setup download directory
cd /tmp
mkdir nso-binaries
cd nso-binaries

#download nso binaries
wget $nso_repo/$nso_version.bin

#unpack installation files
chmod +x ./$nso_version.bin
sh ./$nso_version.bin

#local install
if [ "$nso_install_type" == "local" ]; then
    #start local installation
    chmod +x ./$nso_version.linux.x86_64.installer.bin
    sh ./$nso_version.linux.x86_64.installer.bin $HOME/$nso_version --local-install

    #source ncsrc
    source $HOME/$nso_version/ncsrc
    echo source $HOME/$nso_version/ncsrc >> $HOME/.bashrc

    #complete local installation
    cd $HOME
    mkdir nso-run
    ncs-setup --dest $HOME/nso-run
    cd $HOME/nso-run

    #edit ncs.conf file
    mv ncs.conf ncs.conf.orig
    cp /opt/remoteFiles/appPackage/nso_app_content/ncs-$nso_install_type.conf ./ncs.conf

    #start nso
    ncs
fi

#system install
if [ "$nso_install_type" == "system" ]; then
    #perform system install
    chmod +x ./$nso_version.bin
    sh ./$nso_version.linux.x86_64.installer.bin --system-install

    #create nso user & groups
    useradd -p $(openssl passwd -1 $nso_user_pw) nso-admin
    groupadd ncsadmin 
    groupadd ncsoper
    usermod -a -G ncsadmin nso-admin
    usermod -a -G ncsadmin root

    #edit ncs.conf file
    cd /etc/ncs
    mv ncs.conf ncs.conf.orig
    cp /opt/remoteFiles/appPackage/nso_app_content/ncs-$nso_install_type.conf ./ncs.conf

    #start nso
    /etc/init.d/ncs start

    #cleanup pre-installed neds
    rm -rf /opt/ncs/current/packages/neds/*
fi

#cleanup
rm -rf /tmp/nso-binaries/*

agentSendLogMessage "Installing NSO...COMPLETE"