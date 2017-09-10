FROM openjdk:8-jdk-alpine
MAINTAINER yusuke@samuraism.com

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    apk add --update curl && \
    apk add --update bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /var/lib/hub && \
    addgroup -g 2000 -S hub && \
    adduser -S -D -u 2000 -G hub hub && \
    chown -R hub:hub /var/lib/hub

######### Install hub ###################
COPY entry-point.sh /entry-point.sh

RUN \
    export HUB_VERSION=2017.3 && \
    export HUB_BUILD=6757 && \
    mkdir -p /usr/local/hub/backups && \
    mkdir -p /var/lib/hub && \
    cd /usr/local && \
    echo "$HUB_VERSION" > version.docker.image && \
    curl -L https://download.jetbrains.com/hub/${HUB_VERSION}/hub-ring-bundle-${HUB_VERSION}.${HUB_BUILD}.zip > hub.zip && \
    unzip hub.zip && \
    mv /usr/local/hub-ring-bundle-${HUB_VERSION}.${HUB_BUILD} /usr/local/hub && \
    rm -f hub.zip && \
    rm -rf /usr/local/hub/internal/java/linux-x64/man && \
    rm -rf /usr/local/hub/internal/java/mac-x64 && \
    rm -rf /usr/local/hub/internal/java/windows-amd64 && \
    chown -R hub:hub /usr/local/hub && \
    chmod -R u+rwxX /usr/local/hub/internal/java/linux-x64

USER hub
ENV HOME=/var/lib/hub
EXPOSE 8080
ENTRYPOINT ["/entry-point.sh"]
CMD ["run"]
