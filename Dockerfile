FROM  debian:stretch-slim

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer                      = "Guillaume LAURENT <laurent.guillaume@gmail.com>"
LABEL org.label-schema.build-date     = $BUILD_DATE
LABEL org.label-schema.vcs-url        = "https://github.com/iamthemitch/docker-domoticz.git"
LABEL org.label-schema.vcs-ref        = $VCS_REF
LABEL org.label-schema.name           = "Domoticz"
LABEL org.label-schema.description    = "Domoticz container using Debian stable-slim"
LABEL org.label-schema.url            = "https://domoticz.com"
LABEL org.label-schema.schema-version = "1.0.0-rc1"

RUN \
    # Packages and system setup
    apt-get update && apt-get install -y \
        curl procps \
        git cmake make gcc g++ \
        libboost-thread-dev libboost-system-dev libcoap-1-0-dev libcurl4-gnutls-dev libssl1.0-dev libudev-dev libusb-dev zlib1g-dev \
        python3-dev && \
    # Create user
    adduser --disabled-password --gecos "Domoticz" domoticz && \
    usermod -a -G dialout domoticz && \
    # OpenZWave
    cd /opt && \
    git clone --depth 1 https://github.com/OpenZWave/open-zwave open-zwave-read-only && \
    cd open-zwave-read-only && \
    make && \
    rm -rf /opt/open-zwave-read-only/.git* && \
    # Domoticz
    cd /opt && \
    git clone https://github.com/domoticz/domoticz domoticz && \
    cd domoticz && \
    git pull && \
    cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && \
    make && \
    rm -rf /opt/domoticz/.git* && \
    # Add plugins
    ## BatteryLevel
    cd /opt/domoticz/plugins && \
    git clone --depth 1 https://github.com/999LV/BatteryLevel BatteryLevel && \
    rm -rf /opt/domoticz/plugins/BatteryLevel/.git* && \
    ## Tradfri
#    ### libcoap - should work with libcoap-1-0-dev
#    cd /opt && \
#    git clone --depth 1 --recursive -b dtls https://github.com/home-assistant/libcoap.git && \
#    cd libcoap && \
#    ./autogen.sh && \
#    ./configure --disable-documentation --disable-shared --without-debug CFLAGS="-D COAP_DEBUG_FD=stderr" && \
#    make && \
#    make install && \
#    rm -rf /opt/libcoap/.git* && \
    ### pytradfri
    cd /opt && \
    git clone --depth 1 https://github.com/ggravlingen/pytradfri pytradfri && \
    rm -rf /opt/pytradfri/.git* && \
    ln -s /opt/pytradfri/pytradfri /opt/domoticz/scripts/python/pytradfri && \
    ### ikea-tradfri
    git clone --depth 1 https://gitlab.com/iamthemitch/ikea-tradfri ikea-tradfri && \
    rm -rf /opt/ikea-tradfri/.git* && \
    ln -s /opt/pytradfri/pytradfri /opt/ikea-tradfri/pytradfri && \
    # Create missing folders and set rights
    mkdir /data && chown -R domoticz: /data && \
    mkdir /opt/domoticz/backups && \
    chown -R domoticz: /opt/domoticz && \
    # Clean
    apt-get remove --purge -y git cmake make gcc g++ && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo DONE

EXPOSE  6144 8080
USER    domoticz
VOLUME  ["/data", "/opt/domoticz/backups", "/opt/domoticz/plugins", "/opt/domoticz/scripts"]
WORKDIR /opt/domoticz

HEALTHCHECK --interval=5m --timeout=5s \
  CMD curl -f http://127.0.0.1:8080/json.htm?type=command&param=getversion || exit 1

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase", "/data/domoticz.db"]
CMD        ["-www", "8080", "-sslwww", "0"]
