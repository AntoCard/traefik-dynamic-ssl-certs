# I need to publish in dockerhub the custom alpine-monit image to make this work
FROM rawmind/alpine-monit:0.5.20-2
MAINTAINER antonio.cardenes <antonio.cardenes@canaryops.com>

# Set environment
ENV SERVICE_NAME=traefik \
    SERVICE_HOME=/opt/traefik \
    SERVICE_VERSION=v1.2.3 \
    SERVICE_USER=traefik \
    SERVICE_UID=10001 \
    SERVICE_GROUP=traefik \
    SERVICE_GID=10001 \
    SERVICE_URL=https://github.com/containous/traefik/releases/download
ENV SERVICE_RELEASE=${SERVICE_URL}/${SERVICE_VERSION}/traefik_linux-amd64 \
    PATH=${PATH}:${SERVICE_HOME}/bin

# Download and install traefik
RUN mkdir -p ${SERVICE_HOME}/bin ${SERVICE_HOME}/etc ${SERVICE_HOME}/log ${SERVICE_HOME}/certs ${SERVICE_HOME}/acme && \
    apk add --no-cache libcap  && \
    cd ${SERVICE_HOME}/bin && \
    curl -jksSL "${SERVICE_RELEASE}" -O && \
    mv traefik_linux-amd64 traefik && \
    touch ${SERVICE_HOME}/etc/rules.toml && \
    chmod +x ${SERVICE_HOME}/bin/traefik && \
    addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
    adduser -g "${SERVICE_NAME} user" -D -h ${SERVICE_HOME} -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER}
ADD root /
RUN chmod +x ${SERVICE_HOME}/bin/*.sh && \
    chown -R ${SERVICE_USER}:${SERVICE_GROUP} ${SERVICE_HOME} /opt/monit && \
    setcap 'cap_net_bind_service=+ep' ${SERVICE_HOME}/bin/traefik

ADD get-certs.sh /bin/get-certs.sh
RUN chmod 755 /bin/get-certs.sh

ADD monit-service.conf /opt/monit/etc/conf.d/monit-service.conf

USER $SERVICE_USER
WORKDIR $SERVICE_HOME

