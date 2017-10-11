KeePassXC Debian packaging container
====================================

Usage
-----

    docker build -t keepassxc_build .
    
    docker run -ti --rm -e DEBUG=1 \
      -e GITHUB_TOKEN=<github_auth_token> \
      -e UPSTREAM_VERSION=<upstream_version> \
      -e DEBIAN_RELEASE=<debian_release> \
      -e GITHUB_TAG=<github_tag> \
      keepassx

