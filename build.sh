#!/bin/bash

set -e pipefail

function fail {
	echo "$1" >&2
	exit 1
}

export ARCH=`dpkg --print-architecture`
export PACKAGE_NAME=keepassxc
[[ -z "$UPSTREAM_VERSION" ]] && fail "Parameter UPSTREAM_VERSION missing."
[[ -z "$DEBIAN_RELEASE" ]] && fail "Parameter DEBIAN_RELEASE missing."
export BUILD_DEPS='cmake qtbase5-dev qttools5-dev qttools5-dev-tools libgcrypt20-dev zlib1g-dev libxi-dev libxtst-dev libqt5x11extras5-dev libyubikey-dev libykpers-1-dev'
export GITHUB_REPO="beli-sk/keepassxc-debian"
[[ -z "$GITHUB_TAG" ]] && fail "Parameter GITHUB_TAG missing."
export UPLOAD=${UPLOAD:-1}

function admin_shell {
	exec /bin/bash
}

[[ "$DEBUG" -eq 1 ]] && trap admin_shell EXIT

cd /home/builder

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${BUILD_DEPS}

# download & unpack upstream source
wget -O "${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz" "https://github.com/keepassxreboot/keepassxc/releases/download/${UPSTREAM_VERSION}/${PACKAGE_NAME}-${UPSTREAM_VERSION}-src.tar.xz"
tar -Jxf "${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz"
cd "${PACKAGE_NAME}-${UPSTREAM_VERSION}"
# download packaging config
git clone https://github.com/${GITHUB_REPO}.git debian
cd debian
git checkout "tags/${GITHUB_TAG}"
cd ..
# build package
debuild -uc -us --build=source,binary
cd ..
if [[ "$UPLOAD" -eq 1 ]] ; then
	# get upload URL for release by tag
	UPLOAD_URL=`curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${GITHUB_TAG}" | jq -r '.upload_url' | cut -d'{' -f1`
	# upload deb file
	curl -H "Authorization: token ${GITHUB_TOKEN}" -H 'Content-type: application/vnd.debian.binary-package' -X POST -d "@${PACKAGE_NAME}_${UPSTREAM_VERSION}-${DEBIAN_RELEASE}_amd64.deb" "${UPLOAD_URL}?name=${PACKAGE_NAME}_${UPSTREAM_VERSION}-${DEBIAN_RELEASE}_amd64.deb"
	# upload source package files
	curl -H "Authorization: token ${GITHUB_TOKEN}" -H 'Content-type: text/plain' -X POST -d "@${PACKAGE_NAME}_${UPSTREAM_VERSION}-${DEBIAN_RELEASE}.dsc" "${UPLOAD_URL}?name=${PACKAGE_NAME}_${UPSTREAM_VERSION}-${DEBIAN_RELEASE}.dsc"
	curl -H "Authorization: token ${GITHUB_TOKEN}" -H 'Content-type: application/x-xz' -X POST -d "@${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz" "${UPLOAD_URL}?name=${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz"
	curl -H "Authorization: token ${GITHUB_TOKEN}" -H 'Content-type: application/x-xz' -X POST -d "@${PACKAGE_NAME}_${UPSTREAM_VERSION}-${DEBIAN_RELEASE}.debian.tar.xz" "${UPLOAD_URL}?name=${PACKAGE_NAME}_${UPSTREAM_VERSION}-${DEBIAN_RELEASE}.debian.tar.xz"
fi
