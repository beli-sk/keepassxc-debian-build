FROM ubuntu:17.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential debootstrap devscripts git \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends debhelper cmake qtbase5-dev qttools5-dev \
		qttools5-dev-tools libgcrypt20-dev zlib1g-dev libxi-dev libxtst-dev libqt5x11extras5-dev libyubikey-dev libykpers-1-dev

RUN sed -ri 's/^(%sudo.*) ALL$/\1 NOPASSWD: ALL/' /etc/sudoers \
	&& useradd -d /home/builder -m -G sudo builder

ADD build.sh /

USER builder

CMD ["/bin/bash", "build.sh"]
