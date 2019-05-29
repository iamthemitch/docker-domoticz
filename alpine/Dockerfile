FROM alpine

ARG BUILD_DATE
ARG VCS_REF
ARG DEFAULT_WWW=8080
ARG DEFAULT_SSLWWW=0

LABEL maintainer                      "Guillaume LAURENT <laurent.guillaume@gmail.com>"
LABEL org.label-schema.build-date     $BUILD_DATE
LABEL org.label-schema.vcs-url        "https://github.com/iamthemitch/docker-domoticz.git"
LABEL org.label-schema.vcs-ref        $VCS_REF
LABEL org.label-schema.name           "Domoticz"
LABEL org.label-schema.description    "Domoticz container using Alpine"
LABEL org.label-schema.url            "https://domoticz.com"
LABEL org.label-schema.schema-version "1.0.0-rc1"

ENV WWW    $DEFAULT_WWW
ENV SSLWWW $DEFAULT_SSLWWW

RUN \
    # Packages and system setup
    #  Not using libexecinfo-dev as causing compilation issues
    apk add --no-cache \
        curl \
        coreutils build-base git shadow \
        boost-date_time boost-system boost-thread libcurl udev libcoap libressl libusb libusb-compat sqlite zlib \
        boost-dev curl-dev eudev-dev libcoap-dev libressl-dev libusb-dev libusb-compat-dev sqlite-dev zlib-dev \
        python3 python3-dev && \
    # CMake 3.14.0 or higher is required
    curl -O https://github.com/Kitware/CMake/releases/download/v3.14.4/cmake-3.14.4.tar.gz && \
    tar -xzvf cmake-3.14.4.tar.gz && \
    rm cmake-3.14.4.tar.gz && \
    cd cmake-3.14.4 && \
    ./bootstrap && \
    make && \
    make install && \
    cd ..  && \
    rm -Rf cmake-3.14.4 && \
    cmake --version && \
    # Create user
    adduser --disabled-password --gecos "Domoticz" domoticz && \
    usermod -a -G dialout domoticz && \
    mkdir -p /opt && \
    # OpenZWave
    cd /opt && \
    git clone --depth 1 https://github.com/OpenZWave/open-zwave.git open-zwave-read-only && \
    cd open-zwave-read-only && \
    make && \
    rm -rf /opt/open-zwave-read-only/.git* && \
    # Domoticz
    cd /opt && \
    git clone --depth 1 https://github.com/domoticz/domoticz.git domoticz && \
    cd domoticz && \
    cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && \
    make && \
    rm -rf /opt/domoticz/.git* && \
    # Add plugins
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
    # Clean
    apk del coreutils build-base cmake git shadow boost-dev curl-dev eudev-dev libcoap-dev libressl-dev libusb-dev libusb-compat-dev sqlite-dev zlib-dev && \
    rm -rf /var/cache/apk/* && \
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
