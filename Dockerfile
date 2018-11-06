FROM  debian:stretch-slim

LABEL maintainer="Guillaume LAURENT <laurent.guillaume@gmail.com>" \
      org.label-schema.vcs-url="https://github.com/domoticz/domoticz" \
      org.label-schema.url="https://domoticz.com/" \
      org.label-schema.name="Domoticz" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="MIT"

RUN \
# Packages and system setup
apt-get update && \
apt-get install -y \
  curl procps \
  git cmake make gcc g++ \
  libboost-thread-dev libboost-system-dev libcurl4-gnutls-dev libssl1.0-dev libudev-dev libusb-dev zlib1g-dev \
  python3-dev && \
# Create user
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
# Rights
mkdir /data && \
chown -R domoticz: /opt/domoticz /data && \
# Clean
apt-get remove --purge -y git cmake make gcc g++ && \
apt-get autoremove -y && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /opt/domoticz/.git* && \
rm -rf /opt/open-zwave-read-only/.git*

EXPOSE  6144 8080
USER    domoticz
VOLUME  ["/data", "/opt/domoticz/backups", "/opt/domoticz/scripts"]
WORKDIR /opt/domoticz

HEALTHCHECK --interval=5m --timeout=5s \
  CMD curl -f http://127.0.0.1:8080/json.htm?type=command&param=getversion || exit 1

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase", "/data/domoticz.db"]
CMD        ["-www", "8080", "-sslwww", "0"]
