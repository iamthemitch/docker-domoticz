FROM debian:10-slim

ARG BUILD_DATE
ARG VCS_REF
ARG DEFAULT_WWW=8080
ARG DEFAULT_SSLWWW=0

LABEL maintainer                      "Guillaume LAURENT <laurent.guillaume@gmail.com>"
LABEL org.label-schema.build-date     $BUILD_DATE
LABEL org.label-schema.vcs-url        "https://github.com/iamthemitch/docker-domoticz.git"
LABEL org.label-schema.vcs-ref        $VCS_REF
LABEL org.label-schema.name           "Domoticz"
LABEL org.label-schema.description    "Domoticz container using Debian stable-slim"
LABEL org.label-schema.url            "https://domoticz.com"
LABEL org.label-schema.schema-version "1.0.0-rc1"

ENV WWW    $DEFAULT_WWW
ENV SSLWWW $DEFAULT_SSLWWW

RUN \
    # Packages and system setup
    apt-get update && apt-get install -y \
        curl procps wget \
        build-essential git \
        libcoap-1-0-dev libcurl4-gnutls-dev libssl-dev libudev-dev libusb-dev zlib1g-dev \
        python3-dev && \
    # Create user
    adduser --disabled-password --gecos "Domoticz" domoticz && \
    usermod -a -G dialout domoticz && \
    mkdir -p /opt && \
    # CMake 3.14.0 or higher is required
    cd && wget --quiet https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5.tar.gz && \
    tar -xzf cmake-3.15.5.tar.gz && rm cmake-3.15.5.tar.gz && \
    cd cmake-3.15.5 && \
    ./bootstrap && \
    make && \
    make install && \
    cd && rm -Rf cmake-3.15.5 && \
    cmake --version && \
    # Boost
    cd && wget --quiet https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz && \
    tar -xzf boost_1_71_0.tar.gz && rm boost_1_71_0.tar.gz && \
    cd boost_1_71_0 && \
    ./bootstrap.sh && \
    ./b2 stage threading=multi link=static --with-thread --with-system --with-chrono && \
    ./b2 install threading=multi link=static --with-thread --with-system --with-chrono && \
    cd && rm -Rf boost && \
    # Domoticz (need patch file)
    cd /opt && git clone --branch master --depth 1 https://github.com/domoticz/domoticz.git domoticz && \
    # OpenZWave
    cd && git clone https://github.com/OpenZWave/open-zwave.git open-zwave-read-only && \
    cd open-zwave-read-only && git checkout v1.4-3335-g74e05982 && patch -p1 < /opt/domoticz/patches/domoticz-open-zwave.patch && \
    make && \
    make install && \
    cd && rm -rf open-zwave-read-only && \
    # Domoticz
    cd /opt/domoticz && \
    ## Patch
    sed -i 's#^SET(DOMO_MIN_LIBBOOST_VERSION.*#SET(DOMO_MIN_LIBBOOST_VERSION 1.66.0)#' CMakeLists.txt && \
    ## Build
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DUSE_OPENSSL_STATIC=OFF \
        -DUSE_STATIC_OPENZWAVE=OFF \
        -DOpenZWave=/usr/local/lib64/libopenzwave.so \
        -Wno-dev -Wno-deprecated \
        CMakeLists.txt && \
    make && \
    rm -rf /opt/domoticz/.git* && \
    # Add plugins
    mkdir -p /opt/domoticz/plugins && \
    ## BatteryLevel
    cd /opt/domoticz/plugins && \
    git clone --depth 1 https://github.com/999LV/BatteryLevel.git BatteryLevel && \
    rm -rf /opt/domoticz/plugins/BatteryLevel/.git* && \
    ## Tradfri
    cd /opt && \
    git clone --depth 1 https://github.com/ggravlingen/pytradfri.git pytradfri && \
    rm -rf /opt/pytradfri/.git* && \
    ln -s /opt/pytradfri/pytradfri /opt/domoticz/scripts/python/pytradfri && \
    # Create missing folders and set rights
    mkdir /data && chown -R domoticz: /data && \
    mkdir /opt/domoticz/backups && \
    chown -R domoticz: /opt/domoticz && \
    # Check
    /opt/domoticz/domoticz -version && \
    # Clean
    apt-get remove --purge -y build-essential git wget && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo DONE

WORKDIR /opt/domoticz
COPY start.sh .
COPY healthcheck.sh .
RUN chmod +x *.sh

EXPOSE  6144 ${WWW}
USER    domoticz
VOLUME  ["/data", "/opt/domoticz/backups", "/opt/domoticz/plugins", "/opt/domoticz/scripts"]

HEALTHCHECK --interval=5m --timeout=5s \
    CMD /opt/domoticz/healthcheck.sh

ENTRYPOINT ["/opt/domoticz/start.sh"]
