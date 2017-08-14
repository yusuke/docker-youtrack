FROM openjdk:8-jdk-alpine
MAINTAINER yusuke@samuraism.com

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    apk add --update curl && \
    apk add --update bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /var/lib/youtrack && \
    addgroup -g 2000 -S youtrack && \
    adduser -S -D -u 2000 -G youtrack youtrack && \
    chown -R youtrack:youtrack /var/lib/youtrack

######### Install hub ###################
COPY entry-point.sh /entry-point.sh

RUN \
    export YOUTRACK_VERSION=2017.3 && \
    export YOUTRACK_BUILD=35488 && \
    mkdir -p /usr/local && \
    mkdir -p /var/lib/youtrack && \
    cd /usr/local && \
    echo "$YOUTRACK_VERSION" > version.docker.image && \
    curl -L https://download.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.${YOUTRACK_BUILD}.zip > youtrack.zip && \
    unzip youtrack.zip && \
    mv /usr/local/youtrack-${YOUTRACK_VERSION}.${YOUTRACK_BUILD} /usr/local/youtrack && \
    rm -f youtrack.zip && \
    rm -rf /usr/local/youtrack/internal/java/linux-x64/man && \
    rm -rf /usr/local/youtrack/internal/java/mac-x64 && \
    rm -rf /usr/local/youtrack/internal/java/windows-amd64 && \
    chown -R youtrack:youtrack /usr/local/youtrack && \
    chmod -R u+rwxX /usr/local/youtrack/internal/java/linux-x64

USER youtrack
ENV HOME=/var/lib/youtrack
EXPOSE 8080
ENTRYPOINT ["/entry-point.sh"]
CMD ["run"]
