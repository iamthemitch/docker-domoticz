FROM debian:8-slim

ARG BUILD_DATE
ARG VCS_REF
ARG DEFAULT_WWW=8080
ARG DEFAULT_SSLWWW=0

LABEL maintainer                      "Guillaume LAURENT <laurent.guillaume@gmail.com>"
LABEL org.label-schema.build-date     $BUILD_DATE
LABEL org.label-schema.vcs-url        "https://github.com/iamthemitch/docker-domoticz.git"
LABEL org.label-schema.vcs-ref        $VCS_REF
LABEL org.label-schema.name           "Domoticz"
LABEL org.label-schema.description    "Domoticz container using Debian jessie/8-slim"
LABEL org.label-schema.url            "https://domoticz.com"
LABEL org.label-schema.schema-version "1.0.0-rc1"

ENV WWW    $DEFAULT_WWW
ENV SSLWWW $DEFAULT_SSLWWW

RUN \
    # Packages and system setup
    apt-get update && apt-get install -y \
        curl git procps wget \
        libcurl3-gnutls openssl libudev-dev python3-dev && \
    # Create user
    adduser --disabled-password --gecos "Domoticz" domoticz && \  
    usermod -a -G dialout domoticz && \
    # Domoticz
    mkdir -p /opt/domoticz && cd /opt/domoticz && \
    wget -O domoticz_release.tgz --quiet "http://www.domoticz.com/download.php?channel=beta&type=release&system=linux&machine=x86_64" && \
    tar -xzf domoticz_release.tgz && \
	  rm domoticz_release.tgz && \
    # Add plugins
    mkdir -p /opt/domoticz/plugins &&  \
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
    mkdir -p /data && \
    mkdir -p /opt/domoticz/backups && \
    touch /data/domoticz.db && \
    chown -R domoticz: /data /opt/domoticz && \
    # Check
    /opt/domoticz/domoticz -version && \
    # Clean
    apt-get remove --purge -y git wget && \
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
