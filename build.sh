#!/bin/bash

export KEEPASSXC_VERSION 2.2.1
export KEEPASSXC_RELEASE 1

cd /home/builder

git clone https://github.com/magkopian/keepassxc-debian.git
cd keepassxc-debian
git checkout ${KEEPASSXC_VERSION}-${KEEPASSXC_RELEASE}
cd keepassxc-${KEEPASSXC_VERSION}
debuild -b -uc -us
cd ..
