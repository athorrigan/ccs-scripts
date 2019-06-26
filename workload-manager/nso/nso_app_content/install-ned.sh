#!/bin/bash
. /usr/local/osmosix/service/utils/agent_util.sh
source /usr/local/osmosix/etc/userenv
exec > >(tee -a /var/tmp/FILENAME_$$.log) 2>&1

#run everything as root
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

agentSendLogMessage "Installing NSO NED..."

nso_package_name=$(basename "$nso_package_name" .bin)

#download ned binaries
cd /tmp/nso-binaries
wget $nso_repo/$nso_package_name.bin

#prepare & unpack ned package
chmod +x $nso_package_name.bin
sh ./$nso_package_name.bin
mkdir $nso_package_name
tar -zxf *.tar.gz -C $nso_package_name --strip-components=1 

#local install
if [ "$nso_install_type" == "local" ]; then
    #mv ned package
    mv $nso_package_name /root/nso-run/packages

    #compile ned package
    cd /root/nso-run/packages/$nso_package_name/src
    make clean all 
fi

#system install
if [ "$nso_install_type" == "system" ]; then
    #mv & ln ned package
    mv $nso_package_name /opt/ncs/current/packages/neds
    ln -s /opt/ncs/current/packages/neds/$nso_package_name /var/opt/ncs/packages

    #compile ned package
    cd /var/opt/ncs/packages/$nso_package_name/src
    make clean all 
fi

#cleanup
rm -rf /tmp/nso-binaries/*

agentSendLogMessage "Installing NSO NED...COMPLETE"
