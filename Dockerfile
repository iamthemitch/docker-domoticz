FROM  debian:stable-slim

ENV   port 8080

LABEL maintainer="Guillaume LAURENT <laurent.guillaume@gmail.com>"

RUN \
# Packages and system setup
apt-get update && \
apt-get install -y \
  curl git \
  cmake make gcc g++ \
  libboost-thread-dev libboost-system-dev libcurl4-gnutls-dev libssl-dev libudev-dev libusb-dev zlib1g-dev \
  python3-dev && \
adduser --disabled-password --gecos "Domoticz" domoticz && \
usermod -a -G dialout domoticz && \
# OpenZWave
cd /opt && \
git clone https://github.com/OpenZWave/open-zwave open-zwave-read-only && \
cd open-zwave-read-only && \
make && \
# Domoticz
cd /opt && \
git clone https://github.com/domoticz/domoticz.git domoticz && \
cd domoticz && \
git pull && \
cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && \
make && \
# Clean
apt-get remove -y \
  git \
  cmake make gcc g++ && \
apt-get autoremove -y && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

EXPOSE  6144 ${port}
USER    domoticz
VOLUME  /data
WORKDIR /opt/domoticz

HEALTHCHECK --interval=5m --timeout=5s \
   CMD curl -f http://127.0.0.1:${8080}/json.htm?type=command&param=getversion || exit 1

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase /data/domoticz.db"]
CMD        ["-www ${port}", "-sslwww 0"]
