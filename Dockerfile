FROM ubuntu:17.04

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y sudo build-essential debootstrap devscripts debhelper git jq \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -ri 's/^(%sudo.*) ALL$/\1 NOPASSWD: ALL/' /etc/sudoers \
	&& useradd -d /home/builder -m -G sudo builder

ADD build.sh /

USER builder

CMD ["/bin/bash", "build.sh"]
