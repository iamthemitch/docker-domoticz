FROM alpine:3.9

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
    apk add --no-cache --virtual=build-dependencies \
        git shadow && \
    apk add --no-cache curl domoticz python3-dev && \
    # Create user
    usermod -a -G dialout domoticz && \
    # Add plugins
    ## BatteryLevel
    cd /var/lib/domoticz/plugins && \
    git clone --depth 1 https://github.com/999LV/BatteryLevel.git BatteryLevel && \
    rm -rf /var/lib/domoticz/plugins/BatteryLevel/.git* && \
    ## Tradfri
    cd /var/lib && \
    git clone --depth 1 https://github.com/ggravlingen/pytradfri.git pytradfri && \
    rm -rf /var/lib/pytradfri/.git* && \
    ln -s /var/lib/pytradfri/pytradfri /var/lib/domoticz/scripts/python/pytradfri && \
    # Create missing folders and set rights
    mkdir /data && chown -R domoticz: /data && \
    touch /var/lib/domoticz/domoticz.db && \
    mkdir /var/lib/domoticz/backups && chown -R domoticz: /var/lib/domoticz && \
    # Check
    /usr/bin/domoticz -version && \
    # Clean
    apk del --purge build-dependencies && \
    rm -rf /var/cache/apk/* && \
    echo DONE

WORKDIR /usr/share/domoticz
COPY start.sh .
COPY healthcheck.sh .
RUN chmod +x *.sh

EXPOSE  6144 ${WWW}
USER    domoticz
VOLUME  ["/data", "/var/lib/domoticz/backups", "/var/lib/domoticz/plugins", "/var/lib/domoticz/scripts"]

HEALTHCHECK --interval=5m --timeout=5s \
    CMD /usr/share/domoticz/healthcheck.sh

WORKDIR /var/lib/domoticz
ENTRYPOINT ["/usr/share/domoticz/start.sh"]
