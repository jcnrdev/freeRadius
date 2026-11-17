FROM freeradius/freeradius-server:latest-3.2

LABEL maintainer="infra@empresa.com"
LABEL description="FreeRADIUS 3.2 com suporte a SQL (MariaDB) e monitoramento de logs LDAP"

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
    netcat-openbsd \
    docker.io \
    curl \
    unzip \
    python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/promtail \
    && curl -fsSL "https://github.com/grafana/loki/releases/download/v3.0.0/promtail-linux-amd64.zip" -o /tmp/promtail.zip \
    && unzip -o /tmp/promtail.zip -d /opt/promtail \
    && chmod +x /opt/promtail/promtail-linux-amd64 \
    && ln -sf /opt/promtail/promtail-linux-amd64 /usr/local/bin/promtail \
    && rm -f /tmp/promtail.zip

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 1812/udp 1813/udp 3799/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["freeradius", "-X"]
