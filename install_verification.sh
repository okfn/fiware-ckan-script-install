#!/bin/bash -ex

# The script is aborted if any command fails. If it is OK that a comand fails,
# use ./mycomand || true

# log into the VM and check the service
# use debian user for Debian7, ubuntu for Ubuntu12.04/Ubuntu14.04, centos for Centos6/Centos7

# vagrant ssh default -- 'bash -s' < ckan2.5_install_verification.sh
ssh ubuntu@$IP -- 'bash -s' < ckan2.5_install_verification.sh
